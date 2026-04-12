import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_day.freezed.dart';

enum ReplayDayStatus { collecting, ready, failed, archived }

@freezed
class ReplayDay with _$ReplayDay {
  const ReplayDay({
    required this.id,
    required this.marketDate,
    required this.exchange,
    required this.quoteAsset,
    required this.status,
  });

  @override
  final String id;

  @override
  final DateTime marketDate;

  @override
  final String exchange;

  @override
  final String quoteAsset;

  @override
  final ReplayDayStatus status;

  bool get isReady => status == ReplayDayStatus.ready;
}
