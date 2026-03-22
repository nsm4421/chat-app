final class CursorPaginationPage<T, Cursor> {
  const CursorPaginationPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<T> items;
  final Cursor? nextCursor;
  final bool hasMore;
}
