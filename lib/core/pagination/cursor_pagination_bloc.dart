import 'package:domodachi/core/error/failure.dart';
import 'package:domodachi/core/pagination/cursor_pagination_event.dart';
import 'package:domodachi/core/pagination/cursor_pagination_page.dart';
import 'package:domodachi/core/pagination/cursor_pagination_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CursorPaginationBloc<T, Cursor>
    extends
        Bloc<
          CursorPaginationEvent<T, Cursor>,
          CursorPaginationState<T, Cursor>
        > {
  CursorPaginationBloc() : super(CursorPaginationState<T, Cursor>()) {
    on<CursorPaginationRefreshRequested<T, Cursor>>(_onRefreshRequested);
    on<CursorPaginationFetchMoreRequested<T, Cursor>>(_onFetchMoreRequested);
    on<CursorPaginationItemUpdated<T, Cursor>>(_onItemUpdated);
    on<CursorPaginationItemDeleted<T, Cursor>>(_onItemDeleted);
  }

  @protected
  Future<CursorPaginationPage<T, Cursor>> fetchPage(Cursor? cursor);

  @protected
  String get fallbackErrorMessage => '목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';

  @protected
  bool isSameItem(T item, T other) => item == other;

  void init() => refresh();

  void refresh() {
    add(const CursorPaginationEvent.refreshRequested());
  }

  void fetchMore() {
    add(const CursorPaginationEvent.fetchMoreRequested());
  }

  void itemUpdated(T item) {
    add(CursorPaginationEvent.itemUpdated(item));
  }

  void itemDeleted(T item) {
    add(CursorPaginationEvent.itemDeleted(item));
  }

  @protected
  List<T> reduceUpdatedItem(List<T> items, T updatedItem) {
    return items
        .map((item) => isSameItem(item, updatedItem) ? updatedItem : item)
        .toList(growable: false);
  }

  @protected
  List<T> reduceDeletedItem(List<T> items, T deletedItem) {
    return items
        .where((item) => !isSameItem(item, deletedItem))
        .toList(growable: false);
  }

  Future<void> _onRefreshRequested(
    CursorPaginationRefreshRequested<T, Cursor> event,
    Emitter<CursorPaginationState<T, Cursor>> emit,
  ) async {
    if (state.isLoading || state.isRefreshing) {
      return;
    }

    final previousState = state;
    emit(
      previousState.copyWith(
        status: previousState.hasData
            ? CursorPaginationStatus.refreshing
            : CursorPaginationStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final page = await fetchPage(null);
      emit(_toSuccessState(page));
    } on Failure catch (error) {
      emit(_toFailureState(previousState, error.message));
    } catch (_) {
      emit(_toFailureState(previousState, fallbackErrorMessage));
    }
  }

  Future<void> _onFetchMoreRequested(
    CursorPaginationFetchMoreRequested<T, Cursor> event,
    Emitter<CursorPaginationState<T, Cursor>> emit,
  ) async {
    if (state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final previousState = state;
    emit(
      previousState.copyWith(
        status: CursorPaginationStatus.loadingMore,
        errorMessage: null,
      ),
    );

    try {
      final page = await fetchPage(previousState.nextCursor);
      emit(
        CursorPaginationState<T, Cursor>(
          items: [...previousState.items, ...page.items],
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          status: CursorPaginationStatus.success,
        ),
      );
    } on Failure catch (error) {
      emit(_toFailureState(previousState, error.message));
    } catch (_) {
      emit(_toFailureState(previousState, fallbackErrorMessage));
    }
  }

  void _onItemUpdated(
    CursorPaginationItemUpdated<T, Cursor> event,
    Emitter<CursorPaginationState<T, Cursor>> emit,
  ) {
    final nextItems = reduceUpdatedItem(state.items, event.item);
    if (listEquals(nextItems, state.items)) {
      return;
    }

    emit(state.copyWith(items: nextItems));
  }

  void _onItemDeleted(
    CursorPaginationItemDeleted<T, Cursor> event,
    Emitter<CursorPaginationState<T, Cursor>> emit,
  ) {
    final nextItems = reduceDeletedItem(state.items, event.item);
    if (listEquals(nextItems, state.items)) {
      return;
    }

    emit(state.copyWith(items: nextItems));
  }

  CursorPaginationState<T, Cursor> _toSuccessState(
    CursorPaginationPage<T, Cursor> page,
  ) {
    return CursorPaginationState<T, Cursor>(
      items: page.items,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      status: CursorPaginationStatus.success,
    );
  }

  CursorPaginationState<T, Cursor> _toFailureState(
    CursorPaginationState<T, Cursor> previousState,
    String message,
  ) {
    return previousState.copyWith(
      status: CursorPaginationStatus.failure,
      errorMessage: message,
    );
  }
}
