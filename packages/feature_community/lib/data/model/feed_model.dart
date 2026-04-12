final class FeedModel {
  final String id;
  final String content;
  final DateTime createdAt;
  final String createdBy;

  FeedModel({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.createdBy,
  });
}
