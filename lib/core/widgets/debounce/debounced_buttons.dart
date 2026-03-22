import 'dart:async';

import 'package:domodachi/core/debounce/debouncer.dart';
import 'package:flutter/material.dart';

typedef DebouncedButtonCallback = FutureOr<void> Function();

class DebouncedFilledButton extends StatelessWidget {
  const DebouncedFilledButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final DebouncedButtonCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _DebouncedButton(
      duration: duration,
      onPressed: onPressed,
      builder: (onPressed) =>
          FilledButton(onPressed: onPressed, style: style, child: child),
    );
  }
}

class DebouncedFilledButtonIcon extends StatelessWidget {
  const DebouncedFilledButtonIcon({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final DebouncedButtonCallback? onPressed;
  final Widget icon;
  final Widget label;
  final ButtonStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _DebouncedButton(
      duration: duration,
      onPressed: onPressed,
      builder: (onPressed) => FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
        style: style,
      ),
    );
  }
}

class DebouncedFilledTonalButton extends StatelessWidget {
  const DebouncedFilledTonalButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final DebouncedButtonCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _DebouncedButton(
      duration: duration,
      onPressed: onPressed,
      builder: (onPressed) =>
          FilledButton.tonal(onPressed: onPressed, style: style, child: child),
    );
  }
}

class DebouncedOutlinedButton extends StatelessWidget {
  const DebouncedOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final DebouncedButtonCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _DebouncedButton(
      duration: duration,
      onPressed: onPressed,
      builder: (onPressed) =>
          OutlinedButton(onPressed: onPressed, style: style, child: child),
    );
  }
}

class DebouncedTextButton extends StatelessWidget {
  const DebouncedTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.duration = const Duration(milliseconds: 300),
  });

  final DebouncedButtonCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _DebouncedButton(
      duration: duration,
      onPressed: onPressed,
      builder: (onPressed) =>
          TextButton(onPressed: onPressed, style: style, child: child),
    );
  }
}

class DebouncedIconButton extends StatelessWidget {
  const DebouncedIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.style,
    this.tooltip,
    this.duration = const Duration(milliseconds: 300),
  });

  final DebouncedButtonCallback? onPressed;
  final Widget icon;
  final ButtonStyle? style;
  final String? tooltip;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return _DebouncedButton(
      duration: duration,
      onPressed: onPressed,
      builder: (onPressed) => IconButton(
        onPressed: onPressed,
        style: style,
        tooltip: tooltip,
        icon: icon,
      ),
    );
  }
}

class _DebouncedButton extends StatefulWidget {
  const _DebouncedButton({
    required this.onPressed,
    required this.builder,
    required this.duration,
  });

  final DebouncedButtonCallback? onPressed;
  final Widget Function(VoidCallback? onPressed) builder;
  final Duration duration;

  @override
  State<_DebouncedButton> createState() => _DebouncedButtonState();
}

class _DebouncedButtonState extends State<_DebouncedButton> {
  late final Debouncer _debouncer = Debouncer(
    duration: widget.duration,
    leading: true,
  );

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _handlePressed() {
    final onPressed = widget.onPressed;
    if (onPressed == null) {
      return;
    }

    _debouncer.run(onPressed);
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(widget.onPressed == null ? null : _handlePressed);
  }
}
