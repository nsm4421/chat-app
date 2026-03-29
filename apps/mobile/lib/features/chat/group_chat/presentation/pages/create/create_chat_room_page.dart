import 'dart:async';

import 'package:domodachi/core/extensions/build_context_extension.dart';
import 'package:domodachi/core/extensions/num_extension.dart';
import 'package:shared/shared.dart';
import 'package:app_ui/app_ui.dart';
import 'package:feature_chat_core/chat_core/core/value_objects/chat_room_enums.dart';
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

class CreateChatRoomPage extends StatelessWidget {
  const CreateChatRoomPage({super.key, this.initialRoom});

  final ChatRoom? initialRoom;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<ChatRoomFormCubit>()),
        BlocProvider(
          create: (context) => EditChatRoomCubit(
            GetIt.instance<GroupChatUseCases>(),
            context.read<ChatRoomFormCubit>(),
          ),
        ),
      ],
      child: _CreateChatRoomView(initialRoom: initialRoom),
    );
  }
}

class _CreateChatRoomView extends StatefulWidget {
  const _CreateChatRoomView({this.initialRoom});

  final ChatRoom? initialRoom;

  @override
  State<_CreateChatRoomView> createState() => _CreateChatRoomViewState();
}

class _CreateChatRoomViewState extends State<_CreateChatRoomView> {
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
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialRoom != null) {
        _editCubit.initializeForUpdate(widget.initialRoom!);
        return;
      }

      unawaited(_editCubit.initializeForCreate());
    });
  }

  @override
  void dispose() {
    if (widget.initialRoom == null) {
      unawaited(_editCubit.saveDraftOnExit());
    }
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

  Future<void> _showDraftDialog(ChatRoom draft) async {
    final shouldRestore = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('임시 저장된 채팅방이 있어요'),
          content: const Text('이전에 작성하던 내용을 불러오거나 삭제할 수 있어요.'),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('삭제'),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text('불러오기'),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    if (shouldRestore ?? false) {
      _editCubit.restoreDraft(draft);
      return;
    }

    await _editCubit.discardDraft();
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
    final isCreateMode = widget.initialRoom == null;

    return MultiBlocListener(
      listeners: [
        BlocListener<EditChatRoomCubit, EditChatRoomState>(
          listener: (context, state) {
            state.whenOrNull(
              draftFound: _showDraftDialog,
              success: (message) {
                final messenger = ScaffoldMessenger.of(context);
                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(content: Text(message ?? '채팅방을 저장했어요.')),
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
              final isBootstrapping = editState.maybeWhen(
                idle: () => true,
                draftFound: (_) => true,
                orElse: () => false,
              );
              final isSubmitting = editState.isLoading;

              return Scaffold(
                appBar: AppBar(
                  title: Text(
                    widget.initialRoom == null ? '채팅방 만들기' : '채팅방 수정',
                  ),
                ),
                body: isBootstrapping
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          12,
                          20,
                          24 + context.bottomPadding,
                        ),
                        children: [
                          _SectionLabel(
                            title: '기본 정보',
                            subtitle: '제목과 소개가 가장 중요해요. 여기부터 먼저 채워주세요.',
                          ),
                          12.v,
                          _SectionCard(
                            child: Column(
                              children: [
                                TextField(
                                  controller: _titleController,
                                  enabled: !isSubmitting,
                                  maxLength: 60,
                                  textInputAction: TextInputAction.next,
                                  decoration: InputDecoration(
                                    labelText: isCreateMode
                                        ? '방 제목'
                                        : formState.isPrivate
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
                                    labelText: isCreateMode
                                        ? '방 소개'
                                        : formState.isPrivate
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
                                            style: IconButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              shadowColor: Colors.transparent,
                                            ),
                                            onPressed: isSubmitting
                                                ? null
                                                : _addTag,
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
                                              deleteIcon: const Icon(
                                                Icons.close,
                                              ),
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
                                      style: context.textTheme.bodySmall
                                          ?.copyWith(
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          20.v,
                          _SectionLabel(
                            title: '참여 설정',
                            subtitle: isCreateMode
                                ? '생성 화면에서는 그룹 채팅방만 만들 수 있고 최대 인원만 설정합니다.'
                                : '필수 설정만 짧게 정리합니다.',
                          ),
                          12.v,
                          _SectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (!isCreateMode) ...[
                                  SwitchListTile.adaptive(
                                    value: formState.isPrivate,
                                    contentPadding: EdgeInsets.zero,
                                    onChanged: isSubmitting
                                        ? null
                                        : (isPrivate) {
                                            _formCubit.typeChanged(
                                              isPrivate
                                                  ? ChatRoomType.private
                                                  : ChatRoomType.group,
                                            );
                                          },
                                    title: Text(
                                      formState.isPrivate ? '비공개 대화' : '공개 그룹방',
                                    ),
                                    subtitle: Text(
                                      formState.isPrivate
                                          ? '상대와 바로 시작하는 2인 대화예요.'
                                          : '여러 명이 참여할 수 있고 Discover에 노출할 수 있어요.',
                                    ),
                                    secondary: Icon(
                                      formState.isPrivate
                                          ? Icons.lock_outline
                                          : Icons.groups_2_outlined,
                                    ),
                                  ),
                                  8.v,
                                ],
                                if (!isCreateMode && formState.isPrivate)
                                  Container(
                                    width: double.infinity,
                                    padding: 14.p,
                                    decoration: BoxDecoration(
                                      color: context.colorScheme.surface,
                                      borderRadius: 18.br,
                                    ),
                                    child: Text(
                                      '비공개 대화는 추가 설정 없이 2명으로 바로 시작됩니다.',
                                      style: context.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: context
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  )
                                else ...[
                                  if (isCreateMode)
                                    Container(
                                      width: double.infinity,
                                      padding: 14.p,
                                      decoration: BoxDecoration(
                                        color: context.colorScheme.surface,
                                        borderRadius: 18.br,
                                      ),
                                      child: Text(
                                        '이 화면은 그룹 채팅방 생성 전용입니다.',
                                        style: context.textTheme.bodyMedium
                                            ?.copyWith(
                                              color: context
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                      ),
                                    ),
                                  if (isCreateMode) 12.v,
                                  _CapacitySelector(
                                    value: formState.maxParticipants,
                                    onDecrease:
                                        (isSubmitting ||
                                            formState.maxParticipants <=
                                                ChatRoomFieldRules
                                                    .groupMinParticipants)
                                        ? null
                                        : () =>
                                              _formCubit.maxParticipantsChanged(
                                                formState.maxParticipants - 1,
                                              ),
                                    onIncrease:
                                        (isSubmitting ||
                                            formState.maxParticipants >=
                                                ChatRoomFieldRules
                                                    .groupMaxParticipants)
                                        ? null
                                        : () =>
                                              _formCubit.maxParticipantsChanged(
                                                formState.maxParticipants + 1,
                                              ),
                                  ),
                                ],
                                if (formState.maxParticipantsError != null) ...[
                                  10.v,
                                  Text(
                                    formState.maxParticipantsError!,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(
                                          color: context.colorScheme.error,
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
                                  : Icons.add_comment_outlined,
                            ),
                            label: Text(
                              isSubmitting ? '채팅방 저장 중...' : '채팅방 저장',
                            ),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.subtitle});

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

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

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

class _CapacitySelector extends StatelessWidget {
  const _CapacitySelector({
    required this.value,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int value;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Text(
          '참여 인원',
          style: context.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: 999.br,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onDecrease,
                icon: const Icon(Icons.remove),
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44),
                child: Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '명',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              IconButton(
                onPressed: onIncrease,
                icon: const Icon(Icons.add),
                visualDensity: VisualDensity.compact,
                splashRadius: 18,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
