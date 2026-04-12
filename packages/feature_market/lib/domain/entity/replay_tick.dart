import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_tick.freezed.dart';

@freezed
class ReplayTick with _$ReplayTick {
  const ReplayTick({
    required this.replayDayId,
    required this.assetId,
    required this.sequenceNo,
    required this.eventTime,
    required this.tradePrice,
    this.tradeVolume,
    this.accumulatedTradeVolume,
    this.accumulatedTradePrice,
  });

  @override
  final String replayDayId;

  @override
  final String assetId;

  @override
  final int sequenceNo;

  @override
  final DateTime eventTime;

  @override
  final double tradePrice;

  @override
  final double? tradeVolume;

  @override
  final double? accumulatedTradeVolume;

  @override
  final double? accumulatedTradePrice;
}
