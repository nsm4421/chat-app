import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_composer_state.freezed.dart';

@freezed
class ChatComposerState with _$ChatComposerState {
  const ChatComposerState({
    this.text = '',
    this.isSending = false,
    this.errorMessage,
  });

  factory ChatComposerState.initial() => const ChatComposerState();

  @override
  final String text;

  @override
  final bool isSending;

  @override
  final String? errorMessage;
}

extension ChatComposerStateX on ChatComposerState {
  bool get canSend => text.trim().isNotEmpty && !isSending;
}
