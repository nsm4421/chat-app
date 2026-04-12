import 'package:decimal/decimal.dart';
import 'package:market_replay_ingestor/market_replay_ingestor.dart';
import 'package:test/test.dart';

void main() {
  test('ingests replay day and builds deterministic replay rows', () async {
    final source = _FakeSource();
    final sink = _FakeSink();
    final useCase = IngestReplayDayUseCase(source, sink);

    final result = await useCase(
      IngestReplayDayCommand(
        referenceDate: DateTime.utc(2026, 4, 10),
        exchange: 'upbit',
        quoteAsset: 'KRW',
        symbols: const ['KRW-BTC'],
      ),
    );

    expect(result.replayDayId, 'replay-day-1');
    expect(result.assetCount, 1);
    expect(result.tickCount, 8);
    expect(result.candleCount, 7);
    expect(sink.readyReplayDayIds, ['replay-day-1']);
    expect(sink.failedReplayDayIds, isEmpty);
    expect(sink.persistedTicks.first.sequenceNo, 1);
    expect(sink.persistedTicks.last.sequenceNo, 8);
    expect(
      sink.persistedCandles
          .where((row) => row.interval == MarketCandleInterval.oneMinute)
          .length,
      2,
    );
    expect(
      sink.persistedCandles
          .where((row) => row.interval == MarketCandleInterval.oneDay)
          .length,
      1,
    );
  });
}

final class _FakeSource implements MarketReplaySource {
  @override
  Future<SourceReplayDayBundle> fetchReplayDay(
    IngestReplayDayCommand command,
  ) async {
    final sourceDate = command.resolveSourceMarketDate();
    return SourceReplayDayBundle(
      referenceDate: command.referenceDate,
      sourceMarketDate: sourceDate,
      exchange: command.exchange,
      quoteAsset: command.quoteAsset,
      assets: const [
        ReplayAsset(
          symbol: 'KRW-BTC',
          baseAsset: 'BTC',
          quoteAsset: 'KRW',
          displayName: 'Bitcoin',
          exchange: 'upbit',
        ),
      ],
      minuteCandles: [
        SourceMinuteCandle(
          symbol: 'KRW-BTC',
          candleAt: DateTime.utc(2026, 4, 9, 0, 0),
          openPrice: Decimal.parse('100'),
          highPrice: Decimal.parse('110'),
          lowPrice: Decimal.parse('95'),
          closePrice: Decimal.parse('105'),
          volume: Decimal.parse('10'),
          quoteVolume: Decimal.parse('1020'),
        ),
        SourceMinuteCandle(
          symbol: 'KRW-BTC',
          candleAt: DateTime.utc(2026, 4, 9, 0, 1),
          openPrice: Decimal.parse('105'),
          highPrice: Decimal.parse('112'),
          lowPrice: Decimal.parse('101'),
          closePrice: Decimal.parse('108'),
          volume: Decimal.parse('8'),
          quoteVolume: Decimal.parse('860'),
        ),
      ],
    );
  }
}

final class _FakeSink implements ReplayMarketSink {
  String? replayDayId;
  List<ReplayTickRow> persistedTicks = const [];
  List<ReplayCandleRow> persistedCandles = const [];
  List<String> readyReplayDayIds = [];
  List<String> failedReplayDayIds = [];

  @override
  Future<void> close() async {}

  @override
  Future<void> markReplayDayFailed(String replayDayId) async {
    failedReplayDayIds = [...failedReplayDayIds, replayDayId];
  }

  @override
  Future<void> markReplayDayReady(String replayDayId) async {
    readyReplayDayIds = [...readyReplayDayIds, replayDayId];
  }

  @override
  Future<void> replaceReplayData({
    required String replayDayId,
    required List<ReplayTickRow> ticks,
    required List<ReplayCandleRow> candles,
  }) async {
    this.replayDayId = replayDayId;
    persistedTicks = ticks;
    persistedCandles = candles;
  }

  @override
  Future<Map<String, String>> upsertAssets(List<ReplayAsset> assets) async {
    return {
      for (final asset in assets)
        asset.symbol: 'asset-${asset.baseAsset.toLowerCase()}',
    };
  }

  @override
  Future<String> upsertReplayDayCollecting({
    required DateTime referenceDate,
    required DateTime sourceMarketDate,
    required String exchange,
    required String quoteAsset,
  }) async {
    return 'replay-day-1';
  }
}
