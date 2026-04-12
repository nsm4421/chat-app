import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'market_replay_models.dart';

final class UpbitMarketCatalogClient {
  UpbitMarketCatalogClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? 'https://sg-api.upbit.com';

  final http.Client _client;
  final String _baseUrl;

  Future<List<ReplayAsset>> fetchMarkets({
    required String quoteAsset,
    String exchange = 'upbit',
  }) async {
    final response = await _getJson(
      '/v1/market/all',
      queryParameters: const {'isDetails': 'false'},
    );

    final desiredQuote = quoteAsset.toUpperCase();
    final markets = <ReplayAsset>[];
    for (final row in response) {
      final map = row as Map<String, dynamic>;
      final symbol = (map['market'] as String).toUpperCase();
      final parts = symbol.split('-');
      if (parts.length != 2 || parts.first != desiredQuote) {
        continue;
      }
      markets.add(
        ReplayAsset(
          symbol: symbol,
          baseAsset: parts[1],
          quoteAsset: parts[0],
          displayName: (map['english_name'] as String?) ?? parts[1],
          exchange: exchange,
        ),
      );
    }

    markets.sort((a, b) => a.symbol.compareTo(b.symbol));
    return markets;
  }

  String normalizeSymbol(String symbol, String quoteAsset) {
    final normalized = symbol.trim().toUpperCase();
    if (normalized.contains('-')) {
      return normalized;
    }
    return '${quoteAsset.toUpperCase()}-$normalized';
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
}
