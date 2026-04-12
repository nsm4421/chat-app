import 'package:feature_market/domain/entity/replay_candle.dart';
import 'package:feature_market/domain/repository/market_repository.dart';

final class FetchReplayCandlesUseCase {
  const FetchReplayCandlesUseCase(this._repository);

  final MarketRepository _repository;

  Future<List<ReplayCandle>> call({
    required String replayDayId,
    required String assetId,
    required MarketCandleInterval interval,
    int? limit,
  }) {
    return _repository.fetchReplayCandles(
      replayDayId: replayDayId,
      assetId: assetId,
      interval: interval,
      limit: limit,
    );
  }
}
