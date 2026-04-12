import 'package:decimal/decimal.dart';

enum MarketCandleInterval {
  oneMinute('1m', 1),
  fiveMinutes('5m', 5),
  fifteenMinutes('15m', 15),
  oneHour('1h', 60),
  fourHours('4h', 240),
  oneDay('1d', 1440);

  const MarketCandleInterval(this.dbValue, this.minutes);

  final String dbValue;
  final int minutes;
}

final class ReplayAsset {
  const ReplayAsset({
    required this.symbol,
    required this.baseAsset,
    required this.quoteAsset,
    required this.displayName,
    required this.exchange,
    this.category,
    this.isActive = true,
  });

  final String symbol;
  final String baseAsset;
  final String quoteAsset;
  final String displayName;
  final String exchange;
  final String? category;
  final bool isActive;
}

final class SourceMinuteCandle {
  const SourceMinuteCandle({
    required this.symbol,
    required this.candleAt,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.quoteVolume,
  });

  final String symbol;
  final DateTime candleAt;
  final Decimal openPrice;
  final Decimal highPrice;
  final Decimal lowPrice;
  final Decimal closePrice;
  final Decimal volume;
  final Decimal quoteVolume;
}

final class SourceReplayDayBundle {
  const SourceReplayDayBundle({
    required this.referenceDate,
    required this.sourceMarketDate,
    required this.exchange,
    required this.quoteAsset,
    required this.assets,
    required this.minuteCandles,
  });

  final DateTime referenceDate;
  final DateTime sourceMarketDate;
  final String exchange;
  final String quoteAsset;
  final List<ReplayAsset> assets;
  final List<SourceMinuteCandle> minuteCandles;
}

final class ReplayTickDraft {
  const ReplayTickDraft({
    required this.assetSymbol,
    required this.eventTime,
    required this.tradePrice,
    required this.tradeVolume,
    required this.accTradeVolume,
    required this.accTradePrice,
  });

  final String assetSymbol;
  final DateTime eventTime;
  final Decimal tradePrice;
  final Decimal tradeVolume;
  final Decimal accTradeVolume;
  final Decimal accTradePrice;
}

final class ReplayCandleDraft {
  const ReplayCandleDraft({
    required this.assetSymbol,
    required this.interval,
    required this.candleAt,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.quoteVolume,
  });

  final String assetSymbol;
  final MarketCandleInterval interval;
  final DateTime candleAt;
  final Decimal openPrice;
  final Decimal highPrice;
  final Decimal lowPrice;
  final Decimal closePrice;
  final Decimal volume;
  final Decimal quoteVolume;
}

final class ReplayTickRow {
  const ReplayTickRow({
    required this.sequenceNo,
    required this.assetId,
    required this.eventTime,
    required this.tradePrice,
    required this.tradeVolume,
    required this.accTradeVolume,
    required this.accTradePrice,
  });

  final int sequenceNo;
  final String assetId;
  final DateTime eventTime;
  final Decimal tradePrice;
  final Decimal tradeVolume;
  final Decimal accTradeVolume;
  final Decimal accTradePrice;
}

final class ReplayCandleRow {
  const ReplayCandleRow({
    required this.assetId,
    required this.interval,
    required this.candleAt,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    required this.quoteVolume,
  });

  final String assetId;
  final MarketCandleInterval interval;
  final DateTime candleAt;
  final Decimal openPrice;
  final Decimal highPrice;
  final Decimal lowPrice;
  final Decimal closePrice;
  final Decimal volume;
  final Decimal quoteVolume;
}

final class ReplayDayPersistencePlan {
  const ReplayDayPersistencePlan({
    required this.assets,
    required this.ticks,
    required this.candles,
  });

  final List<ReplayAsset> assets;
  final List<ReplayTickRow> ticks;
  final List<ReplayCandleRow> candles;
}

final class RawMarketTradeRow {
  const RawMarketTradeRow({
    required this.exchange,
    required this.assetId,
    required this.symbol,
    required this.quoteAsset,
    required this.tradeTimestamp,
    required this.tradeTimestampMs,
    required this.sequentialId,
    required this.tradePrice,
    required this.tradeVolume,
    required this.askBid,
    required this.streamType,
    required this.payloadJson,
    required this.receivedAt,
    this.bestAskPrice,
    this.bestAskSize,
    this.bestBidPrice,
    this.bestBidSize,
  });

  final String exchange;
  final String assetId;
  final String symbol;
  final String quoteAsset;
  final DateTime tradeTimestamp;
  final int tradeTimestampMs;
  final int sequentialId;
  final Decimal tradePrice;
  final Decimal tradeVolume;
  final String askBid;
  final Decimal? bestAskPrice;
  final Decimal? bestAskSize;
  final Decimal? bestBidPrice;
  final Decimal? bestBidSize;
  final String streamType;
  final String payloadJson;
  final DateTime receivedAt;
}

final class IngestReplayDayResult {
  const IngestReplayDayResult({
    required this.replayDayId,
    required this.referenceDate,
    required this.sourceMarketDate,
    required this.assetCount,
    required this.tickCount,
    required this.candleCount,
  });

  final String replayDayId;
  final DateTime referenceDate;
  final DateTime sourceMarketDate;
  final int assetCount;
  final int tickCount;
  final int candleCount;
}

final class IngestReplayDayException implements Exception {
  const IngestReplayDayException(this.message);

  final String message;

  @override
  String toString() => 'IngestReplayDayException: $message';
}
