import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_candle.freezed.dart';

enum MarketCandleInterval { oneMinute, fiveMinutes, fifteenMinutes, oneHour, fourHours, oneDay }

@freezed
class ReplayCandle with _$ReplayCandle {
  const ReplayCandle({
    required this.replayDayId,
    required this.assetId,
    required this.interval,
    required this.candleAt,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.closePrice,
    required this.volume,
    this.quoteVolume,
  });

  @override
  final String replayDayId;

  @override
  final String assetId;

  @override
  final MarketCandleInterval interval;

  @override
  final DateTime candleAt;

  @override
  final double openPrice;

  @override
  final double highPrice;

  @override
  final double lowPrice;

  @override
  final double closePrice;

  @override
  final double volume;

  @override
  final double? quoteVolume;
}
