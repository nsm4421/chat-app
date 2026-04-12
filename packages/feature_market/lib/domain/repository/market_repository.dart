import 'package:feature_market/domain/entity/market_asset.dart';
import 'package:feature_market/domain/entity/replay_candle.dart';
import 'package:feature_market/domain/entity/replay_day.dart';
import 'package:feature_market/domain/entity/replay_tick.dart';

abstract interface class MarketRepository {
  Future<List<ReplayDay>> fetchReplayDays({
    String? exchange,
    String? quoteAsset,
  });

  Future<List<MarketAsset>> fetchMarketAssets({
    required String exchange,
    required String quoteAsset,
  });

  Future<List<ReplayTick>> fetchReplayTicks({
    required String replayDayId,
    required String assetId,
    int? afterSequenceNo,
    int limit = 120,
  });

  Future<List<ReplayCandle>> fetchReplayCandles({
    required String replayDayId,
    required String assetId,
    required MarketCandleInterval interval,
    int? limit,
  });
}
