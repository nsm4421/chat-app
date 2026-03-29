import 'package:shared/shared.dart';
import 'package:app_ui/app_ui.dart';
import 'package:domodachi/app/router/app_route_path.dart';
import 'package:feature_private_chat/private_chat/domain/use_case/private_chat_use_cases.dart';
import 'package:feature_private_chat/private_chat/presentation/cubit/start_dm/start_dm_cubit.dart';
import 'package:feature_private_chat/private_chat/presentation/cubit/start_dm/start_dm_state.dart';
import 'package:feature_friend/domain/entity/friend.dart';
import 'package:feature_friend/domain/entity/friend_request.dart';
import 'package:feature_friend/presentation/bloc/friend_list/friend_list_bloc.dart';
import 'package:feature_friend/presentation/bloc/received_request/received_friend_request_bloc.dart';
import 'package:feature_friend/presentation/bloc/sent_request/sent_friend_request_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

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
        BlocProvider(
          create: (_) => StartDmCubit(GetIt.instance<PrivateChatUseCases>()),
        ),
      ],
      child: const _FriendHubView(),
    );
  }
}

class _FriendHubView extends StatefulWidget {
  const _FriendHubView();

  @override
  State<_FriendHubView> createState() => _FriendHubViewState();
}

class _FriendHubViewState extends State<_FriendHubView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _searchController;
  late final ScrollController _friendScrollController;
  late final ScrollController _receivedScrollController;
  late final ScrollController _sentScrollController;

  bool _isSearchMode = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (mounted) {
          if (_tabController.index != 0 && _isSearchMode) {
            _isSearchMode = false;
            _query = '';
            _searchController.clear();
          }
          setState(() {});
        }
      });
    _searchController = TextEditingController();
    _friendScrollController = ScrollController()
      ..addListener(_handleFriendScroll);
    _receivedScrollController = ScrollController()
      ..addListener(_handleReceivedScroll);
    _sentScrollController = ScrollController()..addListener(_handleSentScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _friendScrollController
      ..removeListener(_handleFriendScroll)
      ..dispose();
    _receivedScrollController
      ..removeListener(_handleReceivedScroll)
      ..dispose();
    _sentScrollController
      ..removeListener(_handleSentScroll)
      ..dispose();
    super.dispose();
  }

  void _handleFriendScroll() {
    if (!_friendScrollController.hasClients) {
      return;
    }

    final position = _friendScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<FriendListBloc>().fetchMore();
    }
  }

  void _handleReceivedScroll() {
    if (!_receivedScrollController.hasClients) {
      return;
    }

    final position = _receivedScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<ReceivedFriendRequestBloc>().fetchMore();
    }
  }

  void _handleSentScroll() {
    if (!_sentScrollController.hasClients) {
      return;
    }

    final position = _sentScrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<SentFriendRequestBloc>().fetchMore();
    }
  }

  void _toggleSearchMode() {
    if (_tabController.index != 0) {
      return;
    }

    setState(() {
      _isSearchMode = !_isSearchMode;
      if (!_isSearchMode) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  List<Friend> _filterFriends(List<Friend> items) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return items;
    }

    return items
        .where((friend) {
          final displayName = (friend.profile.displayName ?? '').toLowerCase();
          final username = (friend.profile.username ?? '').toLowerCase();
          return displayName.contains(query) || username.contains(query);
        })
        .toList(growable: false);
  }

  List<FriendRequest> _filterReceivedRequests(List<FriendRequest> items) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return items;
    }

    return items
        .where((request) {
          final displayName = (request.requester.displayName ?? '')
              .toLowerCase();
          final username = (request.requester.username ?? '').toLowerCase();
          return displayName.contains(query) || username.contains(query);
        })
        .toList(growable: false);
  }

  List<FriendRequest> _filterSentRequests(List<FriendRequest> items) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return items;
    }

    return items
        .where((request) {
          final displayName = (request.receiver.displayName ?? '')
              .toLowerCase();
          final username = (request.receiver.username ?? '').toLowerCase();
          return displayName.contains(query) || username.contains(query);
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final canSearchFriends = _tabController.index == 0;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: _isSearchMode
            ? TextField(
                controller: _searchController,
                autofocus: true,
                textInputAction: TextInputAction.search,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: '친구 이름 또는 아이디 검색',
                  border: InputBorder.none,
                ),
              )
            : const PageAppBarTitle('친구'),
        actions: canSearchFriends
            ? [
                IconButton(
                  onPressed: _toggleSearchMode,
                  icon: Icon(
                    _isSearchMode ? Icons.close_rounded : Icons.search_rounded,
                  ),
                ),
              ]
            : null,
        bottom: TabBar(
          controller: _tabController,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: '친구'),
            Tab(text: '받은 요청'),
            Tab(text: '보낸 요청'),
          ],
        ),
      ),
      body: BlocListener<StartDmCubit, StartDmState>(
        listenWhen: (previous, current) =>
            previous.status != current.status &&
            (current.isSuccess || current.isFailure),
        listener: (context, state) async {
          final messenger = ScaffoldMessenger.of(context);
          messenger.hideCurrentSnackBar();

          if (state.isFailure) {
            messenger.showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'DM을 열지 못했어요.')),
            );
            context.read<StartDmCubit>().reset();
            return;
          }

          final chatRoomId = state.chatRoomId;
          if (state.isSuccess && chatRoomId != null) {
            context.read<StartDmCubit>().reset();
            await context.push(AppRoutePath.chatRoomPath(chatRoomId));
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Text(
                '친구 목록과 친구 요청을 여기에서 관리하세요.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FriendListTab(
                    scrollController: _friendScrollController,
                    onRefresh: () async {
                      context.read<FriendListBloc>().refresh();
                    },
                    filterFriends: _filterFriends,
                  ),
                  _ReceivedRequestTab(
                    scrollController: _receivedScrollController,
                    onRefresh: () async {
                      context.read<ReceivedFriendRequestBloc>().refresh();
                    },
                    filterRequests: _filterReceivedRequests,
                  ),
                  _SentRequestTab(
                    scrollController: _sentScrollController,
                    onRefresh: () async {
                      context.read<SentFriendRequestBloc>().refresh();
                    },
                    filterRequests: _filterSentRequests,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendListTab extends StatelessWidget {
  const _FriendListTab({
    required this.scrollController,
    required this.onRefresh,
    required this.filterFriends,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final List<Friend> Function(List<Friend>) filterFriends;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FriendListBloc, CursorPaginationState<Friend, String>>(
      builder: (context, state) {
        final items = filterFriends(state.items);

        if (state.isLoading && !state.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.hasData) {
          return _FriendPageEmptyState(
            title: state.isFailure ? '친구 목록을 불러오지 못했어요' : '아직 친구가 없어요',
            message: state.errorMessage ?? '친구가 생기면 여기에 목록이 표시됩니다.',
            icon: state.isFailure
                ? Icons.cloud_off_outlined
                : Icons.people_outline_rounded,
            actionLabel: state.isFailure ? '다시 시도' : null,
            onAction: state.isFailure
                ? () => context.read<FriendListBloc>().refresh()
                : null,
          );
        }

        if (items.isEmpty) {
          return const _FriendPageEmptyState(
            title: '검색 결과가 없어요',
            message: '이름이나 아이디를 다시 확인해 보세요.',
            icon: Icons.search_off_rounded,
          );
        }

        final hasTrailingState =
            state.isLoadingMore || (state.isFailure && state.hasData);

        return RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: items.length + (hasTrailingState ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return _FriendInlineError(
                  message: state.errorMessage ?? '목록을 더 불러오지 못했어요.',
                  onRetry: () => context.read<FriendListBloc>().fetchMore(),
                );
              }

              return _FriendListTile(friend: items[index]);
            },
          ),
        );
      },
    );
  }
}

class _ReceivedRequestTab extends StatelessWidget {
  const _ReceivedRequestTab({
    required this.scrollController,
    required this.onRefresh,
    required this.filterRequests,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final List<FriendRequest> Function(List<FriendRequest>) filterRequests;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      ReceivedFriendRequestBloc,
      CursorPaginationState<FriendRequest, String>
    >(
      builder: (context, state) {
        final items = filterRequests(state.items);

        if (state.isLoading && !state.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.hasData) {
          return _FriendPageEmptyState(
            title: state.isFailure ? '받은 요청을 불러오지 못했어요' : '받은 친구 요청이 없어요',
            message: state.errorMessage ?? '새로운 친구 요청이 오면 여기에 표시됩니다.',
            icon: state.isFailure
                ? Icons.cloud_off_outlined
                : Icons.mark_email_unread_outlined,
            actionLabel: state.isFailure ? '다시 시도' : null,
            onAction: state.isFailure
                ? () => context.read<ReceivedFriendRequestBloc>().refresh()
                : null,
          );
        }

        if (items.isEmpty) {
          return const _FriendPageEmptyState(
            title: '검색 결과가 없어요',
            message: '다른 이름으로 다시 찾아보세요.',
            icon: Icons.search_off_rounded,
          );
        }

        final hasTrailingState =
            state.isLoadingMore || (state.isFailure && state.hasData);

        return RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: items.length + (hasTrailingState ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return _FriendInlineError(
                  message: state.errorMessage ?? '목록을 더 불러오지 못했어요.',
                  onRetry: () =>
                      context.read<ReceivedFriendRequestBloc>().fetchMore(),
                );
              }

              return _ReceivedRequestTile(request: items[index]);
            },
          ),
        );
      },
    );
  }
}

class _SentRequestTab extends StatelessWidget {
  const _SentRequestTab({
    required this.scrollController,
    required this.onRefresh,
    required this.filterRequests,
  });

  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final List<FriendRequest> Function(List<FriendRequest>) filterRequests;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      SentFriendRequestBloc,
      CursorPaginationState<FriendRequest, String>
    >(
      builder: (context, state) {
        final items = filterRequests(state.items);

        if (state.isLoading && !state.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!state.hasData) {
          return _FriendPageEmptyState(
            title: state.isFailure ? '보낸 요청을 불러오지 못했어요' : '보낸 친구 요청이 없어요',
            message: state.errorMessage ?? '보낸 친구 요청이 여기에 표시됩니다.',
            icon: state.isFailure
                ? Icons.cloud_off_outlined
                : Icons.outbox_outlined,
            actionLabel: state.isFailure ? '다시 시도' : null,
            onAction: state.isFailure
                ? () => context.read<SentFriendRequestBloc>().refresh()
                : null,
          );
        }

        if (items.isEmpty) {
          return const _FriendPageEmptyState(
            title: '검색 결과가 없어요',
            message: '다른 이름으로 다시 찾아보세요.',
            icon: Icons.search_off_rounded,
          );
        }

        final hasTrailingState =
            state.isLoadingMore || (state.isFailure && state.hasData);

        return RefreshIndicator.adaptive(
          onRefresh: onRefresh,
          child: ListView.separated(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            itemCount: items.length + (hasTrailingState ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= items.length) {
                if (state.isLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return _FriendInlineError(
                  message: state.errorMessage ?? '목록을 더 불러오지 못했어요.',
                  onRetry: () =>
                      context.read<SentFriendRequestBloc>().fetchMore(),
                );
              }

              return _SentRequestTile(request: items[index]);
            },
          ),
        );
      },
    );
  }
}

class _FriendListTile extends StatelessWidget {
  const _FriendListTile({required this.friend});

  final Friend friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarUrl = friend.profile.avatarUrl;
    final username = friend.profile.username ?? 'unknown';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: avatarUrl != null && avatarUrl.isNotEmpty
            ? CircleAvatar(radius: 24, backgroundImage: NetworkImage(avatarUrl))
            : CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  (friend.profile.displayName ?? username).characters.first,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
        title: Text(
          friend.profile.displayName ?? username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '@$username',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatLastSeen(friend.profile.lastSeenAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        trailing: PopupMenuButton<_FriendAction>(
          onSelected: (action) {
            final messenger = ScaffoldMessenger.of(context);
            messenger.hideCurrentSnackBar();
            switch (action) {
              case _FriendAction.dm:
                context.read<StartDmCubit>().start(friend.profile.id);
              case _FriendAction.remove:
                messenger.showSnackBar(
                  SnackBar(content: Text('@$username 친구 삭제 mock')),
                );
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: _FriendAction.dm, child: Text('DM 보내기')),
            PopupMenuItem(value: _FriendAction.remove, child: Text('친구 삭제')),
          ],
        ),
      ),
    );
  }
}

class _ReceivedRequestTile extends StatelessWidget {
  const _ReceivedRequestTile({required this.request});

  final FriendRequest request;

  Future<void> _declineRequest(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    try {
      await context.read<ReceivedFriendRequestBloc>().declineRequest(
        request.id,
      );
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('친구 요청을 거절했어요.')));
    } catch (error) {
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _acceptRequest(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    try {
      await context.read<ReceivedFriendRequestBloc>().acceptRequest(request.id);
      if (context.mounted) {
        context.read<FriendListBloc>().refresh();
      }
      if (!context.mounted) {
        return;
      }
      messenger.showSnackBar(const SnackBar(content: Text('친구 요청을 수락했어요.')));
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
    final username = request.requester.username ?? 'unknown';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _RequestAvatar(
          label: request.requester.displayName ?? username,
          avatarUrl: request.requester.avatarUrl,
        ),
        title: Text(
          request.requester.displayName ?? username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '@$username',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _declineRequest(context),
                tooltip: '거절',
                icon: const Icon(Icons.close_rounded),
              ),
              IconButton(
                onPressed: () => _acceptRequest(context),
                tooltip: '수락',
                icon: const Icon(Icons.check_rounded),
              ),
            ],
          ),
        ),
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
    final username = request.receiver.username ?? 'unknown';

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(22),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _RequestAvatar(
          label: request.receiver.displayName ?? username,
          avatarUrl: request.receiver.avatarUrl,
        ),
        title: Text(
          request.receiver.displayName ?? username,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            request.message?.isNotEmpty == true
                ? request.message!
                : '응답을 기다리는 중이에요.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
        trailing: OutlinedButton(
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
              messenger.showSnackBar(SnackBar(content: Text(error.toString())));
            }
          },
          child: const Text('취소'),
        ),
      ),
    );
  }
}

class _RequestAvatar extends StatelessWidget {
  const _RequestAvatar({required this.label, this.avatarUrl});

  final String label;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatarUrl!),
      );
    }

    return CircleAvatar(
      radius: 24,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        label.characters.first,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

class _FriendPageEmptyState extends StatelessWidget {
  const _FriendPageEmptyState({
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

class _FriendInlineError extends StatelessWidget {
  const _FriendInlineError({required this.message, required this.onRetry});

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

String _formatLastSeen(DateTime? lastSeenAt) {
  if (lastSeenAt == null) {
    return '최근 접속 정보가 없어요';
  }

  final difference = DateTime.now().difference(lastSeenAt);
  if (difference.inMinutes < 1) {
    return '방금 접속했어요';
  }
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전에 접속';
  }
  if (difference.inHours < 24) {
    return '${difference.inHours}시간 전에 접속';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays}일 전에 접속';
  }

  final month = lastSeenAt.month.toString().padLeft(2, '0');
  final day = lastSeenAt.day.toString().padLeft(2, '0');
  return '$month/$day 접속';
}

enum _FriendAction { dm, remove }
