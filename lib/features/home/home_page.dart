import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_cubit.dart';
import 'package:domodachi/features/auth/presentation/cubit/session/auth_session_state.dart';
import 'package:domodachi/features/auth/presentation/cubit/account/delete_account_cubit.dart';
import 'package:domodachi/features/auth/presentation/widgets/auth_request_listener.dart';
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

    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, state) {
        final user = state.maybeWhen(
          authenticated: (user) => user,
          orElse: () => null,
        );
        final displayName = user?.displayName ?? 'Domodachi Crew';
        final email = user?.email ?? 'hello@domodachi.app';

        final tabs = [
          _HomeTab(
            displayName: displayName,
            email: email,
            colorScheme: colorScheme,
          ),
          const _DiscoverTab(),
          const _ChatRoomsTab(),
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
                    icon: Icon(Icons.explore_outlined),
                    selectedIcon: Icon(Icons.explore),
                    label: 'Discover',
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Text(
          'Good evening',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          displayName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tonight\'s pulse',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.84),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '주변에 12개의 대화가 열려 있고\n3명이 당신의 프로필을 확인했어요.',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  _HighlightChip(label: 'Nearby 12'),
                  SizedBox(width: 10),
                  _HighlightChip(label: 'Unread 5'),
                  SizedBox(width: 10),
                  _HighlightChip(label: 'New vibe'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text('Quick actions', style: theme.textTheme.titleLarge),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.camera_alt_outlined,
                title: 'Moment',
                subtitle: '오늘의 감정을 한 컷으로 남겨요',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.coffee_outlined,
                title: 'Meet',
                subtitle: '근처에서 가볍게 만날 사람 찾기',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _QuickActionCard(
          icon: Icons.auto_awesome_outlined,
          title: 'Mood mix',
          subtitle: '추천 키워드로 오늘 대화를 바로 시작해요',
          fullWidth: true,
        ),
        const SizedBox(height: 24),
        Text('Trending rooms', style: theme.textTheme.titleLarge),
        const SizedBox(height: 14),
        const _RoomCard(
          title: 'Han River Afterwork',
          detail: '퇴근 후 바로 합류 가능한 6명',
          badge: '12 min away',
          accentColor: Color(0xFFFFC857),
        ),
        const SizedBox(height: 12),
        const _RoomCard(
          title: 'Quiet Study Sprint',
          detail: '집중 50분 + 휴식 10분 루틴',
          badge: 'Open now',
          accentColor: Color(0xFF7BD389),
        ),
        const SizedBox(height: 12),
        const _RoomCard(
          title: 'Late Night Designers',
          detail: 'UI 피드백 교환하는 소규모 테이블',
          badge: '4 seats left',
          accentColor: Color(0xFFFF8A65),
        ),
      ],
    );
  }
}

class _DiscoverTab extends StatelessWidget {
  const _DiscoverTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Text('Discover', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '지금 분위기에 맞는 사람과 장소를 빠르게 훑어보는 mock 섹션입니다.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        const _DiscoverCard(
          title: 'Creative lunch table',
          subtitle: '브랜딩, 사이드 프로젝트, 커리어 이야기',
          meta: '7 people joined',
        ),
        const SizedBox(height: 12),
        const _DiscoverCard(
          title: 'Weekend walking crew',
          subtitle: '성수동 가볍게 걷고 커피 마시는 모임',
          meta: 'Starts in 35 min',
        ),
        const SizedBox(height: 12),
        const _DiscoverCard(
          title: 'Quiet strangers club',
          subtitle: '말 많이 안 해도 편한 느슨한 연결',
          meta: 'Trending in Seoul',
        ),
      ],
    );
  }
}

class _ChatRoomsTab extends StatelessWidget {
  const _ChatRoomsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      children: [
        Text('My chat rooms', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Text(
          '내가 참여 중인 채팅방 목록입니다.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        const _ConversationCard(
          name: '성수 커피 번개',
          message: '지금 2명 더 합류 가능해요. 올 분 있나요?',
          time: '2m',
          unreadCount: 2,
        ),
        const SizedBox(height: 12),
        const _ConversationCard(
          name: '한강 러닝 5K',
          message: '내일 오전 7시 반에 출발하는 걸로 정리할게요.',
          time: '18m',
        ),
        const SizedBox(height: 12),
        const _ConversationCard(
          name: '퇴근 후 맥주팟',
          message: '테이블 예약 완료했습니다. 7시에 봐요.',
          time: '1h',
          unreadCount: 1,
        ),
      ],
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

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.fullWidth = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.title,
    required this.detail,
    required this.badge,
    required this.accentColor,
  });

  final String title;
  final String detail;
  final String badge;
  final Color accentColor;

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
          Container(
            width: 14,
            height: 56,
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
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(
                  detail,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(badge, style: theme.textTheme.labelLarge),
          ),
        ],
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final String title;
  final String subtitle;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Text(meta, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
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
