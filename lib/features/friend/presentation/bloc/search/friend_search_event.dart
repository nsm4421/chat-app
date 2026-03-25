import 'package:freezed_annotation/freezed_annotation.dart';

part 'friend_search_event.freezed.dart';

@freezed
sealed class FriendSearchEvent with _$FriendSearchEvent {
  const factory FriendSearchEvent.querySubmitted(String query) =
      _QuerySubmitted;
  const factory FriendSearchEvent.cleared() = _Cleared;
  const factory FriendSearchEvent.requestMarkedPending(String receiverUserId) =
      _RequestMarkedPending;
}
