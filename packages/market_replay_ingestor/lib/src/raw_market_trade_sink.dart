import 'market_replay_models.dart';

abstract interface class RawMarketTradeSink {
  Future<Map<String, String>> upsertAssets(List<ReplayAsset> assets);

  Future<int> insertTrades(List<RawMarketTradeRow> trades);

  Future<void> close();
}
