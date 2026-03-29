import 'package:feature_friend/domain/entity/friend_candidate.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_search_state.freezed.dart';

@freezed
sealed class FriendSearchState with _$FriendSearchState {
  const factory FriendSearchState.idle() = _Idle;
  const factory FriendSearchState.loading({required String query}) = _Loading;
  const factory FriendSearchState.empty({required String query}) = _Empty;
  const factory FriendSearchState.success({
    required String query,
    required List<FriendCandidate> items,
  }) = _Success;
  const factory FriendSearchState.failure({
    required String query,
    required String message,
  }) = _Failure;
}
