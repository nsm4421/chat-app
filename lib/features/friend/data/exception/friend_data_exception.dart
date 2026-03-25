final class FriendDataException implements Exception {
  const FriendDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
