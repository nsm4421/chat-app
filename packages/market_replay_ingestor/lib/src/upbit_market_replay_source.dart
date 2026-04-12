import 'dart:convert';
import 'dart:io';

import 'package:decimal/decimal.dart';
import 'package:http/http.dart' as http;

import 'ingest_replay_day_command.dart';
import 'market_replay_models.dart';
import 'market_replay_source.dart';
import 'upbit_market_catalog_client.dart';

final class UpbitMarketReplaySource implements MarketReplaySource {
  UpbitMarketReplaySource({
    http.Client? client,
    String? baseUrl,
    Duration requestSpacing = const Duration(milliseconds: 120),
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? 'https://sg-api.upbit.com',
       _requestSpacing = requestSpacing,
       _catalogClient = UpbitMarketCatalogClient(
         client: client,
         baseUrl: baseUrl,
       );

  final http.Client _client;
  final String _baseUrl;
  final Duration _requestSpacing;
  final UpbitMarketCatalogClient _catalogClient;

  @override
  Future<SourceReplayDayBundle> fetchReplayDay(
    IngestReplayDayCommand command,
  ) async {
    final sourceMarketDate = command.resolveSourceMarketDate();
    final symbols = await _resolveSymbols(command);
    final assets = await _resolveAssets(command, symbols);

    final candles = <SourceMinuteCandle>[];
    final availableAssets = <ReplayAsset>[];
    for (final asset in assets) {
      final marketCandles = await _fetchMinuteCandlesForDay(
        market: asset.symbol,
        sourceMarketDate: sourceMarketDate,
        unit: command.minuteUnit,
      );
      if (marketCandles.isEmpty) {
        continue;
      }
      candles.addAll(marketCandles);
      availableAssets.add(asset);
      await Future<void>.delayed(_requestSpacing);
    }

    return SourceReplayDayBundle(
      referenceDate: command.referenceDate,
      sourceMarketDate: sourceMarketDate,
      exchange: command.exchange,
      quoteAsset: command.quoteAsset.toUpperCase(),
      assets: availableAssets,
      minuteCandles: candles,
    );
  }

  Future<List<String>> _resolveSymbols(IngestReplayDayCommand command) async {
    final explicitSymbols = command.symbols;
    if (explicitSymbols != null && explicitSymbols.isNotEmpty) {
      return explicitSymbols
          .map(
            (symbol) =>
                _catalogClient.normalizeSymbol(symbol, command.quoteAsset),
          )
          .toList(growable: false);
    }

    final markets = await _fetchMarkets(command.quoteAsset, command.exchange);
    return markets
        .take(command.marketLimit)
        .map((market) => market.symbol)
        .toList(growable: false);
  }

  Future<List<ReplayAsset>> _resolveAssets(
    IngestReplayDayCommand command,
    List<String> symbols,
  ) async {
    final marketMap = {
      for (final asset in await _fetchMarkets(
        command.quoteAsset,
        command.exchange,
      ))
        asset.symbol: asset,
    };

    return symbols
        .map((symbol) {
          final normalized = _catalogClient.normalizeSymbol(
            symbol,
            command.quoteAsset,
          );
          final fromApi = marketMap[normalized];
          if (fromApi != null) {
            return fromApi;
          }

          final parts = normalized.split('-');
          final baseAsset = parts.length == 2 ? parts[1] : normalized;
          return ReplayAsset(
            symbol: normalized,
            baseAsset: baseAsset,
            quoteAsset: command.quoteAsset.toUpperCase(),
            displayName: baseAsset,
            exchange: command.exchange,
          );
        })
        .toList(growable: false);
  }

  Future<List<ReplayAsset>> _fetchMarkets(String quoteAsset, String exchange) {
    return _catalogClient.fetchMarkets(
      quoteAsset: quoteAsset,
      exchange: exchange,
    );
  }

  Future<List<SourceMinuteCandle>> _fetchMinuteCandlesForDay({
    required String market,
    required DateTime sourceMarketDate,
    required int unit,
  }) async {
    final dayStart = DateTime.utc(
      sourceMarketDate.year,
      sourceMarketDate.month,
      sourceMarketDate.day,
    );
    final dayEnd = dayStart.add(const Duration(days: 1));
    var cursor = dayEnd;
    final candlesByTime = <DateTime, SourceMinuteCandle>{};

    while (true) {
      final response = await _getJson(
        '/v1/candles/minutes/$unit',
        queryParameters: {
          'market': market,
          'count': '200',
          'to': cursor.toIso8601String(),
        },
      );
      if (response.isEmpty) {
        break;
      }

      DateTime? oldest;
      for (final row in response) {
        final map = row as Map<String, dynamic>;
        final candleAt = _parseUpbitUtcDateTime(
          map['candle_date_time_utc'] as String,
        );
        if (candleAt.isBefore(dayStart)) {
          oldest ??= candleAt;
          continue;
        }
        if (!candleAt.isBefore(dayEnd)) {
          continue;
        }

        candlesByTime[candleAt] = SourceMinuteCandle(
          symbol: market,
          candleAt: candleAt,
          openPrice: Decimal.parse(map['opening_price'].toString()),
          highPrice: Decimal.parse(map['high_price'].toString()),
          lowPrice: Decimal.parse(map['low_price'].toString()),
          closePrice: Decimal.parse(map['trade_price'].toString()),
          volume: Decimal.parse(map['candle_acc_trade_volume'].toString()),
          quoteVolume: Decimal.parse(map['candle_acc_trade_price'].toString()),
        );
        oldest = candleAt;
      }

      if (oldest == null || !oldest.isAfter(dayStart)) {
        break;
      }
      cursor = oldest.subtract(const Duration(milliseconds: 1));
      await Future<void>.delayed(_requestSpacing);
    }

    final candles = candlesByTime.values.toList()
      ..sort((a, b) => a.candleAt.compareTo(b.candleAt));
    return candles;
  }

  Future<List<dynamic>> _getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParameters);
    final response = await _client.get(
      uri,
      headers: {HttpHeaders.acceptHeader: 'application/json'},
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'Upbit request failed (${response.statusCode}) for $uri: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List<dynamic>) {
      return decoded;
    }

    throw HttpException('Unexpected Upbit response format for $uri.');
  }

  DateTime _parseUpbitUtcDateTime(String raw) {
    final normalized = raw.endsWith('Z') ? raw : '${raw}Z';
    return DateTime.parse(normalized).toUtc();
  }
}
