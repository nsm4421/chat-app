import 'package:hive_ce_flutter/hive_flutter.dart';

import 'hive_box_name.dart';

abstract final class HiveInitializer {
  static Future<HiveInterface> initialize() async {
    await Hive.initFlutter('domodachi_cache');

    await _openBoxIfNeeded<dynamic>(HiveBoxName.appCache);
    await _openBoxIfNeeded<dynamic>(HiveBoxName.discoverCache);
    await _openBoxIfNeeded<dynamic>(HiveBoxName.chatCache);

    return Hive;
  }

  static Future<void> _openBoxIfNeeded<T>(String name) async {
    if (Hive.isBoxOpen(name)) {
      return;
    }

    await Hive.openBox<T>(name);
  }
}
