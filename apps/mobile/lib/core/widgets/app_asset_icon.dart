import 'package:flutter/material.dart';
import 'package:app_ui/app_ui.dart';

import 'package:domodachi/core/widgets/app_asset_path.dart';

enum AppAssetIconKind {
  /// Members / participants list entry points.
  members,

  /// Direct message entry points.
  dm,

  /// Group chat / lounge entry points.
  group,

  /// Friend request actions.
  friendAdd,

  /// Chat message like actions.
  like,
}

extension on AppAssetIconKind {
  AppAssetPath assetPath(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return switch (this) {
      AppAssetIconKind.members =>
        isDark ? AppAssetPath.membersDark : AppAssetPath.membersLight,
      AppAssetIconKind.dm =>
        isDark ? AppAssetPath.dmDark : AppAssetPath.dmLight,
      AppAssetIconKind.group =>
        isDark ? AppAssetPath.groupDark : AppAssetPath.groupLight,
      AppAssetIconKind.friendAdd =>
        isDark ? AppAssetPath.friendAddDark : AppAssetPath.friendAddLight,
      AppAssetIconKind.like =>
        isDark ? AppAssetPath.likeDark : AppAssetPath.likeLight,
    };
  }
}

class AppAssetIcon extends StatelessWidget {
  const AppAssetIcon({
    super.key,
    required this.kind,
    this.size = 24,
    this.semanticLabel,
  });

  final AppAssetIconKind kind;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final lightAssetPath = kind.assetPath(Brightness.light).value;
    final darkAssetPath = kind.assetPath(Brightness.dark).value;

    return SvgAssetIcon(
      assetPath: lightAssetPath,
      darkAssetPath: darkAssetPath,
      size: size,
      semanticLabel: semanticLabel,
    );
  }
}
