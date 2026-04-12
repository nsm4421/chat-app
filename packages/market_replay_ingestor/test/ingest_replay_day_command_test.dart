import 'package:market_replay_ingestor/market_replay_ingestor.dart';
import 'package:test/test.dart';

void main() {
  test('resolves previous day by default', () {
    final command = IngestReplayDayCommand(
      referenceDate: DateTime.utc(2026, 4, 10, 15),
      exchange: 'upbit',
      quoteAsset: 'KRW',
    );

    expect(command.referenceDate, DateTime.utc(2026, 4, 10));
    expect(command.resolveSourceMarketDate(), DateTime.utc(2026, 4, 9));
  });
}
