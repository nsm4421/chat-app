import 'package:domodachi/features/chat/core/value_objects/chat_room_enums.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_room_form_state.freezed.dart';

@freezed
class ChatRoomFormState with _$ChatRoomFormState {
  const ChatRoomFormState({
    required this.type,
    required this.status,
    required this.title,
    required this.description,
    required this.tags,
    required this.maxParticipants,
    required this.isPublic,
    this.titleError,
    this.descriptionError,
    this.tagsError,
    this.maxParticipantsError,
  });

  factory ChatRoomFormState.create() {
    return const ChatRoomFormState(
      type: ChatRoomType.group,
      status: ChatRoomStatus.open,
      title: '',
      description: '',
      tags: <String>[],
      maxParticipants: 8,
      isPublic: true,
    );
  }

  factory ChatRoomFormState.fromChatRoom(ChatRoom room) {
    return ChatRoomFormState(
      type: room.type,
      status: room.status,
      title: room.title ?? '',
      description: room.description ?? '',
      tags: room.tags,
      maxParticipants: room.maxParticipants,
      isPublic: room.type == ChatRoomType.group,
    );
  }

  @override
  final ChatRoomType type;

  @override
  final ChatRoomStatus status;

  @override
  final String title;

  @override
  final String description;

  @override
  final List<String> tags;

  @override
  final int maxParticipants;

  @override
  final bool isPublic;

  @override
  final String? titleError;

  @override
  final String? descriptionError;

  @override
  final String? tagsError;

  @override
  final String? maxParticipantsError;
}

extension ChatRoomFormStateX on ChatRoomFormState {
  bool get isPrivate => type == ChatRoomType.private;

  bool get isValid =>
      titleError == null &&
      descriptionError == null &&
      tagsError == null &&
      maxParticipantsError == null;

  String? get normalizedTitle => title.trim().isEmpty ? null : title.trim();

  String? get normalizedDescription =>
      description.trim().isEmpty ? null : description.trim();

  List<String> get normalizedTags => tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .toList(growable: false);

  bool get hasDraftContent =>
      title.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      normalizedTags.isNotEmpty ||
      type == ChatRoomType.private ||
      maxParticipants != 8 ||
      isPublic != true;
}
