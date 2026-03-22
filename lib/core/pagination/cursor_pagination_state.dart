import 'package:freezed_annotation/freezed_annotation.dart';

part 'cursor_pagination_state.freezed.dart';

enum CursorPaginationStatus {
  idle,
  loading,
  success,
  refreshing,
  loadingMore,
  failure,
}

@freezed
class CursorPaginationState<T, Cursor> with _$CursorPaginationState<T, Cursor> {
  const CursorPaginationState({
    this.items = const [],
    this.nextCursor,
    this.hasMore = true,
    this.status = CursorPaginationStatus.idle,
    this.errorMessage,
  });

  @override
  final List<T> items;

  @override
  final Cursor? nextCursor;

  @override
  final bool hasMore;

  @override
  final CursorPaginationStatus status;

  @override
  final String? errorMessage;
}

extension CursorPaginationStateX<T, Cursor>
    on CursorPaginationState<T, Cursor> {
  bool get isIdle => status == CursorPaginationStatus.idle;
  bool get isLoading => status == CursorPaginationStatus.loading;
  bool get isRefreshing => status == CursorPaginationStatus.refreshing;
  bool get isLoadingMore => status == CursorPaginationStatus.loadingMore;
  bool get isSuccess => status == CursorPaginationStatus.success;
  bool get isFailure => status == CursorPaginationStatus.failure;
  bool get hasData => items.isNotEmpty;
}
