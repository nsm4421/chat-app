import 'package:domodachi/core/pagination/cursor_pagination_state.dart';
import 'package:domodachi/features/friend/domain/entity/friend.dart';
import 'package:domodachi/features/friend/domain/entity/friend_request.dart';
import 'package:domodachi/features/friend/presentation/bloc/friend_list/friend_list_bloc.dart';
import 'package:domodachi/features/friend/presentation/bloc/received_request/received_friend_request_bloc.dart';
import 'package:domodachi/features/friend/presentation/bloc/search/friend_search_bloc.dart';
import 'package:domodachi/features/friend/presentation/bloc/search/friend_search_state.dart';
import 'package:domodachi/features/friend/presentation/bloc/sent_request/sent_friend_request_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class FriendHubPage extends StatelessWidget {
  const FriendHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<FriendListBloc>()),
        BlocProvider(
          create: (_) => GetIt.instance<ReceivedFriendRequestBloc>(),
        ),
        BlocProvider(create: (_) => GetIt.instance<SentFriendRequestBloc>()),
        BlocProvider(create: (_) => GetIt.instance<FriendSearchBloc>()),
      ],
      child: const _FriendHubView(),
    );
  }
}

class _FriendHubView extends StatelessWidget {
  const _FriendHubView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('친구'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: '친구'),
              Tab(text: '받은 요청'),
              Tab(text: '보낸 요청'),
              Tab(text: '검색'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _FriendListTab(),
            _ReceivedRequestTab(),
            _SentRequestTab(),
            _FriendSearchTab(),
          ],
        ),
      ),
    );
  }
}

class _FriendListTab extends StatefulWidget {
  const _FriendListTab();

  @override
  State<_FriendListTab> createState() => _FriendListTabState();
}

class _FriendListTabState extends State<_FriendListTab> {
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
      context.read<FriendListBloc>().fetchMore();
    }
  }

  Future<void> _refresh() async {
    context.read<FriendListBloc>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _FriendPagedList<Friend, FriendListBloc>(
      scrollController: _scrollController,
      onRefresh: _refresh,
      emptyTitle: '아직 추가된 친구가 없어요',
      emptyMessage: '검색 탭에서 사용자를 찾아 친구 요청을 보내보세요.',
      emptyIcon: Icons.group_add_outlined,
      itemBuilder: (context, friend) => _FriendTile(friend: friend),
      onRetry: () => context.read<FriendListBloc>().refresh(),
      onFetchMoreRetry: () => context.read<FriendListBloc>().fetchMore(),
    );
  }
}

class _ReceivedRequestTab extends StatefulWidget {
  const _ReceivedRequestTab();

  @override
  State<_ReceivedRequestTab> createState() => _ReceivedRequestTabState();
}

class _ReceivedRequestTabState extends State<_ReceivedRequestTab> {
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
      context.read<ReceivedFriendRequestBloc>().fetchMore();
    }
  }

  Future<void> _refresh() async {
    context.read<ReceivedFriendRequestBloc>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _FriendPagedList<FriendRequest, ReceivedFriendRequestBloc>(
      scrollController: _scrollController,
      onRefresh: _refresh,
      emptyTitle: '받은 친구 요청이 없어요',
      emptyMessage: '새로운 요청이 오면 여기에서 바로 수락하거나 거절할 수 있어요.',
      emptyIcon: Icons.mark_email_unread_outlined,
      itemBuilder: (context, request) => _ReceivedRequestTile(request: request),
      onRetry: () => context.read<ReceivedFriendRequestBloc>().refresh(),
      onFetchMoreRetry: () =>
          context.read<ReceivedFriendRequestBloc>().fetchMore(),
    );
  }
}

class _SentRequestTab extends StatefulWidget {
  const _SentRequestTab();

  @override
  State<_SentRequestTab> createState() => _SentRequestTabState();
}

class _SentRequestTabState extends State<_SentRequestTab> {
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
      context.read<SentFriendRequestBloc>().fetchMore();
    }
  }

  Future<void> _refresh() async {
    context.read<SentFriendRequestBloc>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    return _FriendPagedList<FriendRequest, SentFriendRequestBloc>(
      scrollController: _scrollController,
      onRefresh: _refresh,
      emptyTitle: '보낸 친구 요청이 없어요',
      emptyMessage: '친구 요청을 보내면 상태를 여기에서 확인할 수 있어요.',
      emptyIcon: Icons.outbox_outlined,
      itemBuilder: (context, request) => _SentRequestTile(request: request),
      onRetry: () => context.read<SentFriendRequestBloc>().refresh(),
      onFetchMoreRetry: () => context.read<SentFriendRequestBloc>().fetchMore(),
    );
  }
}

class _FriendSearchTab extends StatefulWidget {
  const _FriendSearchTab();

  @override
  State<_FriendSearchTab> createState() => _FriendSearchTabState();
}

class _FriendSearchTabState extends State<_FriendSearchTab> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendRequest(
    BuildContext context, {
    required String receiverUserId,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    try {
      await context.read<FriendSearchBloc>().sendFriendRequest(
        receiverUserId: receiverUserId,
      );
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('친구 요청을 보냈어요.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: context.read<FriendSearchBloc>().search,
            decoration: InputDecoration(
              hintText: '이름 또는 아이디로 검색',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: () {
                  _controller.clear();
                  context.read<FriendSearchBloc>().clear();
                },
                icon: const Icon(Icons.close_rounded),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () =>
                  context.read<FriendSearchBloc>().search(_controller.text),
              child: const Text('검색'),
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: BlocBuilder<FriendSearchBloc, FriendSearchState>(
              builder: (context, state) {
                return state.when(
                  idle: () => _SearchEmptyState(
                    title: '친구를 찾아보세요',
                    message: 'display name이나 username으로 사용자를 검색할 수 있어요.',
                    icon: Icons.person_search_outlined,
                  ),
                  loading: (_) =>
                      const Center(child: CircularProgressIndicator()),
                  empty: (query) => _SearchEmptyState(
                    title: '"$query" 검색 결과가 없어요',
                    message: '철자를 다시 확인하거나 다른 키워드로 시도해 보세요.',
                    icon: Icons.search_off_rounded,
                  ),
                  failure: (_, message) => _SearchEmptyState(
                    title: '검색을 처리하지 못했어요',
                    message: message,
                    icon: Icons.cloud_off_outlined,
                  ),
                  success: (_, items) => ListView.separated(
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final subtitleParts = [
                        if ((item.profile.username ?? '').isNotEmpty)
                          '@${item.profile.username}',
                        if ((item.profile.bio ?? '').isNotEmpty)
                          item.profile.bio!,
                      ];

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          children: [
                            _ProfileAvatar(
                              label:
                                  item.profile.displayName ??
                                  item.profile.username ??
                                  'U',
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.profile.displayName ??
                                        item.profile.username ??
                                        'Unknown user',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  if (subtitleParts.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      subtitleParts.join(' • '),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (item.isFriend)
                              const Chip(label: Text('친구'))
                            else if (item.hasPendingRequest)
                              const Chip(label: Text('요청 중'))
                            else
                              FilledButton.tonal(
                                onPressed: () => _sendRequest(
                                  context,
                                  receiverUserId: item.profile.id,
                                ),
                                child: const Text('추가'),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendPagedList<
  T,
  B extends StateStreamable<CursorPaginationState<T, String>>
>
    extends StatelessWidget {
  const _FriendPagedList({
    required this.scrollController,
    required this.onRefresh,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.emptyIcon,
    required this.itemBuilder,
    required this.onRetry,
    required this.onFetchMoreRetry,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onRetry;
  final VoidCallback onFetchMoreRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, CursorPaginationState<T, String>>(
      builder: (context, state) {
        final items = state.items;

        if (state.isLoading && !state.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.hasData) {
          return _SearchEmptyState(
            title: state.isFailure ? '목록을 불러오지 못했어요' : emptyTitle,
            message: state.errorMessage ?? emptyMessage,
            icon: state.isFailure ? Icons.cloud_off_outlined : emptyIcon,
            actionLabel: state.isFailure ? '다시 시도' : null,
            onAction: state.isFailure ? onRetry : null,
          );
        }

        return RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            itemCount:
                items.length +
                (state.isLoadingMore || (state.isFailure && state.hasData)
                    ? 1
                    : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return _InlineErrorCard(
                  message: state.errorMessage ?? '목록을 더 불러오지 못했어요.',
                  onRetry: onFetchMoreRetry,
                );
              }

              return itemBuilder(context, items[index]);
            },
          ),
        );
      },
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _ProfileAvatar(
            label: friend.profile.displayName ?? friend.profile.username ?? 'U',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  friend.profile.displayName ??
                      friend.profile.username ??
                      'Unknown user',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '@${friend.profile.username ?? 'unknown'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          FilledButton.tonal(onPressed: () {}, child: const Text('대화')),
        ],
      ),
    );
  }
}

class _ReceivedRequestTile extends StatelessWidget {
  const _ReceivedRequestTile({required this.request});

  final FriendRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ProfileAvatar(
                label:
                    request.requester.displayName ??
                    request.requester.username ??
                    'U',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.requester.displayName ??
                          request.requester.username ??
                          'Unknown user',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${request.requester.username ?? 'unknown'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((request.message ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              request.message!,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();
                    try {
                      await context
                          .read<ReceivedFriendRequestBloc>()
                          .declineRequest(request.id);
                      if (!context.mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        const SnackBar(content: Text('친구 요청을 거절했어요.')),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  },
                  child: const Text('거절'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.hideCurrentSnackBar();
                    try {
                      await context
                          .read<ReceivedFriendRequestBloc>()
                          .acceptRequest(request.id);
                      if (!context.mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        const SnackBar(content: Text('친구 요청을 수락했어요.')),
                      );
                    } catch (error) {
                      if (!context.mounted) {
                        return;
                      }
                      messenger.showSnackBar(
                        SnackBar(content: Text(error.toString())),
                      );
                    }
                  },
                  child: const Text('수락'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SentRequestTile extends StatelessWidget {
  const _SentRequestTile({required this.request});

  final FriendRequest request;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _ProfileAvatar(
            label:
                request.receiver.displayName ??
                request.receiver.username ??
                'U',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.receiver.displayName ??
                      request.receiver.username ??
                      'Unknown user',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  request.message?.isNotEmpty == true
                      ? request.message!
                      : '응답을 기다리는 중이에요.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              messenger.hideCurrentSnackBar();
              try {
                await context.read<SentFriendRequestBloc>().cancelRequest(
                  request.id,
                );
                if (!context.mounted) {
                  return;
                }
                messenger.showSnackBar(
                  const SnackBar(content: Text('친구 요청을 취소했어요.')),
                );
              } catch (error) {
                if (!context.mounted) {
                  return;
                }
                messenger.showSnackBar(
                  SnackBar(content: Text(error.toString())),
                );
              }
            },
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final seed = label.trim().isEmpty ? 'U' : label.trim().characters.first;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          seed,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.title,
    required this.message,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InlineErrorCard extends StatelessWidget {
  const _InlineErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
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
