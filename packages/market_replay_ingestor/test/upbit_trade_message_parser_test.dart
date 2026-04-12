import 'dart:convert';

import 'package:market_replay_ingestor/market_replay_ingestor.dart';
import 'package:test/test.dart';

void main() {
  group('UpbitTradeMessageParser', () {
    test('parses a default trade payload into raw trade rows', () {
      const parser = UpbitTradeMessageParser();
      final rows = parser.parse(
        rawMessage: jsonEncode({
          'type': 'trade',
          'code': 'SGD-BTC',
          'trade_timestamp': 1749471055055,
          'trade_price': 138423.0,
          'trade_volume': 0.0000167,
          'ask_bid': 'ASK',
          'sequential_id': 1749471055055000,
          'best_ask_price': 138770,
          'best_ask_size': 0.17,
          'best_bid_price': 138423,
          'best_bid_size': 0.1699833,
          'stream_type': 'REALTIME',
        }),
        exchange: 'upbit',
        quoteAsset: 'SGD',
        assetsBySymbol: const {
          'SGD-BTC': TrackedMarketAsset(
            assetId: 'asset-1',
            symbol: 'SGD-BTC',
            quoteAsset: 'SGD',
          ),
        },
        receivedAt: DateTime.utc(2026, 4, 12, 1),
      );

      expect(rows, hasLength(1));
      expect(rows.single.assetId, 'asset-1');
      expect(rows.single.symbol, 'SGD-BTC');
      expect(rows.single.tradeTimestampMs, 1749471055055);
      expect(rows.single.sequentialId, 1749471055055000);
      expect(rows.single.askBid, 'ASK');
      expect(rows.single.streamType, 'REALTIME');
    });

    test('ignores messages for symbols outside the tracked asset map', () {
      const parser = UpbitTradeMessageParser();
      final rows = parser.parse(
        rawMessage: jsonEncode({
          'type': 'trade',
          'code': 'SGD-ETH',
          'trade_timestamp': 1749471055055,
          'trade_price': 3200,
          'trade_volume': 0.5,
          'ask_bid': 'BID',
          'sequential_id': 1749471055055001,
          'stream_type': 'REALTIME',
        }),
        exchange: 'upbit',
        quoteAsset: 'SGD',
        assetsBySymbol: const {
          'SGD-BTC': TrackedMarketAsset(
            assetId: 'asset-1',
            symbol: 'SGD-BTC',
            quoteAsset: 'SGD',
          ),
        },
        receivedAt: DateTime.utc(2026, 4, 12, 1),
      );

      expect(rows, isEmpty);
    });
  });
}
