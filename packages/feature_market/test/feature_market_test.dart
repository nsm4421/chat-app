import 'package:flutter_test/flutter_test.dart';

import 'package:feature_market/feature_market.dart';

void main() {
  test('replay day exposes ready state', () {
    final replayDay = ReplayDay(
      id: 'day-1',
      marketDate: DateTime.utc(2026, 4, 10),
      exchange: 'upbit',
      quoteAsset: 'KRW',
      status: ReplayDayStatus.ready,
    );

    expect(replayDay.isReady, isTrue);
  });
}
