import 'dart:async';

import 'package:postgres/postgres.dart';

import 'market_replay_models.dart';
import 'postgres_market_assets.dart';
import 'postgres_support.dart';
import 'replay_market_sink.dart';

final class PostgresReplayMarketSink implements ReplayMarketSink {
  PostgresReplayMarketSink._(this._connection);

  final Connection _connection;

  static Future<PostgresReplayMarketSink> open(String connectionString) async {
    final connection = await openPostgresConnection(connectionString);
    return PostgresReplayMarketSink._(connection);
  }

  @override
  Future<String> upsertReplayDayCollecting({
    required DateTime referenceDate,
    required DateTime sourceMarketDate,
    required String exchange,
    required String quoteAsset,
  }) async {
    final result = await _connection.execute(
      Sql.indexed('''
        insert into public.market_replay_days (
          reference_date,
          source_market_date,
          exchange,
          quote_asset,
          status,
          source_started_at,
          source_finished_at
        )
        values (\$1::date, \$2::date, \$3, \$4, 'collecting', timezone('utc', now()), null)
        on conflict (reference_date, exchange, quote_asset)
        do update set
          source_market_date = excluded.source_market_date,
          status = 'collecting',
          source_started_at = timezone('utc', now()),
          source_finished_at = null
        returning id::text
      '''),
      parameters: [
        formatUtcDate(referenceDate),
        formatUtcDate(sourceMarketDate),
        exchange,
        quoteAsset.toUpperCase(),
      ],
    );

    return result.single[0] as String;
  }

  @override
  Future<Map<String, String>> upsertAssets(List<ReplayAsset> assets) async {
    return upsertMarketAssets(_connection, assets);
  }

  @override
  Future<void> replaceReplayData({
    required String replayDayId,
    required List<ReplayTickRow> ticks,
    required List<ReplayCandleRow> candles,
  }) async {
    await _connection.runTx((session) async {
      await session.execute(
        Sql.indexed(
          'delete from public.market_replay_ticks where replay_day_id = \$1::uuid',
        ),
        parameters: [replayDayId],
      );
      await session.execute(
        Sql.indexed(
          'delete from public.market_replay_candles where replay_day_id = \$1::uuid',
        ),
        parameters: [replayDayId],
      );

      for (final batch in chunk(ticks, 500)) {
        final values = <String>[];
        final parameters = <Object?>[];
        var index = 1;
        for (final tick in batch) {
          values.add('''
            (\$${index++}::uuid, \$${index++}::bigint, \$${index++}::uuid, \$${index++}::timestamptz,
             \$${index++}::numeric, \$${index++}::numeric, \$${index++}::numeric, \$${index++}::numeric)
            ''');
          parameters.addAll([
            replayDayId,
            tick.sequenceNo,
            tick.assetId,
            tick.eventTime.toUtc().toIso8601String(),
            decimalString(tick.tradePrice),
            decimalString(tick.tradeVolume),
            decimalString(tick.accTradeVolume),
            decimalString(tick.accTradePrice),
          ]);
        }

        await session.execute(
          Sql.indexed('''
            insert into public.market_replay_ticks (
              replay_day_id,
              sequence_no,
              asset_id,
              event_time,
              trade_price,
              trade_volume,
              acc_trade_volume,
              acc_trade_price
            )
            values ${values.join(', ')}
          '''),
          parameters: parameters,
        );
      }

      for (final batch in chunk(candles, 500)) {
        final values = <String>[];
        final parameters = <Object?>[];
        var index = 1;
        for (final candle in batch) {
          values.add('''
            (\$${index++}::uuid, \$${index++}::uuid, \$${index++}, \$${index++}::timestamptz,
             \$${index++}::numeric, \$${index++}::numeric, \$${index++}::numeric, \$${index++}::numeric,
             \$${index++}::numeric, \$${index++}::numeric)
            ''');
          parameters.addAll([
            replayDayId,
            candle.assetId,
            candle.interval.dbValue,
            candle.candleAt.toUtc().toIso8601String(),
            decimalString(candle.openPrice),
            decimalString(candle.highPrice),
            decimalString(candle.lowPrice),
            decimalString(candle.closePrice),
            decimalString(candle.volume),
            decimalString(candle.quoteVolume),
          ]);
        }

        await session.execute(
          Sql.indexed('''
            insert into public.market_replay_candles (
              replay_day_id,
              asset_id,
              interval,
              candle_at,
              open_price,
              high_price,
              low_price,
              close_price,
              volume,
              quote_volume
            )
            values ${values.join(', ')}
          '''),
          parameters: parameters,
        );
      }
    });
  }

  @override
  Future<void> markReplayDayReady(String replayDayId) {
    return _connection.execute(
      Sql.indexed('''
        update public.market_replay_days
        set
          status = 'ready',
          source_finished_at = timezone('utc', now())
        where id = \$1::uuid
      '''),
      parameters: [replayDayId],
    );
  }

  @override
  Future<void> markReplayDayFailed(String replayDayId) {
    return _connection.execute(
      Sql.indexed('''
        update public.market_replay_days
        set
          status = 'failed',
          source_finished_at = timezone('utc', now())
        where id = \$1::uuid
      '''),
      parameters: [replayDayId],
    );
  }

  @override
  Future<void> close() => _connection.close();
}
