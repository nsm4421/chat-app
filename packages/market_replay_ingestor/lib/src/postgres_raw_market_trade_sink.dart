import 'package:postgres/postgres.dart';

import 'market_replay_models.dart';
import 'postgres_market_assets.dart';
import 'postgres_support.dart';
import 'raw_market_trade_sink.dart';

final class PostgresRawMarketTradeSink implements RawMarketTradeSink {
  PostgresRawMarketTradeSink._(this._connection);

  final Connection _connection;

  static Future<PostgresRawMarketTradeSink> open(
    String connectionString,
  ) async {
    final connection = await openPostgresConnection(connectionString);
    return PostgresRawMarketTradeSink._(connection);
  }

  @override
  Future<Map<String, String>> upsertAssets(List<ReplayAsset> assets) {
    return upsertMarketAssets(_connection, assets);
  }

  @override
  Future<int> insertTrades(List<RawMarketTradeRow> trades) async {
    if (trades.isEmpty) {
      return 0;
    }

    var insertedCount = 0;
    await _connection.runTx((session) async {
      for (final batch in chunk(trades, 500)) {
        final values = <String>[];
        final parameters = <Object?>[];
        var index = 1;
        for (final trade in batch) {
          values.add('''
            (\$${index++}, \$${index++}::uuid, \$${index++}, \$${index++}, \$${index++}::timestamptz,
             \$${index++}::bigint, \$${index++}::bigint, \$${index++}::numeric, \$${index++}::numeric,
             \$${index++}, \$${index++}::numeric, \$${index++}::numeric, \$${index++}::numeric,
             \$${index++}::numeric, \$${index++}, \$${index++}::jsonb, \$${index++}::timestamptz)
          ''');
          parameters.addAll([
            trade.exchange,
            trade.assetId,
            trade.symbol,
            trade.quoteAsset,
            trade.tradeTimestamp.toUtc().toIso8601String(),
            trade.tradeTimestampMs,
            trade.sequentialId,
            decimalString(trade.tradePrice),
            decimalString(trade.tradeVolume),
            trade.askBid,
            trade.bestAskPrice == null
                ? null
                : decimalString(trade.bestAskPrice!),
            trade.bestAskSize == null
                ? null
                : decimalString(trade.bestAskSize!),
            trade.bestBidPrice == null
                ? null
                : decimalString(trade.bestBidPrice!),
            trade.bestBidSize == null
                ? null
                : decimalString(trade.bestBidSize!),
            trade.streamType,
            trade.payloadJson,
            trade.receivedAt.toUtc().toIso8601String(),
          ]);
        }

        final rows = await session.execute(
          Sql.indexed('''
            insert into public.raw_market_trades (
              exchange,
              asset_id,
              symbol,
              quote_asset,
              trade_timestamp,
              trade_timestamp_ms,
              sequential_id,
              trade_price,
              trade_volume,
              ask_bid,
              best_ask_price,
              best_ask_size,
              best_bid_price,
              best_bid_size,
              stream_type,
              payload,
              received_at
            )
            values ${values.join(', ')}
            on conflict (exchange, symbol, sequential_id)
            do nothing
            returning 1
          '''),
          parameters: parameters,
        );
        insertedCount += rows.length;
      }
    });

    return insertedCount;
  }

  @override
  Future<void> close() => _connection.close();
}
