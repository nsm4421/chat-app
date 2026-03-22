import 'package:freezed_annotation/freezed_annotation.dart';

part 'cursor_pagination_event.freezed.dart';

@freezed
sealed class CursorPaginationEvent<T, Cursor>
    with _$CursorPaginationEvent<T, Cursor> {
  const factory CursorPaginationEvent.refreshRequested() =
      CursorPaginationRefreshRequested<T, Cursor>;

  const factory CursorPaginationEvent.fetchMoreRequested() =
      CursorPaginationFetchMoreRequested<T, Cursor>;

  const factory CursorPaginationEvent.itemUpdated(T item) =
      CursorPaginationItemUpdated<T, Cursor>;

  const factory CursorPaginationEvent.itemDeleted(T item) =
      CursorPaginationItemDeleted<T, Cursor>;
}
