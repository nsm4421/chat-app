import 'package:feature_market/data/data_source/market_data_source.dart';
import 'package:feature_market/data/exception/market_data_exception.dart';
import 'package:feature_market/data/model/market_asset_model.dart';
import 'package:feature_market/data/model/replay_candle_model.dart';
import 'package:feature_market/data/model/replay_day_model.dart';
import 'package:feature_market/data/model/replay_tick_model.dart';
import 'package:feature_market/domain/entity/replay_candle.dart';
final class UnimplementedMarketDataSource implements MarketDataSource {
  const UnimplementedMarketDataSource();

  Never _throw() {
    throw const MarketDataException(
      'MarketDataSource 구현이 아직 연결되지 않았습니다.',
    );
  }

  @override
  Future<Iterable<ReplayDayModel>> fetchReplayDays({
    String? exchange,
    String? quoteAsset,
  }) async => _throw();

  @override
  Future<Iterable<MarketAssetModel>> fetchMarketAssets({
    required String exchange,
    required String quoteAsset,
  }) async => _throw();

  @override
  Future<Iterable<ReplayTickModel>> fetchReplayTicks({
    required String replayDayId,
    required String assetId,
    int? afterSequenceNo,
    int limit = 120,
  }) async => _throw();

  @override
  Future<Iterable<ReplayCandleModel>> fetchReplayCandles({
    required String replayDayId,
    required String assetId,
    required MarketCandleInterval interval,
    int? limit,
  }) async => _throw();
}
