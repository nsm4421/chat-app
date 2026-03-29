import 'package:shared/shared.dart';
import 'package:test/test.dart';

class _TestFailure extends Failure {
  const _TestFailure(super.message);
}

class _TestCursorPaginationBloc extends CursorPaginationBloc<int, int> {
  _TestCursorPaginationBloc({
    required Future<CursorPaginationPage<int, int>> Function(int? cursor)
    fetcher,
    this.fallbackMessage = 'fallback',
  }) : _fetcher = fetcher;

  final Future<CursorPaginationPage<int, int>> Function(int? cursor) _fetcher;
  final String fallbackMessage;
  final List<int?> requestedCursors = [];

  @override
  String get fallbackErrorMessage => fallbackMessage;

  @override
  Future<CursorPaginationPage<int, int>> fetchPage(int? cursor) {
    requestedCursors.add(cursor);
    return _fetcher(cursor);
  }
}

void main() {
  group('CursorPaginationBloc', () {
    test('refresh loads first page', () async {
      final bloc = _TestCursorPaginationBloc(
        fetcher: (_) async => const CursorPaginationPage(
          items: [1, 2],
          nextCursor: 2,
          hasMore: true,
        ),
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );

      bloc.refresh();
      await expectation;

      expect(bloc.requestedCursors, [null]);
      await bloc.close();
    });

    test('loadMore appends next page items', () async {
      final bloc = _TestCursorPaginationBloc(
        fetcher: (cursor) async {
          if (cursor == null) {
            return const CursorPaginationPage(
              items: [1, 2],
              nextCursor: 2,
              hasMore: true,
            );
          }

          return const CursorPaginationPage(
            items: [3, 4],
            nextCursor: null,
            hasMore: false,
          );
        },
      );

      final refreshExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );
      bloc.refresh();
      await refreshExpectation;

      final fetchMoreExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.loadingMore,
          ),
          const CursorPaginationState<int, int>(
            items: [1, 2, 3, 4],
            nextCursor: null,
            hasMore: false,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );

      bloc.fetchMore();
      await fetchMoreExpectation;

      expect(bloc.requestedCursors, [null, 2]);
      await bloc.close();
    });

    test('refresh keeps current items while refreshing', () async {
      var fetchCount = 0;
      final bloc = _TestCursorPaginationBloc(
        fetcher: (_) async {
          fetchCount += 1;
          if (fetchCount == 1) {
            return const CursorPaginationPage(
              items: [1, 2],
              nextCursor: 2,
              hasMore: true,
            );
          }

          return const CursorPaginationPage(
            items: [10, 20],
            nextCursor: 20,
            hasMore: true,
          );
        },
      );

      final firstRefreshExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );
      bloc.refresh();
      await firstRefreshExpectation;

      final secondRefreshExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.refreshing,
          ),
          const CursorPaginationState<int, int>(
            items: [10, 20],
            nextCursor: 20,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );

      bloc.refresh();
      await secondRefreshExpectation;
      await bloc.close();
    });

    test('loadMore failure keeps items and exposes failure message', () async {
      final bloc = _TestCursorPaginationBloc(
        fetcher: (cursor) async {
          if (cursor == null) {
            return const CursorPaginationPage(
              items: [1, 2],
              nextCursor: 2,
              hasMore: true,
            );
          }

          throw const _TestFailure('failed');
        },
      );

      final refreshExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );
      bloc.refresh();
      await refreshExpectation;

      final fetchMoreExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.loadingMore,
          ),
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.failure,
            errorMessage: 'failed',
          ),
        ]),
      );

      bloc.fetchMore();
      await fetchMoreExpectation;
      await bloc.close();
    });

    test('fetchMore does nothing when hasMore is false', () async {
      final bloc = _TestCursorPaginationBloc(
        fetcher: (_) async => const CursorPaginationPage(
          items: [1, 2],
          nextCursor: null,
          hasMore: false,
        ),
      );

      final refreshExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<int, int>(
            items: [1, 2],
            nextCursor: null,
            hasMore: false,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );
      bloc.refresh();
      await refreshExpectation;
      bloc.fetchMore();

      expect(bloc.requestedCursors, [null]);
      expect(bloc.state.items, [1, 2]);
      expect(bloc.state.hasMore, isFalse);
      await bloc.close();
    });

    test('uses fallback message for unexpected errors', () async {
      final bloc = _TestCursorPaginationBloc(
        fetcher: (_) async => throw Exception('boom'),
        fallbackMessage: 'custom fallback',
      );

      final expectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<int, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<int, int>(
            status: CursorPaginationStatus.failure,
            errorMessage: 'custom fallback',
          ),
        ]),
      );

      bloc.refresh();
      await expectation;
      await bloc.close();
    });

    test('itemUpdated replaces matching item', () async {
      final bloc = _IdentityCursorPaginationBloc(
        fetcher: (_) async => const CursorPaginationPage(
          items: [
            _TestItem(id: 1, label: 'a'),
            _TestItem(id: 2, label: 'b'),
            _TestItem(id: 3, label: 'c'),
          ],
          nextCursor: 3,
          hasMore: true,
        ),
      );

      final refreshExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<_TestItem, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<_TestItem, int>(
            items: [
              _TestItem(id: 1, label: 'a'),
              _TestItem(id: 2, label: 'b'),
              _TestItem(id: 3, label: 'c'),
            ],
            nextCursor: 3,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );
      bloc.refresh();
      await refreshExpectation;

      final updateExpectation = expectLater(
        bloc.stream,
        emits(
          const CursorPaginationState<_TestItem, int>(
            items: [
              _TestItem(id: 1, label: 'a'),
              _TestItem(id: 2, label: 'updated'),
              _TestItem(id: 3, label: 'c'),
            ],
            nextCursor: 3,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ),
      );

      bloc.itemUpdated(const _TestItem(id: 2, label: 'updated'));
      await updateExpectation;
      await bloc.close();
    });

    test('itemDeleted removes matching item', () async {
      final bloc = _IdentityCursorPaginationBloc(
        fetcher: (_) async => const CursorPaginationPage(
          items: [
            _TestItem(id: 1, label: 'a'),
            _TestItem(id: 2, label: 'b'),
          ],
          nextCursor: 2,
          hasMore: true,
        ),
      );

      final refreshExpectation = expectLater(
        bloc.stream,
        emitsInOrder([
          const CursorPaginationState<_TestItem, int>(
            status: CursorPaginationStatus.loading,
          ),
          const CursorPaginationState<_TestItem, int>(
            items: [
              _TestItem(id: 1, label: 'a'),
              _TestItem(id: 2, label: 'b'),
            ],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ]),
      );
      bloc.refresh();
      await refreshExpectation;

      final deleteExpectation = expectLater(
        bloc.stream,
        emits(
          const CursorPaginationState<_TestItem, int>(
            items: [_TestItem(id: 1, label: 'a')],
            nextCursor: 2,
            hasMore: true,
            status: CursorPaginationStatus.success,
          ),
        ),
      );

      bloc.itemDeleted(const _TestItem(id: 2, label: 'ignored'));
      await deleteExpectation;
      await bloc.close();
    });
  });
}

class _IdentityCursorPaginationBloc
    extends CursorPaginationBloc<_TestItem, int> {
  _IdentityCursorPaginationBloc({
    required Future<CursorPaginationPage<_TestItem, int>> Function(int? cursor)
    fetcher,
  }) : _fetcher = fetcher;

  final Future<CursorPaginationPage<_TestItem, int>> Function(int? cursor)
  _fetcher;

  @override
  Future<CursorPaginationPage<_TestItem, int>> fetchPage(int? cursor) {
    return _fetcher(cursor);
  }

  @override
  bool isSameItem(_TestItem item, _TestItem other) => item.id == other.id;
}

final class _TestItem {
  const _TestItem({required this.id, required this.label});

  final int id;
  final String label;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is _TestItem && other.id == id && other.label == label;
  }

  @override
  int get hashCode => Object.hash(id, label);
}
