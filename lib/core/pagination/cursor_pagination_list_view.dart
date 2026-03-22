import 'package:domodachi/core/pagination/cursor_pagination_bloc.dart';
import 'package:domodachi/core/pagination/cursor_pagination_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

typedef CursorPaginationItemBuilder<T> =
    Widget Function(BuildContext context, T item, int index);
typedef CursorPaginationErrorBuilder =
    Widget Function(BuildContext context, String message, VoidCallback retry);

class CursorPaginationListView<T, Cursor> extends StatefulWidget {
  const CursorPaginationListView({
    required this.bloc,
    required this.itemBuilder,
    super.key,
    this.padding = EdgeInsets.zero,
    this.controller,
    this.physics,
    this.fetchMoreThreshold = 240,
    this.autoInitialize = true,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
  });

  final CursorPaginationBloc<T, Cursor> bloc;
  final CursorPaginationItemBuilder<T> itemBuilder;
  final EdgeInsetsGeometry padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final double fetchMoreThreshold;
  final bool autoInitialize;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final CursorPaginationErrorBuilder? errorBuilder;

  @override
  State<CursorPaginationListView<T, Cursor>> createState() =>
      _CursorPaginationListViewState<T, Cursor>();
}

class _CursorPaginationListViewState<T, Cursor>
    extends State<CursorPaginationListView<T, Cursor>> {
  @override
  void initState() {
    super.initState();
    _initializeIfNeeded(widget.bloc);
  }

  @override
  void didUpdateWidget(
    covariant CursorPaginationListView<T, Cursor> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bloc != widget.bloc) {
      _initializeIfNeeded(widget.bloc);
    }
  }

  void _initializeIfNeeded(CursorPaginationBloc<T, Cursor> bloc) {
    if (!widget.autoInitialize || !bloc.state.isIdle) {
      return;
    }

    bloc.init();
  }

  Future<void> _handleRefresh() {
    if (widget.bloc.state.isLoading || widget.bloc.state.isRefreshing) {
      return widget.bloc.stream.firstWhere(
        (state) => !state.isLoading && !state.isRefreshing,
      );
    }

    final future = widget.bloc.stream.firstWhere(
      (state) => !state.isLoading && !state.isRefreshing,
    );
    widget.bloc.refresh();
    return future;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) {
      return false;
    }

    if ((notification.scrollDelta ?? 0) <= 0) {
      return false;
    }

    if (notification.metrics.extentAfter > widget.fetchMoreThreshold) {
      return false;
    }

    widget.bloc.fetchMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      CursorPaginationBloc<T, Cursor>,
      CursorPaginationState<T, Cursor>
    >(
      bloc: widget.bloc,
      builder: (context, state) {
        if (state.isLoading && !state.hasData) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure && !state.hasData) {
          return _buildErrorState(context, state);
        }

        if (!state.isLoading && state.items.isEmpty) {
          return widget.emptyBuilder?.call(context) ??
              const Center(child: Text('표시할 항목이 없어요.'));
        }

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: _handleScrollNotification,
            child: ListView.builder(
              controller: widget.controller,
              physics: _buildScrollPhysics(),
              padding: widget.padding,
              itemCount: state.items.length + (_showsFooter(state) ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < state.items.length) {
                  return widget.itemBuilder(context, state.items[index], index);
                }

                return _buildFooter(context, state);
              },
            ),
          ),
        );
      },
    );
  }

  ScrollPhysics _buildScrollPhysics() {
    return widget.physics == null
        ? const AlwaysScrollableScrollPhysics()
        : AlwaysScrollableScrollPhysics(parent: widget.physics);
  }

  bool _showsFooter(CursorPaginationState<T, Cursor> state) {
    return state.isLoadingMore || (state.isFailure && state.hasData);
  }

  Widget _buildFooter(
    BuildContext context,
    CursorPaginationState<T, Cursor> state,
  ) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final message = state.errorMessage ?? '목록을 불러오지 못했어요.';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: _buildInlineRetry(context, message),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    CursorPaginationState<T, Cursor> state,
  ) {
    final message = state.errorMessage ?? '목록을 불러오지 못했어요.';

    return widget.errorBuilder?.call(context, message, widget.bloc.refresh) ??
        Center(child: _buildInlineRetry(context, message));
  }

  Widget _buildInlineRetry(BuildContext context, String message) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: widget.bloc.refresh,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
