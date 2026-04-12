import 'dart:io';

import 'package:args/args.dart';
import 'package:market_replay_ingestor/market_replay_ingestor.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'database-url',
      help: 'Postgres connection string. Falls back to DATABASE_URL.',
    )
    ..addOption(
      'reference-date',
      mandatory: true,
      help: 'Replay reference date in YYYY-MM-DD.',
    )
    ..addOption(
      'source-market-date',
      help:
          'Override the historical market date to ingest. Defaults to reference-date - 1 day.',
    )
    ..addOption('exchange', defaultsTo: 'upbit')
    ..addOption('quote-asset', defaultsTo: 'SGD')
    ..addOption(
      'symbols',
      help:
          'Comma-separated market codes or base symbols. Example: SGD-BTC,SGD-ETH or BTC,ETH',
    )
    ..addOption('market-limit', defaultsTo: '20')
    ..addOption('minute-unit', defaultsTo: '1')
    ..addOption(
      'upbit-base-url',
      defaultsTo: 'https://sg-api.upbit.com',
      help:
          'Override Upbit quotation API base URL. Use https://api.upbit.com for KRW markets if needed.',
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

  final command = IngestReplayDayCommand(
    referenceDate: DateTime.parse(args['reference-date'] as String).toUtc(),
    sourceMarketDate:
        (args['source-market-date'] as String?)?.isNotEmpty == true
        ? DateTime.parse(args['source-market-date'] as String).toUtc()
        : null,
    exchange: (args['exchange'] as String).trim(),
    quoteAsset: (args['quote-asset'] as String).trim(),
    symbols: _parseSymbols(args['symbols'] as String?),
    marketLimit: int.parse(args['market-limit'] as String),
    minuteUnit: int.parse(args['minute-unit'] as String),
  );

  final sink = await PostgresReplayMarketSink.open(databaseUrl);
  final source = UpbitMarketReplaySource(
    baseUrl: (args['upbit-base-url'] as String).trim(),
  );

  try {
    final result = await IngestReplayDayUseCase(source, sink)(command);
    stdout.writeln('Replay day ingestion completed.');
    stdout.writeln('replay_day_id: ${result.replayDayId}');
    stdout.writeln('reference_date: ${result.referenceDate.toIso8601String()}');
    stdout.writeln(
      'source_market_date: ${result.sourceMarketDate.toIso8601String()}',
    );
    stdout.writeln('asset_count: ${result.assetCount}');
    stdout.writeln('tick_count: ${result.tickCount}');
    stdout.writeln('candle_count: ${result.candleCount}');
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
