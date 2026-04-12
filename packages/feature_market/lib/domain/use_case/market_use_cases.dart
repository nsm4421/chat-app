import 'package:feature_market/domain/repository/market_repository.dart';
import 'package:feature_market/domain/use_case/scenario/fetch_market_assets_use_case.dart';
import 'package:feature_market/domain/use_case/scenario/fetch_replay_candles_use_case.dart';
import 'package:feature_market/domain/use_case/scenario/fetch_replay_days_use_case.dart';
import 'package:feature_market/domain/use_case/scenario/fetch_replay_ticks_use_case.dart';
class MarketUseCases {
  MarketUseCases(this._repository);

  final MarketRepository _repository;

  late final FetchReplayDaysUseCase _fetchReplayDays = FetchReplayDaysUseCase(
    _repository,
  );
  late final FetchMarketAssetsUseCase _fetchMarketAssets =
      FetchMarketAssetsUseCase(_repository);
  late final FetchReplayTicksUseCase _fetchReplayTicks = FetchReplayTicksUseCase(
    _repository,
  );
  late final FetchReplayCandlesUseCase _fetchReplayCandles =
      FetchReplayCandlesUseCase(_repository);

  FetchReplayDaysUseCase get replayDays => _fetchReplayDays;
  FetchMarketAssetsUseCase get marketAssets => _fetchMarketAssets;
  FetchReplayTicksUseCase get replayTicks => _fetchReplayTicks;
  FetchReplayCandlesUseCase get replayCandles => _fetchReplayCandles;
}
