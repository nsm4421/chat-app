import 'package:feature_market/domain/entity/replay_tick.dart';
import 'package:feature_market/domain/repository/market_repository.dart';

final class FetchReplayTicksUseCase {
  const FetchReplayTicksUseCase(this._repository);

  final MarketRepository _repository;

  Future<List<ReplayTick>> call({
    required String replayDayId,
    required String assetId,
    int? afterSequenceNo,
    int limit = 120,
  }) {
    return _repository.fetchReplayTicks(
      replayDayId: replayDayId,
      assetId: assetId,
      afterSequenceNo: afterSequenceNo,
      limit: limit,
    );
  }
}
