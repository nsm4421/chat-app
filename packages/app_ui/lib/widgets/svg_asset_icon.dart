import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SvgAssetIcon extends StatelessWidget {
  const SvgAssetIcon({
    super.key,
    required this.assetPath,
    this.darkAssetPath,
    this.size = 24,
    this.semanticLabel,
    this.package,
  });

  final String assetPath;
  final String? darkAssetPath;
  final double size;
  final String? semanticLabel;
  final String? package;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final resolvedAssetPath = brightness == Brightness.dark
        ? (darkAssetPath ?? assetPath)
        : assetPath;

    return SvgPicture.asset(
      resolvedAssetPath,
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      package: package,
    );
  }
}
