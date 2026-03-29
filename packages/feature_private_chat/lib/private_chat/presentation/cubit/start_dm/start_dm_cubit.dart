import 'package:shared/shared.dart';
import 'package:feature_private_chat/private_chat/domain/use_case/private_chat_use_cases.dart';
import 'package:feature_private_chat/private_chat/presentation/cubit/start_dm/start_dm_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartDmCubit extends Cubit<StartDmState> {
  StartDmCubit(this._chatUseCases) : super(const StartDmState());

  final PrivateChatUseCases _chatUseCases;

  Future<void> start(String otherUserId) async {
    if (state.isLoadingFor(otherUserId)) {
      return;
    }

    emit(
      StartDmState(status: StartDmStatus.loading, targetUserId: otherUserId),
    );

    try {
      final room = await _chatUseCases.createOrGetPrivateChatRoom(otherUserId);
      emit(
        StartDmState(
          status: StartDmStatus.success,
          targetUserId: otherUserId,
          chatRoomId: room.id,
        ),
      );
    } on Failure catch (error) {
      emit(
        StartDmState(
          status: StartDmStatus.failure,
          targetUserId: otherUserId,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        StartDmState(
          status: StartDmStatus.failure,
          targetUserId: otherUserId,
          errorMessage: 'DM을 열지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  void reset() {
    emit(const StartDmState());
  }
}
