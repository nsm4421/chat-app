import 'package:feature_market/domain/entity/replay_day.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'replay_day_model.freezed.dart';

@freezed
class ReplayDayModel with _$ReplayDayModel {
  const ReplayDayModel({
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
}
