final class AuthDataException implements Exception {
  const AuthDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
