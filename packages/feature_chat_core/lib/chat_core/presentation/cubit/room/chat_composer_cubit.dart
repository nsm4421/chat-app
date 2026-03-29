import 'package:shared/shared.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_message.dart';
import 'package:feature_chat_core/chat_core/domain/use_case/chat_core_use_cases.dart';
import 'package:feature_chat_core/chat_core/presentation/cubit/room/chat_composer_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatComposerCubit extends Cubit<ChatComposerState> {
  ChatComposerCubit(this._chatUseCases, @factoryParam this._chatRoomId)
    : super(ChatComposerState.initial());

  final ChatCoreUseCases _chatUseCases;
  final String _chatRoomId;

  void textChanged(String value) {
    emit(state.copyWith(text: value, errorMessage: null));
  }

  void clear() {
    emit(state.copyWith(text: '', errorMessage: null));
  }

  Future<ChatMessage?> send() async {
    final content = state.text.trim();
    if (content.isEmpty || state.isSending) {
      return null;
    }

    emit(state.copyWith(isSending: true, errorMessage: null));

    try {
      final message = await _chatUseCases.sendChatMessage(
        chatRoomId: _chatRoomId,
        content: content,
      );

      emit(state.copyWith(text: '', isSending: false, errorMessage: null));

      return message;
    } on Failure catch (error) {
      emit(state.copyWith(isSending: false, errorMessage: error.message));
    } catch (_) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: '메시지를 전송하지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }

    return null;
  }
}
