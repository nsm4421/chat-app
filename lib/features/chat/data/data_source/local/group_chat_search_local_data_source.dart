abstract interface class GroupChatSearchLocalDataSource {
  Future<List<String>> fetchRecentQueries();

  Future<void> saveRecentQuery(String query);

  Future<void> deleteRecentQuery(String query);
}
