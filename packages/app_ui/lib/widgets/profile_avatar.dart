import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.username,
    this.imageUrl,
    this.memoryImageBytes,
    this.radius = 24,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
  });

  final String? username;
  final String? imageUrl;
  final Uint8List? memoryImageBytes;
  final double radius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final resolvedBackgroundColor =
        backgroundColor ?? colorScheme.primaryContainer;
    final resolvedForegroundColor =
        foregroundColor ?? colorScheme.onPrimaryContainer;
    final initial = _resolveInitial(username);
    final diameter = radius * 2;

    if (memoryImageBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: resolvedBackgroundColor,
        backgroundImage: MemoryImage(memoryImageBytes!),
      );
    }

    if (imageUrl?.trim().isNotEmpty ?? false) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: resolvedBackgroundColor,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: imageUrl!.trim(),
            width: diameter,
            height: diameter,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => _FallbackAvatar(
              radius: radius,
              initial: initial,
              backgroundColor: resolvedBackgroundColor,
              foregroundColor: resolvedForegroundColor,
              textStyle: textStyle,
            ),
            placeholder: (_, __) => SizedBox(
              width: diameter,
              height: diameter,
              child: Center(
                child: SizedBox(
                  width: radius,
                  height: radius,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: resolvedForegroundColor.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return _FallbackAvatar(
      radius: radius,
      initial: initial,
      backgroundColor: resolvedBackgroundColor,
      foregroundColor: resolvedForegroundColor,
      textStyle: textStyle,
    );
  }

  String _resolveInitial(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return '?';
    }
    return normalized.characters.first.toUpperCase();
  }
}

class _FallbackAvatar extends StatelessWidget {
  const _FallbackAvatar({
    required this.radius,
    required this.initial,
    required this.backgroundColor,
    required this.foregroundColor,
    this.textStyle,
  });

  final double radius;
  final String initial;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      child: Text(
        initial,
        style: textStyle ??
            theme.textTheme.titleMedium?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
