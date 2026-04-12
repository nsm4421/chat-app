import 'package:feature_market/domain/entity/market_asset.dart';
import 'package:feature_market/domain/repository/market_repository.dart';

final class FetchMarketAssetsUseCase {
  const FetchMarketAssetsUseCase(this._repository);

  final MarketRepository _repository;

  Future<List<MarketAsset>> call({
    required String exchange,
    required String quoteAsset,
  }) {
    return _repository.fetchMarketAssets(
      exchange: exchange,
      quoteAsset: quoteAsset,
    );
  }
}
