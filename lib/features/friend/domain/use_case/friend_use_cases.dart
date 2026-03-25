import 'package:domodachi/features/friend/domain/repository/friend_repository.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/accept_friend_request_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/cancel_friend_request_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/decline_friend_request_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/fetch_friends_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/fetch_received_friend_requests_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/fetch_sent_friend_requests_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/remove_friend_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/search_friend_profiles_use_case.dart';
import 'package:domodachi/features/friend/domain/use_case/scenario/send_friend_request_use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class FriendUseCases {
  FriendUseCases(this._repository);

  final FriendRepository _repository;

  late final FetchFriendsUseCase _fetchFriends = FetchFriendsUseCase(
    _repository,
  );
  late final FetchReceivedFriendRequestsUseCase _fetchReceivedFriendRequests =
      FetchReceivedFriendRequestsUseCase(_repository);
  late final FetchSentFriendRequestsUseCase _fetchSentFriendRequests =
      FetchSentFriendRequestsUseCase(_repository);
  late final SearchFriendProfilesUseCase _searchFriendProfiles =
      SearchFriendProfilesUseCase(_repository);
  late final SendFriendRequestUseCase _sendFriendRequest =
      SendFriendRequestUseCase(_repository);
  late final AcceptFriendRequestUseCase _acceptFriendRequest =
      AcceptFriendRequestUseCase(_repository);
  late final DeclineFriendRequestUseCase _declineFriendRequest =
      DeclineFriendRequestUseCase(_repository);
  late final CancelFriendRequestUseCase _cancelFriendRequest =
      CancelFriendRequestUseCase(_repository);
  late final RemoveFriendUseCase _removeFriend = RemoveFriendUseCase(
    _repository,
  );

  FetchFriendsUseCase get fetchFriends => _fetchFriends;
  FetchReceivedFriendRequestsUseCase get fetchReceivedFriendRequests =>
      _fetchReceivedFriendRequests;
  FetchSentFriendRequestsUseCase get fetchSentFriendRequests =>
      _fetchSentFriendRequests;
  SearchFriendProfilesUseCase get searchFriendProfiles => _searchFriendProfiles;
  SendFriendRequestUseCase get sendFriendRequest => _sendFriendRequest;
  AcceptFriendRequestUseCase get acceptFriendRequest => _acceptFriendRequest;
  DeclineFriendRequestUseCase get declineFriendRequest => _declineFriendRequest;
  CancelFriendRequestUseCase get cancelFriendRequest => _cancelFriendRequest;
  RemoveFriendUseCase get removeFriend => _removeFriend;
}
