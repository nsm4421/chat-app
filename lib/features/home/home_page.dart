import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_state.dart';
import 'package:domodachi/features/auth/presentation/cubit/account/delete_account_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
import 'package:domodachi/core/pagination/cursor_pagination_state.dart';
import 'package:domodachi/features/chat/presentation/pages/group_chat_page.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/presentation/bloc/my_private_chat/my_private_chat_room_bloc.dart';
import 'package:domodachi/features/settings/widgets/settings_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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

    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, state) {
        final user = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
        final displayName = user?.username ?? 'domodachi';
        final email = user?.email ?? 'hello@domodachi.app';

        final tabs = [
          _HomeTab(
            displayName: displayName,
            email: email,
            colorScheme: colorScheme,
          ),
          const GroupChatPage(),
          const _MyPrivateChatsTab(),
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
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                onDestinationSelected: (index) {
                  setState(() => _selectedIndex = index);
                },
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: '홈',
                  ),
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
                    icon: Icon(Icons.settings_outlined),
                    selectedIcon: Icon(Icons.settings),
                    label: '설정',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({
    required this.displayName,
    required this.email,
    required this.colorScheme,
  });

  final String displayName;
  final String email;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final firstName = displayName.split(' ').firstOrNull ?? displayName;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Home',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$firstName님, 지금 이어갈 대화가 있어요',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _HomeProfileBadge(initial: firstName.characters.first),
          ],
        ),
        const SizedBox(height: 22),
        const _HomePulseHero(),
        const SizedBox(height: 24),
        const _HomeSectionHeader(
          title: '이어서 보기',
          subtitle: '최근 대화와 곧 시작하는 약속을 먼저 확인해요.',
        ),
        const SizedBox(height: 14),
        const _ConversationCard(
          name: '성수 커피 번개',
          message: '지금 두 자리 비었어요. 합류 가능하면 바로 알려주세요.',
          time: '2m',
          unreadCount: 2,
        ),
        const SizedBox(height: 12),
        const _ConversationCard(
          name: '한강 러닝 5K',
          message: '출발 전 스트레칭 포인트만 정하면 바로 시작할 수 있어요.',
          time: '18m',
          unreadCount: 1,
        ),
        const SizedBox(height: 24),
        const _HomeSectionHeader(
          title: '오늘의 흐름',
          subtitle: '홈은 추천보다 지금 해야 할 액션을 먼저 보여줍니다.',
        ),
        const SizedBox(height: 14),
        const _HomeAgendaCard(),
        const SizedBox(height: 24),
        const _HomeSectionHeader(
          title: '당신에게 맞는 방',
          subtitle: '전체 목록은 Group Chat에서, 홈에서는 2개만 압축해서 보여줘요.',
        ),
        const SizedBox(height: 14),
        ..._mockHomeRecommendations.map(
          (room) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _HomeRecommendationCard(room: room),
          ),
        ),
        const SizedBox(height: 12),
        const _HomeSectionHeader(
          title: '빠른 실행',
          subtitle: '지금 자주 쓸 액션만 상단 흐름에 맞게 배치합니다.',
        ),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _HomeQuickActionTile(
                icon: Icons.forum_outlined,
                title: '내 채팅방',
                subtitle: '읽지 않은 대화 바로 보기',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _HomeQuickActionTile(
                icon: Icons.travel_explore_outlined,
                title: 'Group Chat',
                subtitle: '공개 그룹방 둘러보기',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _HomeQuickActionTile(
                icon: Icons.add_comment_outlined,
                title: '방 만들기',
                subtitle: '새로운 대화 시작',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _HomeSectionHeader(
          title: '정착 가이드',
          subtitle: '신규 또는 복귀 유저가 다음 행동을 헷갈리지 않게 도와줍니다.',
        ),
        const SizedBox(height: 14),
        const _HomeChecklistCard(),
      ],
    );
  }
}

class _HomeProfileBadge extends StatelessWidget {
  const _HomeProfileBadge({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          initial,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _HomePulseHero extends StatelessWidget {
  const _HomePulseHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.tertiary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today at a glance',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '읽지 않은 메시지 3개,\n오늘 합류하기 좋은 방 2개가 있어요.',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '홈은 지금 바로 확인해야 할 것과 다음 액션을 먼저 보여주는 시작 화면이에요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.82),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _HomePulseMetric(
                  label: 'Unread',
                  value: '03',
                  caption: '확인할 메시지',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _HomePulseMetric(
                  label: 'Today',
                  value: '01',
                  caption: '곧 시작하는 방',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _HomePulseMetric(
                  label: 'Match',
                  value: '02',
                  caption: '추천 방',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomePulseMetric extends StatelessWidget {
  const _HomePulseMetric({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.76),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            caption,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSectionHeader extends StatelessWidget {
  const _HomeSectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HomeAgendaCard extends StatelessWidget {
  const _HomeAgendaCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HomeAgendaRow(
            title: '19:30',
            subtitle: '성수 커피 번개 시작 20분 전',
            accentColor: Color(0xFFE99663),
          ),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          const _HomeAgendaRow(
            title: 'Unread 3',
            subtitle: '답장이 필요한 대화가 2개 있어요',
            accentColor: Color(0xFF5F9DF7),
          ),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant),
          const SizedBox(height: 12),
          const _HomeAgendaRow(
            title: 'Profile 80%',
            subtitle: '관심 태그만 추가하면 추천 품질이 더 좋아져요',
            accentColor: Color(0xFF7BC67E),
          ),
        ],
      ),
    );
  }
}

class _HomeAgendaRow extends StatelessWidget {
  const _HomeAgendaRow({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  final String title;
  final String subtitle;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 48,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeRecommendationCard extends StatelessWidget {
  const _HomeRecommendationCard({required this.room});

  final _MockHomeRecommendation room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _RoomPill(
                label: room.reason,
                backgroundColor: room.accentColor.withValues(alpha: 0.16),
                foregroundColor: room.accentColor,
              ),
              const SizedBox(width: 8),
              _RoomPill(
                label: room.badge,
                backgroundColor: colorScheme.secondaryContainer,
                foregroundColor: colorScheme.onSecondaryContainer,
              ),
              const Spacer(),
              Icon(room.icon, color: room.accentColor),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            room.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            room.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  room.meta,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              FilledButton.tonal(onPressed: () {}, child: const Text('살펴보기')),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeQuickActionTile extends StatelessWidget {
  const _HomeQuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeChecklistCard extends StatelessWidget {
  const _HomeChecklistCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '오늘의 첫 액션 제안',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '신규 유저라면 프로필 태그를 채우고, 복귀 유저라면 읽지 않은 대화부터 확인하는 흐름이 자연스럽습니다.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.82),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          const _HomeChecklistItem(title: '관심 태그 추가', status: '추천 정확도 향상'),
          const SizedBox(height: 10),
          const _HomeChecklistItem(title: '읽지 않은 대화 확인', status: '2개 남음'),
          const SizedBox(height: 10),
          const _HomeChecklistItem(title: '오늘 열리는 방 둘러보기', status: '2개 추천됨'),
        ],
      ),
    );
  }
}

class _HomeChecklistItem extends StatelessWidget {
  const _HomeChecklistItem({required this.title, required this.status});

  final String title;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(
            Icons.check,
            size: 18,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        Text(
          status,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.78),
          ),
        ),
      ],
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

  Future<void> _openFriends(BuildContext context) async {
    await context.push(AppRoutePath.friends);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('DM', style: theme.textTheme.headlineMedium),
              ),
              OutlinedButton.icon(
                onPressed: () => _openFriends(context),
                icon: const Icon(Icons.group_add_outlined),
                label: const Text('친구'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '1:1 대화와 친구 관리를 함께 보세요.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const Expanded(child: _MyPrivateChatRoomList()),
        ],
      ),
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

class _RoomPill extends StatelessWidget {
  const _RoomPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(color: foregroundColor),
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

final List<_MockHomeRecommendation> _mockHomeRecommendations = [
  _MockHomeRecommendation(
    title: 'Weekend walking crew',
    description: '최근 산책 태그를 자주 봤다면 바로 합류하기 좋은 가벼운 방이에요.',
    reason: 'For you',
    badge: '1.2km',
    meta: '산책 · 커피 · 9/10명',
    icon: Icons.directions_walk_outlined,
    accentColor: Color(0xFF6BAE92),
  ),
  _MockHomeRecommendation(
    title: 'Late night designers',
    description: 'UI, 카피, 플로우 피드백을 짧게 주고받는 소규모 야간 테이블입니다.',
    reason: 'Based on design',
    badge: '4 seats left',
    meta: '디자인 · 피드백 · 오늘 22:00',
    icon: Icons.palette_outlined,
    accentColor: Color(0xFFB86A84),
  ),
];

class _MockHomeRecommendation {
  const _MockHomeRecommendation({
    required this.title,
    required this.description,
    required this.reason,
    required this.badge,
    required this.meta,
    required this.icon,
    required this.accentColor,
  });

  final String title;
  final String description;
  final String reason;
  final String badge;
  final String meta;
  final IconData icon;
  final Color accentColor;
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.name,
    required this.message,
    required this.time,
    this.unreadCount = 0,
  });

  final String name;
  final String message;
  final String time;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              name.characters.first,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(height: 10),
                Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
