import 'package:feature_market/data/model/market_asset_model.dart';
import 'package:feature_market/data/model/replay_candle_model.dart';
import 'package:feature_market/data/model/replay_day_model.dart';
import 'package:feature_market/data/model/replay_tick_model.dart';
import 'package:feature_market/domain/entity/replay_candle.dart';

abstract interface class MarketDataSource {
  Future<Iterable<ReplayDayModel>> fetchReplayDays({
    String? exchange,
    String? quoteAsset,
  });

  Future<Iterable<MarketAssetModel>> fetchMarketAssets({
    required String exchange,
    required String quoteAsset,
  });

  Future<Iterable<ReplayTickModel>> fetchReplayTicks({
    required String replayDayId,
    required String assetId,
    int? afterSequenceNo,
    int limit = 120,
  });

  Future<Iterable<ReplayCandleModel>> fetchReplayCandles({
    required String replayDayId,
    required String assetId,
    required MarketCandleInterval interval,
    int? limit,
  });
}
