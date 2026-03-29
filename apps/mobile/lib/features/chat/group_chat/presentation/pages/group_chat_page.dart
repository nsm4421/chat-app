import 'package:domodachi/app/router/app_route_path.dart';
import 'package:shared/shared.dart';
import 'package:app_ui/app_ui.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_group_chat/group_chat/domain/use_case/group_chat_use_cases.dart';
import 'package:feature_group_chat/group_chat/presentation/bloc/group_chat/group_chat_room_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class GroupChatPage extends StatelessWidget {
  const GroupChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<GroupChatRoomBloc>(),
      child: const _GroupChatView(),
    );
  }
}

class _GroupChatView extends StatelessWidget {
  const _GroupChatView();

  Future<void> _handleCreateChatRoom(BuildContext context) async {
    final didCreate = await context.push<bool>(AppRoutePath.createChatRoom);

    if (!context.mounted || didCreate != true) {
      return;
    }

    context.read<GroupChatRoomBloc>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: const PageAppBarTitle('그룹채팅'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutePath.groupChatSearch),
            tooltip: '검색',
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            onPressed: () => _handleCreateChatRoom(context),
            tooltip: '채팅방 만들기',
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: _GroupChatList(
        header: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
          child: Text(
            '지금 참여할 수 있는 그룹채팅을 여기에서 살펴보세요.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
        onCreateChatRoom: () => _handleCreateChatRoom(context),
      ),
    );
  }
}

class _GroupChatList extends StatefulWidget {
  const _GroupChatList({required this.header, required this.onCreateChatRoom});

  final Widget header;
  final Future<void> Function() onCreateChatRoom;

  @override
  State<_GroupChatList> createState() => _GroupChatListState();
}

class _GroupChatListState extends State<_GroupChatList> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<GroupChatRoomBloc>().fetchMore();
    }
  }

  Future<void> _refresh() async {
    context.read<GroupChatRoomBloc>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      GroupChatRoomBloc,
      CursorPaginationState<ChatRoom, String>
    >(
      builder: (context, state) {
        if (state.isLoading && !state.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure && !state.hasData) {
          return _GroupChatEmptyState(
            title: '목록을 불러오지 못했어요',
            message: state.errorMessage ?? '잠시 후 다시 시도해 주세요.',
            icon: Icons.cloud_off_outlined,
            actionLabel: '다시 시도',
            onAction: _refresh,
          );
        }

        if (!state.hasData) {
          return _GroupChatEmptyState(
            title: '공개 그룹채팅이 없어요',
            message: '지금 입장할 수 있는 그룹채팅이 아직 없어요.',
            icon: Icons.groups_2_outlined,
            actionLabel: '새로고침',
            onAction: _refresh,
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: CustomScrollView(
            key: const PageStorageKey('group_chat_list'),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: widget.header),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final hasTrailingState =
                        state.isLoadingMore ||
                        (state.isFailure && state.hasData);
                    final totalCount =
                        state.items.length + (hasTrailingState ? 1 : 0);
                    if (index >= totalCount) {
                      return null;
                    }

                    if (index >= state.items.length) {
                      if (state.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: _GroupChatInlineError(
                          message: state.errorMessage ?? '목록을 더 불러오지 못했어요.',
                          onRetry: () =>
                              context.read<GroupChatRoomBloc>().fetchMore(),
                        ),
                      );
                    }

                    final room = state.items[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom:
                            index == state.items.length - 1 && !hasTrailingState
                            ? 0
                            : 14,
                      ),
                      child: _GroupChatRoomTile(room: room),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GroupChatRoomTile extends StatelessWidget {
  const _GroupChatRoomTile({required this.room});

  final ChatRoom room;

  bool get _canManageRoom => room.isGroup && room.isHost;

  Future<void> _handleOpen(BuildContext context) async {
    final didDelete = await context.push<bool>(
      AppRoutePath.groupChatRoomPath(room.id),
    );
    if (!context.mounted || didDelete != true) {
      return;
    }

    context.read<GroupChatRoomBloc>().itemDeleted(room);
  }

  Future<void> _handleModify(BuildContext context) async {
    final didUpdate = await context.push<bool>(
      AppRoutePath.modifyChatRoom,
      extra: room,
    );

    if (!context.mounted) {
      return;
    }

    if (didUpdate ?? false) {
      context.read<GroupChatRoomBloc>().refresh();
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('채팅방 삭제'),
          content: Text(
            '\'${room.title ?? '이 채팅방'}\'을(를) 삭제할까요? 삭제 후에는 그룹채팅 목록에서 보이지 않아요.',
          ),
          actions: [
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );

    if (!context.mounted || shouldDelete != true) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    try {
      await GetIt.instance<GroupChatUseCases>().deleteChatRoom(room.id);

      if (!context.mounted) {
        return;
      }

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('채팅방을 삭제했어요.')));
      context.read<GroupChatRoomBloc>().itemDeleted(room);
    } on Failure catch (error) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lastActivity = room.lastMessageAt ?? room.createdAt;
    final summary = room.description ?? '설명이 아직 없는 채팅방입니다.';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            onTap: () => _handleOpen(context),
            title: Text(
              room.title ?? 'Untitled room',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
            trailing: _canManageRoom
                ? SizedBox(
                    width: 96,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () => _handleModify(context),
                          tooltip: '수정',
                          icon: const Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          onPressed: () => _handleDelete(context),
                          tooltip: '삭제',
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (room.tags.isNotEmpty) ...[
                  Text(
                    room.tags.take(3).map((tag) => '#$tag').join('  '),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GroupChatMetaChip(label: _statusLabel(room)),
                    _GroupChatMetaChip(
                      label: '${room.memberCount}/${room.maxParticipants}명',
                    ),
                    _GroupChatMetaChip(
                      label: _formatRelativeTime(lastActivity),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupChatMetaChip extends StatelessWidget {
  const _GroupChatMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _GroupChatEmptyState extends StatelessWidget {
  const _GroupChatEmptyState({
    required this.title,
    required this.message,
    required this.icon,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onAction, child: Text(actionLabel)),
          ],
        ),
      ),
    );
  }
}

class _GroupChatInlineError extends StatelessWidget {
  const _GroupChatInlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(onPressed: onRetry, child: const Text('재시도')),
        ],
      ),
    );
  }
}

String _statusLabel(ChatRoom room) {
  return switch (room.status.name) {
    'open' => '지금 참여 가능',
    'full' => '정원 마감',
    'draft' => '준비 중',
    'closed' => '종료됨',
    _ => room.status.name,
  };
}

String _formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'just now';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  }

  return '${dateTime.month}/${dateTime.day}';
}
