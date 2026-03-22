final class ChatDataException implements Exception {
  const ChatDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
