import 'package:postgres/postgres.dart';

import 'market_replay_models.dart';
import 'postgres_support.dart';

Future<Map<String, String>> upsertMarketAssets(
  Connection connection,
  List<ReplayAsset> assets,
) async {
  if (assets.isEmpty) {
    return const {};
  }

  await connection.runTx((session) async {
    for (final batch in chunk(assets, 200)) {
      final values = <String>[];
      final parameters = <Object?>[];
      var index = 1;
      for (final asset in batch) {
        values.add(
          '(\$${index++}, \$${index++}, \$${index++}, \$${index++}, \$${index++}, \$${index++}, \$${index++})',
        );
        parameters.addAll([
          asset.symbol,
          asset.baseAsset,
          asset.quoteAsset,
          asset.displayName,
          asset.exchange,
          asset.category,
          asset.isActive,
        ]);
      }

      await session.execute(
        Sql.indexed('''
          insert into public.market_assets (
            symbol,
            base_asset,
            quote_asset,
            display_name,
            exchange,
            category,
            is_active
          )
          values ${values.join(', ')}
          on conflict (exchange, symbol)
          do update set
            base_asset = excluded.base_asset,
            quote_asset = excluded.quote_asset,
            display_name = excluded.display_name,
            category = excluded.category,
            is_active = excluded.is_active,
            updated_at = timezone('utc', now())
        '''),
        parameters: parameters,
      );
    }
  });

  final symbols = assets.map((asset) => asset.symbol).toList(growable: false);
  final rows = await connection.execute(
    Sql.indexed('''
      select id::text, symbol
      from public.market_assets
      where exchange = \$1
        and symbol in (${indexedPlaceholders(symbols.length, startIndex: 2)})
    '''),
    parameters: [assets.first.exchange, ...symbols],
  );

  return {for (final row in rows) row[1] as String: row[0] as String};
}
