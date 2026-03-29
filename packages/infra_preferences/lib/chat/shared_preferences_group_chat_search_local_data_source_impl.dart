import 'package:feature_chat_core/chat_core/data/data_source/local/group_chat_search_local_data_source.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@LazySingleton(as: GroupChatSearchLocalDataSource)
class SharedPreferencesGroupChatSearchLocalDataSourceImpl
    implements GroupChatSearchLocalDataSource {
  SharedPreferencesGroupChatSearchLocalDataSourceImpl(this._sharedPreferences);

  static const _recentSearchesKey = 'group_chat_recent_searches';
  static const _maxRecentQueries = 6;

  final SharedPreferences _sharedPreferences;

  @override
  Future<List<String>> fetchRecentQueries() async {
    final stored = _sharedPreferences.getStringList(_recentSearchesKey);
    if (stored == null) {
      return const <String>[];
    }

    return stored
        .where((query) => query.trim().isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> saveRecentQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return;
    }

    final current = await fetchRecentQueries();
    final normalized = trimmed.toLowerCase();
    final next = <String>[
      trimmed,
      ...current.where((item) => item.toLowerCase() != normalized),
    ];

    await _sharedPreferences.setStringList(
      _recentSearchesKey,
      next.take(_maxRecentQueries).toList(growable: false),
    );
  }

  @override
  Future<void> deleteRecentQuery(String query) async {
    final normalized = query.trim().toLowerCase();
    final current = await fetchRecentQueries();
    final next = current
        .where((item) => item.toLowerCase() != normalized)
        .toList(growable: false);

    await _sharedPreferences.setStringList(_recentSearchesKey, next);
  }
}
