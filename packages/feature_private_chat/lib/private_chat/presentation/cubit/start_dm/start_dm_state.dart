enum StartDmStatus { idle, loading, success, failure }

final class StartDmState {
  const StartDmState({
    this.status = StartDmStatus.idle,
    this.targetUserId,
    this.chatRoomId,
    this.errorMessage,
  });

  final StartDmStatus status;
  final String? targetUserId;
  final String? chatRoomId;
  final String? errorMessage;

  bool get isIdle => status == StartDmStatus.idle;
  bool get isLoading => status == StartDmStatus.loading;
  bool get isSuccess => status == StartDmStatus.success;
  bool get isFailure => status == StartDmStatus.failure;

  bool isLoadingFor(String userId) => isLoading && targetUserId == userId;

  StartDmState copyWith({
    StartDmStatus? status,
    String? targetUserId,
    String? chatRoomId,
    String? errorMessage,
    bool clearTargetUserId = false,
    bool clearChatRoomId = false,
    bool clearErrorMessage = false,
  }) {
    return StartDmState(
      status: status ?? this.status,
      targetUserId: clearTargetUserId
          ? null
          : (targetUserId ?? this.targetUserId),
      chatRoomId: clearChatRoomId ? null : (chatRoomId ?? this.chatRoomId),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}
