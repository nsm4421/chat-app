final class ProfileDataException implements Exception {
  const ProfileDataException(this.message);

  final String message;

  @override
  String toString() => message;
}
