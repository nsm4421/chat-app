import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';

import 'market_replay_models.dart';
import 'raw_market_trade_sink.dart';
import 'upbit_market_catalog_client.dart';

typedef TradeBatchPersistedCallback =
    void Function(int insertedCount, int totalInsertedCount);
typedef TradeCollectorWarningCallback = void Function(Object error);

final class UpbitTradeWebSocketCollector {
  UpbitTradeWebSocketCollector({
    required RawMarketTradeSink sink,
    required String websocketUrl,
    required String exchange,
    required String quoteAsset,
    required List<TrackedMarketAsset> assets,
    this.batchSize = 200,
    this.flushInterval = const Duration(seconds: 1),
    this.pingInterval = const Duration(seconds: 30),
    this.includeSnapshot = false,
    this.onBatchPersisted,
    this.onWarning,
  }) : _sink = sink,
       _websocketUrl = websocketUrl,
       _exchange = exchange,
       _quoteAsset = quoteAsset.toUpperCase(),
       _assets = assets;

  final RawMarketTradeSink _sink;
  final String _websocketUrl;
  final String _exchange;
  final String _quoteAsset;
  final List<TrackedMarketAsset> _assets;
  final int batchSize;
  final Duration flushInterval;
  final Duration pingInterval;
  final bool includeSnapshot;
  final TradeBatchPersistedCallback? onBatchPersisted;
  final TradeCollectorWarningCallback? onWarning;

  final List<RawMarketTradeRow> _buffer = <RawMarketTradeRow>[];
  final _parser = const UpbitTradeMessageParser();
  final _assetsBySymbol = <String, TrackedMarketAsset>{};

  Future<void> _serial = Future<void>.value();
  Timer? _flushTimer;
  WebSocket? _socket;
  DateTime _lastFlushAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  int _persistedCount = 0;
  bool _isClosing = false;

  Future<void> run() async {
    if (_assets.isEmpty) {
      throw ArgumentError('At least one market asset is required.');
    }

    for (final asset in _assets) {
      _assetsBySymbol[asset.symbol] = asset;
    }

    _flushTimer ??= Timer.periodic(flushInterval, (_) {
      unawaited(
        _runSerial(() async {
          if (_buffer.isEmpty || !_shouldFlush()) {
            return;
          }
          await _flushBufferUnsafe();
        }),
      );
    });

    var reconnectDelay = const Duration(seconds: 1);
    while (!_isClosing) {
      try {
        await _connectAndConsume();
        reconnectDelay = const Duration(seconds: 1);
      } catch (error) {
        if (_isClosing) {
          break;
        }
        onWarning?.call(error);
        await Future<void>.delayed(reconnectDelay);
        reconnectDelay = _nextReconnectDelay(reconnectDelay);
      }
    }

    await _runSerial(() async {
      await _flushBufferUnsafe();
    });
  }

  Future<void> close() async {
    _isClosing = true;
    _flushTimer?.cancel();
    _flushTimer = null;
    final socket = _socket;
    _socket = null;
    if (socket != null) {
      await socket.close(WebSocketStatus.normalClosure, 'collector shutdown');
    }
    await _runSerial(() async {
      await _flushBufferUnsafe();
    });
  }

  Future<void> _connectAndConsume() async {
    final socket = await WebSocket.connect(_websocketUrl);
    _socket = socket;
    socket.pingInterval = pingInterval;
    socket.add(jsonEncode(_buildSubscriptionPayload()));

    await for (final message in socket) {
      if (_isClosing) {
        break;
      }

      try {
        final rows = _parser.parse(
          rawMessage: message,
          exchange: _exchange,
          quoteAsset: _quoteAsset,
          assetsBySymbol: _assetsBySymbol,
          receivedAt: DateTime.now().toUtc(),
        );
        if (rows.isEmpty) {
          continue;
        }

        await _runSerial(() async {
          _buffer.addAll(rows);
          if (_buffer.length >= batchSize || _shouldFlush()) {
            await _flushBufferUnsafe();
          }
        });
      } catch (error) {
        onWarning?.call(error);
      }
    }
  }

  List<Map<String, Object>> _buildSubscriptionPayload() {
    return [
      {'ticket': 'trade-collector-${DateTime.now().microsecondsSinceEpoch}'},
      {
        'type': 'trade',
        'codes': _assets.map((asset) => asset.symbol).toList(growable: false),
        if (!includeSnapshot) 'is_only_realtime': true,
      },
      {'format': 'DEFAULT'},
    ];
  }

  Duration _nextReconnectDelay(Duration current) {
    final doubled = current.inSeconds * 2;
    if (doubled >= 30) {
      return const Duration(seconds: 30);
    }
    return Duration(seconds: doubled);
  }

  bool _shouldFlush() {
    return DateTime.now().toUtc().difference(_lastFlushAt) >= flushInterval;
  }

  Future<void> _flushBufferUnsafe() async {
    if (_buffer.isEmpty) {
      _lastFlushAt = DateTime.now().toUtc();
      return;
    }

    final pending = List<RawMarketTradeRow>.from(_buffer);
    final insertedCount = await _sink.insertTrades(pending);
    _buffer.removeRange(0, pending.length);
    _lastFlushAt = DateTime.now().toUtc();
    _persistedCount += insertedCount;
    onBatchPersisted?.call(insertedCount, _persistedCount);
  }

  Future<void> _runSerial(Future<void> Function() action) {
    final completer = Completer<void>();
    _serial = _serial.catchError((Object _) {}).then((_) async {
      try {
        await action();
        completer.complete();
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }
}

final class TrackedMarketAsset {
  const TrackedMarketAsset({
    required this.assetId,
    required this.symbol,
    required this.quoteAsset,
  });

  final String assetId;
  final String symbol;
  final String quoteAsset;
}

final class UpbitTradeMessageParser {
  const UpbitTradeMessageParser();

  List<RawMarketTradeRow> parse({
    required Object rawMessage,
    required String exchange,
    required String quoteAsset,
    required Map<String, TrackedMarketAsset> assetsBySymbol,
    required DateTime receivedAt,
  }) {
    final decoded = _decodeMessage(rawMessage);
    if (decoded is List<dynamic>) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .expand(
            (payload) => _parsePayload(
              payload: payload,
              exchange: exchange,
              quoteAsset: quoteAsset,
              assetsBySymbol: assetsBySymbol,
              receivedAt: receivedAt,
            ),
          )
          .toList(growable: false);
    }

    if (decoded is Map<String, dynamic>) {
      return _parsePayload(
        payload: decoded,
        exchange: exchange,
        quoteAsset: quoteAsset,
        assetsBySymbol: assetsBySymbol,
        receivedAt: receivedAt,
      );
    }

    return const [];
  }

  Object _decodeMessage(Object rawMessage) {
    if (rawMessage is String) {
      return jsonDecode(rawMessage);
    }
    if (rawMessage is List<int>) {
      return jsonDecode(utf8.decode(rawMessage));
    }
    throw FormatException(
      'Unsupported websocket payload type: ${rawMessage.runtimeType}',
    );
  }

  List<RawMarketTradeRow> _parsePayload({
    required Map<String, dynamic> payload,
    required String exchange,
    required String quoteAsset,
    required Map<String, TrackedMarketAsset> assetsBySymbol,
    required DateTime receivedAt,
  }) {
    if (payload['type'] != 'trade') {
      return const [];
    }

    final symbol = (payload['code'] as String?)?.toUpperCase();
    if (symbol == null) {
      throw const FormatException('Missing trade code in websocket payload.');
    }

    final asset = assetsBySymbol[symbol];
    if (asset == null) {
      return const [];
    }

    final tradeTimestampMs = _parsePositiveInt(payload['trade_timestamp']);
    final tradeTimestamp = DateTime.fromMillisecondsSinceEpoch(
      tradeTimestampMs,
      isUtc: true,
    );

    return [
      RawMarketTradeRow(
        exchange: exchange,
        assetId: asset.assetId,
        symbol: symbol,
        quoteAsset: asset.quoteAsset.isEmpty ? quoteAsset : asset.quoteAsset,
        tradeTimestamp: tradeTimestamp,
        tradeTimestampMs: tradeTimestampMs,
        sequentialId: _parsePositiveInt(payload['sequential_id']),
        tradePrice: Decimal.parse(payload['trade_price'].toString()),
        tradeVolume: Decimal.parse(payload['trade_volume'].toString()),
        askBid: (payload['ask_bid'] as String).toUpperCase(),
        bestAskPrice: _parseNullableDecimal(payload['best_ask_price']),
        bestAskSize: _parseNullableDecimal(payload['best_ask_size']),
        bestBidPrice: _parseNullableDecimal(payload['best_bid_price']),
        bestBidSize: _parseNullableDecimal(payload['best_bid_size']),
        streamType: (payload['stream_type'] as String).toUpperCase(),
        payloadJson: jsonEncode(payload),
        receivedAt: receivedAt,
      ),
    ];
  }

  int _parsePositiveInt(Object? value) {
    final parsed = switch (value) {
      int intValue => intValue,
      String stringValue => int.parse(stringValue),
      _ => throw FormatException('Expected integer value, received: $value'),
    };
    if (parsed <= 0) {
      throw FormatException(
        'Expected positive integer value, received: $value',
      );
    }
    return parsed;
  }

  Decimal? _parseNullableDecimal(Object? value) {
    if (value == null) {
      return null;
    }
    return Decimal.parse(value.toString());
  }
}

Future<List<ReplayAsset>> resolveTrackedUpbitAssets({
  required UpbitMarketCatalogClient catalogClient,
  required String exchange,
  required String quoteAsset,
  List<String>? symbols,
  int marketLimit = 20,
}) async {
  final marketList = await catalogClient.fetchMarkets(
    quoteAsset: quoteAsset,
    exchange: exchange,
  );
  final marketMap = {for (final asset in marketList) asset.symbol: asset};

  if (symbols == null || symbols.isEmpty) {
    return marketList.take(marketLimit).toList(growable: false);
  }

  return symbols
      .map((symbol) => catalogClient.normalizeSymbol(symbol, quoteAsset))
      .map((symbol) {
        final asset = marketMap[symbol];
        if (asset != null) {
          return asset;
        }

        final parts = symbol.split('-');
        final baseAsset = parts.length == 2 ? parts[1] : symbol;
        return ReplayAsset(
          symbol: symbol,
          baseAsset: baseAsset,
          quoteAsset: quoteAsset.toUpperCase(),
          displayName: baseAsset,
          exchange: exchange,
        );
      })
      .toList(growable: false);
}
