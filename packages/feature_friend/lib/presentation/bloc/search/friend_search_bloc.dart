import 'package:shared/shared.dart';
import 'package:feature_friend/domain/use_case/friend_use_cases.dart';
import 'package:feature_friend/presentation/bloc/search/friend_search_event.dart';
import 'package:feature_friend/presentation/bloc/search/friend_search_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class FriendSearchBloc extends Bloc<FriendSearchEvent, FriendSearchState> {
  FriendSearchBloc(this._friendUseCases)
    : super(const FriendSearchState.idle()) {
    on<FriendSearchEvent>(_onEvent);
  }

  static const _defaultLimit = 20;

  final FriendUseCases _friendUseCases;

  void search(String query) {
    add(FriendSearchEvent.querySubmitted(query));
  }

  void clear() {
    add(const FriendSearchEvent.cleared());
  }

  Future<void> sendFriendRequest({
    required String receiverUserId,
    String? message,
  }) async {
    await _friendUseCases.sendFriendRequest(
      receiverUserId: receiverUserId,
      message: message,
    );
    add(FriendSearchEvent.requestMarkedPending(receiverUserId));
  }

  Future<void> _onEvent(
    FriendSearchEvent event,
    Emitter<FriendSearchState> emit,
  ) async {
    await event.map(
      querySubmitted: (event) async {
        final query = event.query.trim();
        if (query.isEmpty) {
          emit(const FriendSearchState.idle());
          return;
        }

        emit(FriendSearchState.loading(query: query));

        try {
          final items = await _friendUseCases.searchFriendProfiles(
            query: query,
            limit: _defaultLimit,
          );

          if (items.isEmpty) {
            emit(FriendSearchState.empty(query: query));
            return;
          }

          emit(FriendSearchState.success(query: query, items: items));
        } on Failure catch (error) {
          emit(FriendSearchState.failure(query: query, message: error.message));
        } catch (_) {
          emit(
            FriendSearchState.failure(
              query: query,
              message: '친구 검색을 처리하지 못했어요. 잠시 후 다시 시도해 주세요.',
            ),
          );
        }
      },
      cleared: (_) async {
        emit(const FriendSearchState.idle());
      },
      requestMarkedPending: (event) async {
        state.mapOrNull(
          success: (current) {
            final nextItems = current.items
                .map((item) {
                  if (item.profile.id != event.receiverUserId) {
                    return item;
                  }

                  return item.copyWith(hasPendingRequest: true);
                })
                .toList(growable: false);
            emit(
              FriendSearchState.success(query: current.query, items: nextItems),
            );
          },
        );
      },
    );
  }
}
