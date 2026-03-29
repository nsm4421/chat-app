import 'package:feature_auth/presentation/cubit/account/delete_account_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:shared/shared.dart';
import 'package:app_ui/app_ui.dart';
import 'package:domodachi/features/chat/group_chat/presentation/pages/group_chat_page.dart';
import 'package:feature_chat_core/chat_core/domain/entity/chat_room.dart';
import 'package:feature_private_chat/private_chat/presentation/bloc/my_private_chat/my_private_chat_room_bloc.dart';
import 'package:domodachi/features/friend/presentation/pages/friend_hub_page.dart';
import 'package:domodachi/features/settings/widgets/settings_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tabs = [
      const GroupChatPage(),
      const _MyPrivateChatsTab(),
      const FriendHubPage(),
      const _SettingsTab(),
    ];

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.9),
              colorScheme.surface,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: tabs[_selectedIndex],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.groups_2_outlined),
                selectedIcon: Icon(Icons.groups_2),
                label: '그룹채팅',
              ),
              NavigationDestination(
                icon: Icon(Icons.chat_bubble_outline),
                selectedIcon: Icon(Icons.chat_bubble),
                label: '채팅',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: '친구',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: '설정',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyPrivateChatsTab extends StatelessWidget {
  const _MyPrivateChatsTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<MyPrivateChatRoomBloc>(),
      child: const _MyPrivateChatsTabView(),
    );
  }
}

class _MyPrivateChatsTabView extends StatelessWidget {
  const _MyPrivateChatsTabView();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageIntroHeader(
          title: '채팅',
          subtitle: '개인 대화 목록을 여기에서 확인하세요.',
          padding: EdgeInsets.fromLTRB(20, 12, 20, 20),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: _MyPrivateChatRoomList(),
          ),
        ),
      ],
    );
  }
}

class _MyPrivateChatRoomList extends StatefulWidget {
  const _MyPrivateChatRoomList();

  @override
  State<_MyPrivateChatRoomList> createState() => _MyPrivateChatRoomListState();
}

class _MyPrivateChatRoomListState extends State<_MyPrivateChatRoomList> {
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
      context.read<MyPrivateChatRoomBloc>().fetchMore();
    }
  }

  Future<void> _refresh() async {
    context.read<MyPrivateChatRoomBloc>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      MyPrivateChatRoomBloc,
      CursorPaginationState<ChatRoom, String>
    >(
      builder: (context, state) {
        final rooms = state.items;

        if (state.isLoading && !state.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.hasData) {
          return _JoinedChatRoomEmptyState(
            title: '진행 중인 private chat이 없어요',
            message: state.errorMessage ?? '매칭되거나 초대된 1:1 대화가 여기에 표시됩니다.',
            icon: Icons.lock_outline,
            isFailure: state.isFailure,
            onRetry: () => context.read<MyPrivateChatRoomBloc>().refresh(),
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: _refresh,
          child: CustomScrollView(
            key: const PageStorageKey('my_private_chat_rooms'),
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final hasTrailingState =
                        state.isLoadingMore ||
                        (state.isFailure && state.hasData);
                    final totalCount =
                        rooms.length + (hasTrailingState ? 1 : 0);
                    if (index >= totalCount) {
                      return null;
                    }

                    if (index >= rooms.length) {
                      if (state.isLoadingMore) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: _ChatRoomInlineError(
                          message: state.errorMessage ?? '목록을 더 불러오지 못했어요.',
                          onRetry: () =>
                              context.read<MyPrivateChatRoomBloc>().fetchMore(),
                        ),
                      );
                    }

                    final room = rooms[index];
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: index == rooms.length - 1 && !hasTrailingState
                            ? 0
                            : 14,
                      ),
                      child: _DmListTile(room: room),
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

class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<DeleteAccountCubit>(),
      child: const AuthRequestListener<DeleteAccountCubit>(
        child: SettingsContent(showInlineToggle: true),
      ),
    );
  }
}

class _DmListTile extends StatelessWidget {
  const _DmListTile({required this.room});

  final ChatRoom room;

  void _handleOpen(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(room.isJoined ? '입장 mock입니다.' : '참여 mock입니다.')),
    );
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        onTap: () => _handleOpen(context),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            _iconForRoom(room),
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          room.title ?? 'Untitled room',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        trailing: Text(
          _formatRelativeTime(lastActivity),
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
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
      ),
    );
  }
}

class _JoinedChatRoomEmptyState extends StatelessWidget {
  const _JoinedChatRoomEmptyState({
    required this.title,
    required this.message,
    required this.icon,
    required this.isFailure,
    required this.onRetry,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool isFailure;
  final VoidCallback onRetry;

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
            Icon(
              isFailure ? Icons.cloud_off_outlined : icon,
              size: 42,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 14),
            Text(
              isFailure ? '목록을 불러오지 못했어요' : title,
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
            FilledButton(
              onPressed: isFailure ? onRetry : () {},
              child: Text(isFailure ? '다시 시도' : '곧 여기에 표시돼요'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRoomInlineError extends StatelessWidget {
  const _ChatRoomInlineError({required this.message, required this.onRetry});

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

IconData _iconForRoom(ChatRoom room) {
  final primaryTag = room.tags.firstOrNull;

  return switch (primaryTag) {
    'coffee' => Icons.coffee_outlined,
    'walking' => Icons.directions_walk_outlined,
    'design' => Icons.palette_outlined,
    'study' => Icons.menu_book_outlined,
    _ => Icons.forum_outlined,
  };
}
