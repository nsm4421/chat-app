import 'package:domodachi/core/pagination/cursor_pagination_list_view.dart';
import 'package:shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestCursorPaginationBloc extends CursorPaginationBloc<int, int> {
  _TestCursorPaginationBloc({
    required Future<CursorPaginationPage<int, int>> Function(int? cursor)
    fetcher,
  }) : _fetcher = fetcher;

  final Future<CursorPaginationPage<int, int>> Function(int? cursor) _fetcher;
  final List<int?> requestedCursors = [];

  @override
  Future<CursorPaginationPage<int, int>> fetchPage(int? cursor) {
    requestedCursors.add(cursor);
    return _fetcher(cursor);
  }
}

void main() {
  group('CursorPaginationListView', () {
    testWidgets('loads initial items from bloc on first build', (tester) async {
      final bloc = _TestCursorPaginationBloc(
        fetcher: (_) async => const CursorPaginationPage(
          items: [1, 2, 3],
          nextCursor: 3,
          hasMore: true,
        ),
      );

      await tester.pumpWidget(_buildTestApp(bloc));
      await tester.pumpAndSettle();

      expect(find.text('item 1'), findsOneWidget);
      expect(find.text('item 3'), findsOneWidget);
      expect(bloc.requestedCursors, [null]);
    });

    testWidgets('fetches more when scrolled near the bottom', (tester) async {
      final bloc = _TestCursorPaginationBloc(
        fetcher: (cursor) async {
          if (cursor == null) {
            return CursorPaginationPage(
              items: List<int>.generate(20, (index) => index + 1),
              nextCursor: 20,
              hasMore: true,
            );
          }

          return CursorPaginationPage(
            items: List<int>.generate(10, (index) => index + 21),
            nextCursor: null,
            hasMore: false,
          );
        },
      );

      await tester.pumpWidget(_buildTestApp(bloc));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(ListView), const Offset(0, -2200));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(bloc.requestedCursors, [null, 20]);
      expect(bloc.state.items.length, 30);
      expect(bloc.state.items.last, 30);
    });

    testWidgets('refreshes when pulled down', (tester) async {
      var refreshCount = 0;
      final bloc = _TestCursorPaginationBloc(
        fetcher: (_) async {
          refreshCount += 1;

          if (refreshCount == 1) {
            return const CursorPaginationPage(
              items: [1, 2, 3],
              nextCursor: 3,
              hasMore: true,
            );
          }

          return const CursorPaginationPage(
            items: [101, 102, 103],
            nextCursor: 103,
            hasMore: true,
          );
        },
      );

      await tester.pumpWidget(_buildTestApp(bloc));
      await tester.pumpAndSettle();

      await tester.fling(find.byType(ListView), const Offset(0, 320), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.text('item 101'), findsOneWidget);
      expect(bloc.requestedCursors, [null, null]);
    });
  });
}

Widget _buildTestApp(_TestCursorPaginationBloc bloc) {
  return MaterialApp(
    home: Scaffold(
      body: CursorPaginationListView<int, int>(
        bloc: bloc,
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemBuilder: (context, item, index) {
          return SizedBox(
            height: 120,
            child: Center(child: Text('item $item')),
          );
        },
      ),
    ),
  );
}
