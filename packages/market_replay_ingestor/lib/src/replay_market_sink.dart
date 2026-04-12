import 'market_replay_models.dart';

abstract interface class ReplayMarketSink {
  Future<String> upsertReplayDayCollecting({
    required DateTime referenceDate,
    required DateTime sourceMarketDate,
    required String exchange,
    required String quoteAsset,
  });

  Future<Map<String, String>> upsertAssets(List<ReplayAsset> assets);

  Future<void> replaceReplayData({
    required String replayDayId,
    required List<ReplayTickRow> ticks,
    required List<ReplayCandleRow> candles,
  });

  Future<void> markReplayDayReady(String replayDayId);

  Future<void> markReplayDayFailed(String replayDayId);

  Future<void> close();
}
