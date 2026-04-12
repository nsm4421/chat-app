import 'package:feature_market/data/data_source/market_data_source.dart';
import 'package:feature_market/data/mapper/market_mapper.dart';
import 'package:feature_market/data/repository/market_repository_error_handler.dart';
import 'package:feature_market/domain/entity/market_asset.dart';
import 'package:feature_market/domain/entity/replay_candle.dart';
import 'package:feature_market/domain/entity/replay_day.dart';
import 'package:feature_market/domain/entity/replay_tick.dart';
import 'package:feature_market/domain/repository/market_repository.dart';
class MarketRepositoryImpl
    with MarketRepositoryErrorHandler
    implements MarketRepository {
  MarketRepositoryImpl(this._marketDataSource);

  final MarketDataSource _marketDataSource;

  @override
  Future<List<ReplayDay>> fetchReplayDays({
    String? exchange,
    String? quoteAsset,
  }) async {
    return guardMarketRequest(() async {
      final replayDays = await _marketDataSource.fetchReplayDays(
        exchange: exchange,
        quoteAsset: quoteAsset,
      );

      return replayDays.map((day) => day.toEntity()).toList(growable: false);
    }, fallbackMessage: '플레이 가능한 날짜를 불러오는 중 문제가 발생했습니다.');
  }

  @override
  Future<List<MarketAsset>> fetchMarketAssets({
    required String exchange,
    required String quoteAsset,
  }) async {
    return guardMarketRequest(() async {
      final assets = await _marketDataSource.fetchMarketAssets(
        exchange: exchange,
        quoteAsset: quoteAsset,
      );

      return assets.map((asset) => asset.toEntity()).toList(growable: false);
    }, fallbackMessage: '코인 종목 목록을 불러오는 중 문제가 발생했습니다.');
  }

  @override
  Future<List<ReplayTick>> fetchReplayTicks({
    required String replayDayId,
    required String assetId,
    int? afterSequenceNo,
    int limit = 120,
  }) async {
    return guardMarketRequest(() async {
      final ticks = await _marketDataSource.fetchReplayTicks(
        replayDayId: replayDayId,
        assetId: assetId,
        afterSequenceNo: afterSequenceNo,
        limit: limit,
      );

      return ticks.map((tick) => tick.toEntity()).toList(growable: false);
    }, fallbackMessage: '시장 replay 데이터를 불러오는 중 문제가 발생했습니다.');
  }

  @override
  Future<List<ReplayCandle>> fetchReplayCandles({
    required String replayDayId,
    required String assetId,
    required MarketCandleInterval interval,
    int? limit,
  }) async {
    return guardMarketRequest(() async {
      final candles = await _marketDataSource.fetchReplayCandles(
        replayDayId: replayDayId,
        assetId: assetId,
        interval: interval,
        limit: limit,
      );

      return candles
          .map((candle) => candle.toEntity())
          .toList(growable: false);
    }, fallbackMessage: '차트 데이터를 불러오는 중 문제가 발생했습니다.');
  }
}
