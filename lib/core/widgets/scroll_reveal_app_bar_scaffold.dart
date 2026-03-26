import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ScrollRevealAppBarScaffold extends StatefulWidget {
  const ScrollRevealAppBarScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottom,
    this.floatingActionButton,
    this.backgroundColor,
    this.appBarBackgroundColor,
    this.surfaceTintColor,
    this.toolbarHeight,
    this.centerTitle,
    this.automaticallyImplyLeading = true,
    this.notificationPredicate = defaultScrollNotificationPredicate,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
  });

  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Color? appBarBackgroundColor;
  final Color? surfaceTintColor;
  final double? toolbarHeight;
  final bool? centerTitle;
  final bool automaticallyImplyLeading;
  final ScrollNotificationPredicate notificationPredicate;
  final Duration duration;
  final Curve curve;

  @override
  State<ScrollRevealAppBarScaffold> createState() =>
      _ScrollRevealAppBarScaffoldState();
}

class _ScrollRevealAppBarScaffoldState
    extends State<ScrollRevealAppBarScaffold> {
  var _isAppBarVisible = true;

  bool _handleScrollNotification(ScrollNotification notification) {
    if (!widget.notificationPredicate(notification)) {
      return false;
    }

    final metrics = notification.metrics;
    if (metrics.axis != Axis.vertical) {
      return false;
    }

    if (metrics.pixels <= 0) {
      _setAppBarVisibility(true);
      return false;
    }

    if (notification is UserScrollNotification) {
      switch (notification.direction) {
        case ScrollDirection.forward:
          _setAppBarVisibility(true);
        case ScrollDirection.reverse:
          _setAppBarVisibility(false);
        case ScrollDirection.idle:
          break;
      }
    }

    return false;
  }

  void _setAppBarVisibility(bool isVisible) {
    if (_isAppBarVisible == isVisible) {
      return;
    }

    setState(() {
      _isAppBarVisible = isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final toolbarHeight = widget.toolbarHeight ?? kToolbarHeight;
    final bottomHeight = widget.bottom?.preferredSize.height ?? 0;
    final totalHeight = toolbarHeight + bottomHeight;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: _AnimatedAppBarContainer(
        isVisible: _isAppBarVisible,
        expandedHeight: totalHeight,
        duration: widget.duration,
        curve: widget.curve,
        child: AppBar(
          title: widget.title,
          actions: widget.actions,
          bottom: widget.bottom,
          backgroundColor: widget.appBarBackgroundColor,
          surfaceTintColor: widget.surfaceTintColor,
          toolbarHeight: toolbarHeight,
          centerTitle: widget.centerTitle,
          automaticallyImplyLeading: widget.automaticallyImplyLeading,
        ),
      ),
      floatingActionButton: widget.floatingActionButton,
      body: NotificationListener<ScrollNotification>(
        onNotification: _handleScrollNotification,
        child: widget.body,
      ),
    );
  }
}

class _AnimatedAppBarContainer extends StatelessWidget
    implements PreferredSizeWidget {
  const _AnimatedAppBarContainer({
    required this.isVisible,
    required this.expandedHeight,
    required this.duration,
    required this.curve,
    required this.child,
  });

  final bool isVisible;
  final double expandedHeight;
  final Duration duration;
  final Curve curve;
  final PreferredSizeWidget child;

  @override
  Size get preferredSize =>
      Size.fromHeight(isVisible ? expandedHeight : 0);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      height: isVisible ? expandedHeight : 0,
      child: ClipRect(
        child: SizedBox(
          height: expandedHeight,
          child: child,
        ),
      ),
    );
  }
}
