import 'package:feature_market/domain/entity/replay_day.dart';
import 'package:feature_market/domain/repository/market_repository.dart';

final class FetchReplayDaysUseCase {
  const FetchReplayDaysUseCase(this._repository);

  final MarketRepository _repository;

  Future<List<ReplayDay>> call({
    String? exchange,
    String? quoteAsset,
  }) {
    return _repository.fetchReplayDays(
      exchange: exchange,
      quoteAsset: quoteAsset,
    );
  }
}
