import 'package:domodachi/core/extensions/build_context_extension.dart';
import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:shared/shared.dart';
import 'package:app_ui/app_ui.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/group_chat_use_cases.dart';
import 'package:feature_group_chat/group_chat/domain/validation/chat_room_field_rules.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/edit/chat_room_form_cubit.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/edit/chat_room_form_state.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/edit/edit_chat_room_cubit.dart';
import 'package:feature_group_chat/group_chat/presentation/cubit/edit/edit_chat_room_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class ModifyChatRoomPage extends StatelessWidget {
  const ModifyChatRoomPage({super.key, required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<ChatRoomFormCubit>()),
        BlocProvider(
          create: (context) => EditChatRoomCubit(
            GetIt.instance<GroupChatUseCases>(),
            context.read<ChatRoomFormCubit>(),
          )..initializeForUpdate(room),
        ),
      ],
      child: _ModifyChatRoomView(room: room),
    );
  }
}

class _ModifyChatRoomView extends StatefulWidget {
  const _ModifyChatRoomView({required this.room});

  final ChatRoom room;

  @override
  State<_ModifyChatRoomView> createState() => _ModifyChatRoomViewState();
}

class _ModifyChatRoomViewState extends State<_ModifyChatRoomView> {
  late final ChatRoomFormCubit _formCubit;
  late final EditChatRoomCubit _editCubit;
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _formCubit = context.read<ChatRoomFormCubit>();
    _editCubit = context.read<EditChatRoomCubit>();
    _titleController = TextEditingController(text: widget.room.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.room.description ?? '',
    );
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    _editCubit.save();
  }

  String _normalizeTag(String raw) {
    return raw.trim().replaceFirst(RegExp(r'^#+'), '');
  }

  void _addTag() {
    final currentTags = _formCubit.state.tags;
    final normalizedTag = _normalizeTag(_tagsController.text);

    if (normalizedTag.isBlank) {
      return;
    }

    final hasDuplicate = currentTags.any(
      (tag) => tag.toLowerCase() == normalizedTag.toLowerCase(),
    );
    if (hasDuplicate) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('중복된 해시태그는 추가할 수 없어요.')));
      return;
    }

    if (currentTags.length >= ChatRoomFieldRules.tagMaxCount) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              '태그는 최대 ${ChatRoomFieldRules.tagMaxCount}개까지 추가할 수 있어요.',
            ),
          ),
        );
      return;
    }

    _formCubit.tagsChanged([...currentTags, normalizedTag]);
    _tagsController.clear();
  }

  void _removeTag(String tag) {
    _formCubit.tagsChanged(
      _formCubit.state.tags.where((value) => value != tag).toList(),
    );
  }

  void _syncControllers(ChatRoomFormState state) {
    if (_titleController.text != state.title) {
      _titleController.value = _titleController.value.copyWith(
        text: state.title,
        selection: TextSelection.collapsed(offset: state.title.length),
        composing: TextRange.empty,
      );
    }

    if (_descriptionController.text != state.description) {
      _descriptionController.value = _descriptionController.value.copyWith(
        text: state.description,
        selection: TextSelection.collapsed(offset: state.description.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<EditChatRoomCubit, EditChatRoomState>(
          listener: (context, state) {
            state.whenOrNull(
              success: (message) {
                final messenger = ScaffoldMessenger.of(context);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(message ?? '채팅방을 수정했어요.')),
                  );

                if (context.mounted) {
                  context.pop(true);
                }
              },
              error: (message) {
                final messenger = ScaffoldMessenger.of(context);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text(message)));
              },
            );
          },
        ),
        BlocListener<ChatRoomFormCubit, ChatRoomFormState>(
          listener: (context, state) => _syncControllers(state),
        ),
      ],
      child: BlocBuilder<ChatRoomFormCubit, ChatRoomFormState>(
        builder: (context, formState) {
          return BlocBuilder<EditChatRoomCubit, EditChatRoomState>(
            builder: (context, editState) {
              final isSubmitting = editState.isLoading;

              return Scaffold(
                appBar: AppBar(title: const Text('채팅방 수정')),
                body: ListView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    24 + context.bottomPadding,
                  ),
                  children: [
                    const _ModifySectionLabel(
                      title: '기본 정보',
                      subtitle: '제목, 소개, 해시태그만 수정할 수 있어요.',
                    ),
                    12.v,
                    _ModifySectionCard(
                      child: Column(
                        children: [
                          TextField(
                            controller: _titleController,
                            enabled: !isSubmitting,
                            maxLength: 60,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: formState.isPrivate
                                  ? '방 제목 (선택)'
                                  : '방 제목',
                              hintText: '예: 성수 커피 스프린트',
                              errorText: formState.titleError,
                            ),
                            onChanged: _formCubit.titleChanged,
                          ),
                          12.v,
                          TextField(
                            controller: _descriptionController,
                            enabled: !isSubmitting,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 200,
                            decoration: InputDecoration(
                              labelText: formState.isPrivate
                                  ? '방 소개 (선택)'
                                  : '방 소개',
                              hintText: '무슨 대화인지 한 줄로 설명해 주세요.',
                              errorText: formState.descriptionError,
                            ),
                            onChanged: _formCubit.descriptionChanged,
                          ),
                          12.v,
                          TextField(
                            controller: _tagsController,
                            enabled: !isSubmitting,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                              labelText: '해시태그',
                              hintText: '#coffee',
                              errorText: formState.tagsError,
                              helperText:
                                  '최대 ${ChatRoomFieldRules.tagMaxCount}개',
                              suffixIcon:
                                  formState.tags.length >=
                                      ChatRoomFieldRules.tagMaxCount
                                  ? null
                                  : DebouncedIconButton(
                                      onPressed: isSubmitting ? null : _addTag,
                                      tooltip: '태그 추가',
                                      icon: const Icon(Icons.add),
                                    ),
                            ),
                            onSubmitted: (_) {
                              if (formState.tags.length <
                                  ChatRoomFieldRules.tagMaxCount) {
                                _addTag();
                              }
                            },
                          ),
                          if (formState.tags.isNotEmpty) ...[
                            12.v,
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: formState.tags
                                    .map(
                                      (tag) => InputChip(
                                        label: Text('#$tag'),
                                        deleteIcon: const Icon(Icons.close),
                                        onDeleted: isSubmitting
                                            ? null
                                            : () => _removeTag(tag),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          ] else ...[
                            4.v,
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '추가한 태그가 여기 표시돼요.',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    24.v,
                    DebouncedFilledButtonIcon(
                      onPressed: isSubmitting ? null : _submit,
                      icon: Icon(
                        isSubmitting
                            ? Icons.hourglass_top_rounded
                            : Icons.edit_outlined,
                      ),
                      label: Text(isSubmitting ? '변경사항 저장 중...' : '변경사항 저장'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ModifySectionLabel extends StatelessWidget {
  const _ModifySectionLabel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        4.v,
        Text(
          subtitle,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _ModifySectionCard extends StatelessWidget {
  const _ModifySectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 18.p,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: 24.br,
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
      child: child,
    );
  }
}
