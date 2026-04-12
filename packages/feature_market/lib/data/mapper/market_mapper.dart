import 'package:feature_market/data/model/market_asset_model.dart';
import 'package:feature_market/data/model/replay_candle_model.dart';
import 'package:feature_market/data/model/replay_day_model.dart';
import 'package:feature_market/data/model/replay_tick_model.dart';
import 'package:feature_market/domain/entity/market_asset.dart';
import 'package:feature_market/domain/entity/replay_candle.dart';
import 'package:feature_market/domain/entity/replay_day.dart';
import 'package:feature_market/domain/entity/replay_tick.dart';

extension MarketAssetModelMapper on MarketAssetModel {
  MarketAsset toEntity() {
    return MarketAsset(
      id: id,
      symbol: symbol,
      baseAsset: baseAsset,
      quoteAsset: quoteAsset,
      displayName: displayName,
      exchange: exchange,
      isActive: isActive,
    );
  }
}

extension ReplayDayModelMapper on ReplayDayModel {
  ReplayDay toEntity() {
    return ReplayDay(
      id: id,
      marketDate: marketDate,
      exchange: exchange,
      quoteAsset: quoteAsset,
      status: status,
    );
  }
}

extension ReplayTickModelMapper on ReplayTickModel {
  ReplayTick toEntity() {
    return ReplayTick(
      replayDayId: replayDayId,
      assetId: assetId,
      sequenceNo: sequenceNo,
      eventTime: eventTime,
      tradePrice: tradePrice,
      tradeVolume: tradeVolume,
      accumulatedTradeVolume: accumulatedTradeVolume,
      accumulatedTradePrice: accumulatedTradePrice,
    );
  }
}

extension ReplayCandleModelMapper on ReplayCandleModel {
  ReplayCandle toEntity() {
    return ReplayCandle(
      replayDayId: replayDayId,
      assetId: assetId,
      interval: interval,
      candleAt: candleAt,
      openPrice: openPrice,
      highPrice: highPrice,
      lowPrice: lowPrice,
      closePrice: closePrice,
      volume: volume,
      quoteVolume: quoteVolume,
    );
  }
}
