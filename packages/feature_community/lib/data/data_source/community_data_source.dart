import 'package:feature_community/data/model/feed_model.dart';

abstract interface class CommunityDataSource {
  Future<Iterable<FeedModel>> fetchFeeds({int limit = 20});

  Future<FeedModel> insertFeed({
    required String feedId,
    required String content,
  });

  Future<FeedModel> updateFeed({
    required String feedId,
    required String content,
  });

  Future<void> deleteFeed(String feedId);
}
