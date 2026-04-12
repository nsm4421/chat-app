import 'package:decimal/decimal.dart';
import 'package:postgres/postgres.dart';

Future<Connection> openPostgresConnection(String connectionString) async {
  final uri = Uri.parse(connectionString);
  if (uri.scheme != 'postgres' && uri.scheme != 'postgresql') {
    throw ArgumentError('Unsupported database URL scheme: ${uri.scheme}');
  }

  final endpoint = Endpoint(
    host: uri.host.isEmpty ? 'localhost' : uri.host,
    port: uri.hasPort ? uri.port : 5432,
    database: uri.pathSegments.isEmpty ? 'postgres' : uri.pathSegments.first,
    username: uri.userInfo.isEmpty
        ? null
        : Uri.decodeComponent(uri.userInfo.split(':').first),
    password: uri.userInfo.contains(':')
        ? Uri.decodeComponent(uri.userInfo.split(':').skip(1).join(':'))
        : null,
  );

  final sslMode = switch (uri.queryParameters['sslmode']) {
    'disable' => SslMode.disable,
    'verify-ca' || 'verify-full' => SslMode.verifyFull,
    _ => SslMode.require,
  };

  return Connection.open(
    endpoint,
    settings: ConnectionSettings(sslMode: sslMode),
  );
}

String formatUtcDate(DateTime date) {
  final utc = date.toUtc();
  final month = utc.month.toString().padLeft(2, '0');
  final day = utc.day.toString().padLeft(2, '0');
  return '${utc.year}-$month-$day';
}

String decimalString(Decimal value) => value.toString();

String indexedPlaceholders(int count, {int startIndex = 1}) {
  return List.generate(count, (index) => '\$${index + startIndex}').join(', ');
}

Iterable<List<T>> chunk<T>(List<T> items, int size) sync* {
  for (var i = 0; i < items.length; i += size) {
    final end = (i + size < items.length) ? i + size : items.length;
    yield items.sublist(i, end);
  }
}
