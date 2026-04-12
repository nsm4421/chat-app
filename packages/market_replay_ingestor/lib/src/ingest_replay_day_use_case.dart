import 'dart:collection';

import 'package:decimal/decimal.dart';

import 'ingest_replay_day_command.dart';
import 'market_replay_models.dart';
import 'market_replay_source.dart';
import 'replay_market_sink.dart';

final class IngestReplayDayUseCase {
  const IngestReplayDayUseCase(this._source, this._sink);

  final MarketReplaySource _source;
  final ReplayMarketSink _sink;

  Future<IngestReplayDayResult> call(IngestReplayDayCommand command) async {
    final sourceMarketDate = command.resolveSourceMarketDate();
    final replayDayId = await _sink.upsertReplayDayCollecting(
      referenceDate: command.referenceDate,
      sourceMarketDate: sourceMarketDate,
      exchange: command.exchange,
      quoteAsset: command.quoteAsset,
    );

    try {
      final bundle = await _source.fetchReplayDay(command);
      if (bundle.assets.isEmpty) {
        throw const IngestReplayDayException(
          'No replay assets were collected.',
        );
      }
      if (bundle.minuteCandles.isEmpty) {
        throw const IngestReplayDayException(
          'No replay candles were collected.',
        );
      }

      final assetIds = await _sink.upsertAssets(bundle.assets);
      final plan = _buildPersistencePlan(bundle: bundle, assetIds: assetIds);
      _validatePlan(plan);

      await _sink.replaceReplayData(
        replayDayId: replayDayId,
        ticks: plan.ticks,
        candles: plan.candles,
      );
      await _sink.markReplayDayReady(replayDayId);

      return IngestReplayDayResult(
        replayDayId: replayDayId,
        referenceDate: bundle.referenceDate,
        sourceMarketDate: bundle.sourceMarketDate,
        assetCount: plan.assets.length,
        tickCount: plan.ticks.length,
        candleCount: plan.candles.length,
      );
    } catch (_) {
      await _sink.markReplayDayFailed(replayDayId);
      rethrow;
    }
  }

  ReplayDayPersistencePlan _buildPersistencePlan({
    required SourceReplayDayBundle bundle,
    required Map<String, String> assetIds,
  }) {
    final groupedCandles = SplayTreeMap<String, List<SourceMinuteCandle>>();
    for (final candle in bundle.minuteCandles) {
      groupedCandles
          .putIfAbsent(candle.symbol, () => <SourceMinuteCandle>[])
          .add(candle);
    }

    final tickDrafts = <ReplayTickDraft>[];
    final candleDrafts = <ReplayCandleDraft>[];
    for (final entry in groupedCandles.entries) {
      final symbol = entry.key;
      if (!assetIds.containsKey(symbol)) {
        continue;
      }

      final candles = [...entry.value]
        ..sort((a, b) => a.candleAt.compareTo(b.candleAt));
      tickDrafts.addAll(_buildPseudoTicks(symbol, candles));
      candleDrafts.addAll(_buildAggregatedCandles(symbol, candles));
    }

    tickDrafts.sort((a, b) {
      final timeOrder = a.eventTime.compareTo(b.eventTime);
      if (timeOrder != 0) {
        return timeOrder;
      }
      return a.assetSymbol.compareTo(b.assetSymbol);
    });

    final ticks = <ReplayTickRow>[];
    for (var index = 0; index < tickDrafts.length; index++) {
      final draft = tickDrafts[index];
      final assetId = assetIds[draft.assetSymbol];
      if (assetId == null) {
        continue;
      }
      ticks.add(
        ReplayTickRow(
          sequenceNo: index + 1,
          assetId: assetId,
          eventTime: draft.eventTime,
          tradePrice: draft.tradePrice,
          tradeVolume: draft.tradeVolume,
          accTradeVolume: draft.accTradeVolume,
          accTradePrice: draft.accTradePrice,
        ),
      );
    }

    final candles = candleDrafts
        .map((draft) {
          final assetId = assetIds[draft.assetSymbol];
          if (assetId == null) {
            return null;
          }
          return ReplayCandleRow(
            assetId: assetId,
            interval: draft.interval,
            candleAt: draft.candleAt,
            openPrice: draft.openPrice,
            highPrice: draft.highPrice,
            lowPrice: draft.lowPrice,
            closePrice: draft.closePrice,
            volume: draft.volume,
            quoteVolume: draft.quoteVolume,
          );
        })
        .whereType<ReplayCandleRow>()
        .toList(growable: false);

    return ReplayDayPersistencePlan(
      assets: bundle.assets
          .where((asset) => assetIds.containsKey(asset.symbol))
          .toList(growable: false),
      ticks: ticks,
      candles: candles,
    );
  }

  List<ReplayTickDraft> _buildPseudoTicks(
    String symbol,
    List<SourceMinuteCandle> candles,
  ) {
    final drafts = <ReplayTickDraft>[];
    Decimal accVolume = Decimal.zero;
    Decimal accPrice = Decimal.zero;

    for (final candle in candles) {
      final minuteTicks = _expandCandleToTicks(candle);
      for (final tick in minuteTicks) {
        accVolume += tick.tradeVolume;
        accPrice += tick.accTradePrice;
        drafts.add(
          ReplayTickDraft(
            assetSymbol: symbol,
            eventTime: tick.eventTime,
            tradePrice: tick.tradePrice,
            tradeVolume: tick.tradeVolume,
            accTradeVolume: accVolume,
            accTradePrice: accPrice,
          ),
        );
      }
    }

    return drafts;
  }

  List<_PseudoTick> _expandCandleToTicks(SourceMinuteCandle candle) {
    final prices = candle.closePrice >= candle.openPrice
        ? [
            candle.openPrice,
            candle.lowPrice,
            candle.highPrice,
            candle.closePrice,
          ]
        : [
            candle.openPrice,
            candle.highPrice,
            candle.lowPrice,
            candle.closePrice,
          ];

    final volumeWeights = [
      Decimal.parse('0.30'),
      Decimal.parse('0.20'),
      Decimal.parse('0.20'),
      Decimal.parse('0.30'),
    ];
    final quoteWeights = volumeWeights;
    final secondOffsets = [0, 20, 40, 59];

    Decimal assignedVolume = Decimal.zero;
    Decimal assignedQuote = Decimal.zero;
    final ticks = <_PseudoTick>[];
    for (var i = 0; i < prices.length; i++) {
      final isLast = i == prices.length - 1;
      final tradeVolume = isLast
          ? candle.volume - assignedVolume
          : _scaleDecimal(candle.volume, volumeWeights[i]);
      final quoteVolume = isLast
          ? candle.quoteVolume - assignedQuote
          : _scaleDecimal(candle.quoteVolume, quoteWeights[i]);

      assignedVolume += tradeVolume;
      assignedQuote += quoteVolume;

      ticks.add(
        _PseudoTick(
          eventTime: candle.candleAt.add(Duration(seconds: secondOffsets[i])),
          tradePrice: prices[i],
          tradeVolume: tradeVolume,
          accTradePrice: quoteVolume,
        ),
      );
    }

    return ticks;
  }

  List<ReplayCandleDraft> _buildAggregatedCandles(
    String symbol,
    List<SourceMinuteCandle> minuteCandles,
  ) {
    final drafts = <ReplayCandleDraft>[];
    for (final interval in MarketCandleInterval.values) {
      final grouped = <DateTime, _CandleAccumulator>{};
      for (final candle in minuteCandles) {
        final bucket = _floorCandleAt(candle.candleAt, interval);
        grouped.putIfAbsent(bucket, () => _CandleAccumulator()).add(candle);
      }

      final orderedBuckets = grouped.keys.toList()..sort();
      for (final bucket in orderedBuckets) {
        final snapshot = grouped[bucket]!.snapshot();
        drafts.add(
          ReplayCandleDraft(
            assetSymbol: symbol,
            interval: interval,
            candleAt: bucket,
            openPrice: snapshot.openPrice,
            highPrice: snapshot.highPrice,
            lowPrice: snapshot.lowPrice,
            closePrice: snapshot.closePrice,
            volume: snapshot.volume,
            quoteVolume: snapshot.quoteVolume,
          ),
        );
      }
    }
    return drafts;
  }

  DateTime _floorCandleAt(DateTime candleAt, MarketCandleInterval interval) {
    final utc = candleAt.toUtc();
    if (interval == MarketCandleInterval.oneDay) {
      return DateTime.utc(utc.year, utc.month, utc.day);
    }

    final totalMinutes = utc.hour * 60 + utc.minute;
    final flooredMinutes =
        (totalMinutes ~/ interval.minutes) * interval.minutes;
    final hour = flooredMinutes ~/ 60;
    final minute = flooredMinutes % 60;
    return DateTime.utc(utc.year, utc.month, utc.day, hour, minute);
  }

  void _validatePlan(ReplayDayPersistencePlan plan) {
    if (plan.ticks.isEmpty) {
      throw const IngestReplayDayException('Replay ticks were not generated.');
    }
    if (plan.candles.isEmpty) {
      throw const IngestReplayDayException(
        'Replay candles were not generated.',
      );
    }

    for (var i = 0; i < plan.ticks.length; i++) {
      final expected = i + 1;
      if (plan.ticks[i].sequenceNo != expected) {
        throw IngestReplayDayException(
          'Replay tick sequence is not contiguous at index $i.',
        );
      }
    }
  }
}

Decimal _scaleDecimal(Decimal value, Decimal weight) {
  return value * weight;
}

final class _PseudoTick {
  const _PseudoTick({
    required this.eventTime,
    required this.tradePrice,
    required this.tradeVolume,
    required this.accTradePrice,
  });

  final DateTime eventTime;
  final Decimal tradePrice;
  final Decimal tradeVolume;
  final Decimal accTradePrice;
}

final class _CandleAccumulator {
  SourceMinuteCandle? _first;
  SourceMinuteCandle? _last;
  Decimal? _high;
  Decimal? _low;
  Decimal _volume = Decimal.zero;
  Decimal _quoteVolume = Decimal.zero;

  void add(SourceMinuteCandle candle) {
    _first ??= candle;
    _last = candle;
    _high = _high == null || candle.highPrice > _high!
        ? candle.highPrice
        : _high;
    _low = _low == null || candle.lowPrice < _low! ? candle.lowPrice : _low;
    _volume += candle.volume;
    _quoteVolume += candle.quoteVolume;
  }

  _CandleSnapshot snapshot() {
    final first = _first;
    final last = _last;
    final high = _high;
    final low = _low;
    if (first == null || last == null || high == null || low == null) {
      throw const IngestReplayDayException(
        'Cannot snapshot an empty candle bucket.',
      );
    }

    return _CandleSnapshot(
      openPrice: first.openPrice,
      highPrice: high,
      lowPrice: low,
      closePrice: last.closePrice,
      volume: _volume,
      quoteVolume: _quoteVolume,
    );
  }
}

final class _CandleSnapshot {
  const _CandleSnapshot({
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.quoteVolume,
  });

  final Decimal openPrice;
  final Decimal highPrice;
  final Decimal lowPrice;
  final Decimal closePrice;
  final Decimal volume;
  final Decimal quoteVolume;
}
