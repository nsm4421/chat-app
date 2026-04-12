import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:market_replay_ingestor/market_replay_ingestor.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'database-url',
      help: 'Postgres connection string. Falls back to DATABASE_URL.',
    )
    ..addOption('exchange', defaultsTo: 'upbit')
    ..addOption('quote-asset', defaultsTo: 'SGD')
    ..addOption(
      'symbols',
      help:
          'Comma-separated market codes or base symbols. Example: SGD-BTC,SGD-ETH or BTC,ETH',
    )
    ..addOption('market-limit', defaultsTo: '20')
    ..addOption(
      'upbit-base-url',
      defaultsTo: 'https://sg-api.upbit.com',
      help: 'REST base URL for market catalog lookup.',
    )
    ..addOption(
      'upbit-websocket-url',
      defaultsTo: 'wss://sg-api.upbit.com/websocket/v1',
      help: 'Public quotation websocket URL.',
    )
    ..addOption('batch-size', defaultsTo: '200')
    ..addOption('flush-interval-ms', defaultsTo: '1000')
    ..addOption('ping-interval-seconds', defaultsTo: '30')
    ..addFlag(
      'include-snapshot',
      negatable: false,
      help: 'Persist both initial snapshot and realtime events.',
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  final args = parser.parse(arguments);
  if (args['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  final databaseUrl =
      (args['database-url'] as String?)?.trim().isNotEmpty == true
      ? (args['database-url'] as String).trim()
      : Platform.environment['DATABASE_URL'];
  if (databaseUrl == null || databaseUrl.isEmpty) {
    stderr.writeln('DATABASE_URL is required.');
    exitCode = 64;
    return;
  }

  final exchange = (args['exchange'] as String).trim();
  final quoteAsset = (args['quote-asset'] as String).trim().toUpperCase();
  final catalogClient = UpbitMarketCatalogClient(
    baseUrl: (args['upbit-base-url'] as String).trim(),
  );
  final sink = await PostgresRawMarketTradeSink.open(databaseUrl);

  try {
    final assets = await resolveTrackedUpbitAssets(
      catalogClient: catalogClient,
      exchange: exchange,
      quoteAsset: quoteAsset,
      symbols: _parseSymbols(args['symbols'] as String?),
      marketLimit: int.parse(args['market-limit'] as String),
    );
    final assetIds = await sink.upsertAssets(assets);
    final trackedAssets = assets
        .map(
          (asset) => TrackedMarketAsset(
            assetId: assetIds[asset.symbol]!,
            symbol: asset.symbol,
            quoteAsset: asset.quoteAsset,
          ),
        )
        .toList(growable: false);

    final collector = UpbitTradeWebSocketCollector(
      sink: sink,
      websocketUrl: (args['upbit-websocket-url'] as String).trim(),
      exchange: exchange,
      quoteAsset: quoteAsset,
      assets: trackedAssets,
      batchSize: int.parse(args['batch-size'] as String),
      flushInterval: Duration(
        milliseconds: int.parse(args['flush-interval-ms'] as String),
      ),
      pingInterval: Duration(
        seconds: int.parse(args['ping-interval-seconds'] as String),
      ),
      includeSnapshot: args['include-snapshot'] as bool,
      onBatchPersisted: (insertedCount, totalInsertedCount) {
        stdout.writeln(
          '[collector] persisted=$insertedCount total=$totalInsertedCount symbols=${trackedAssets.length}',
        );
      },
      onWarning: (error) {
        stderr.writeln('[collector] warning: $error');
      },
    );

    final signalSubscriptions = <StreamSubscription<ProcessSignal>>[];
    try {
      signalSubscriptions.add(
        ProcessSignal.sigint.watch().listen((_) async {
          await collector.close();
        }),
      );
      signalSubscriptions.add(
        ProcessSignal.sigterm.watch().listen((_) async {
          await collector.close();
        }),
      );

      stdout.writeln(
        'Collecting raw trade events for ${trackedAssets.map((asset) => asset.symbol).join(', ')}',
      );
      stdout.writeln(
        'websocket: ${(args["upbit-websocket-url"] as String).trim()}',
      );
      await collector.run();
    } finally {
      for (final subscription in signalSubscriptions) {
        await subscription.cancel();
      }
    }
  } finally {
    await sink.close();
  }
}

List<String>? _parseSymbols(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }

  return raw
      .split(',')
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);
}
