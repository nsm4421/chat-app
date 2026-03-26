import 'dart:async';

import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_member.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_presence.dart';
import 'package:domodachi/features/chat/presentation/bloc/room/chat_message_list_bloc.dart';
import 'package:domodachi/features/chat/presentation/bloc/room/chat_message_list_event.dart';
import 'package:domodachi/features/chat/presentation/bloc/room/chat_message_list_state.dart';
import 'package:domodachi/features/chat/presentation/bloc/room/chat_timeline_entry.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/chat_composer_cubit.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/chat_composer_state.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/chat_room_session_cubit.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/chat_room_session_state.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/room_member_friend_cubit.dart';
import 'package:domodachi/features/chat/presentation/cubit/room/room_member_friend_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupChatRoomPage extends StatelessWidget {
  const GroupChatRoomPage({super.key, required this.chatRoomId});

  final String chatRoomId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ChatRoomSessionCubit>(param1: chatRoomId),
      child: const _GroupChatRoomPageListener(child: _GroupChatRoomView()),
    );
  }
}

class _GroupChatRoomPageListener extends StatelessWidget {
  const _GroupChatRoomPageListener({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatRoomSessionCubit, ChatRoomSessionState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          },
        ),
      ],
      child: child,
    );
  }
}

class _GroupChatRoomView extends StatelessWidget {
  const _GroupChatRoomView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatRoomSessionCubit, ChatRoomSessionState>(
      builder: (context, state) {
        if ((state.status == ChatRoomSessionStatus.initial ||
                state.isLoading) &&
            state.room == null) {
          return const _GroupChatRoomLoadingView();
        }

        if (state.isNotFound) {
          return _GroupChatRoomUnavailableView(
            icon: Icons.search_off_rounded,
            title: '채팅방을 찾을 수 없어요',
            message: state.errorMessage ?? '삭제되었거나 접근할 수 없는 그룹채팅입니다.',
            actionLabel: '뒤로가기',
            onPressed: () => context.pop(),
          );
        }

        if (state.isFailure && state.room == null) {
          return _GroupChatRoomUnavailableView(
            icon: Icons.cloud_off_rounded,
            title: '채팅방을 불러오지 못했어요',
            message: state.errorMessage ?? '잠시 후 다시 시도해 주세요.',
            actionLabel: '다시 시도',
            onPressed: context.read<ChatRoomSessionCubit>().retry,
          );
        }

        final room = state.room;
        if (room == null) {
          return _GroupChatRoomUnavailableView(
            icon: Icons.forum_outlined,
            title: '채팅방 정보를 준비 중이에요',
            message: '잠시 후 다시 시도해 주세요.',
            actionLabel: '새로고침',
            onPressed: context.read<ChatRoomSessionCubit>().retry,
          );
        }

        return state.isMember
            ? _JoinedGroupChatRoomScaffold(room: room)
            : _GroupChatRoomPreviewView(state: state, room: room);
      },
    );
  }
}

class _JoinedGroupChatRoomScaffold extends StatelessWidget {
  const _JoinedGroupChatRoomScaffold({required this.room});

  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GetIt.instance<ChatMessageListBloc>(param1: room.id),
        ),
        BlocProvider(
          create: (_) => GetIt.instance<ChatComposerCubit>(param1: room.id),
        ),
        BlocProvider(
          create: (context) =>
              GetIt.instance<RoomMemberFriendCubit>()..syncMembers(
                members: context.read<ChatRoomSessionCubit>().state.members,
                currentUserId: Supabase.instance.client.auth.currentUser?.id,
              ),
        ),
      ],
      child: _JoinedGroupChatRoomView(room: room),
    );
  }
}

class _JoinedGroupChatRoomView extends StatelessWidget {
  const _JoinedGroupChatRoomView({required this.room});

  final ChatRoom room;

  Future<bool> _showDeleteConfirmDialog(
    BuildContext context,
    ChatRoom room,
  ) async {
    final result = await showDialog<bool>(
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

    return result ?? false;
  }

  Future<void> _showRoomInfoBottomSheet(
    BuildContext context,
    ChatRoom room,
    ChatRoomSessionState sessionState,
    ChatMessageListState messageState,
  ) {
    final roomMemberFriendCubit = context.read<RoomMemberFriendCubit>();
    final sortedMembers = [...sessionState.members]
      ..sort((a, b) {
        if (a.isHost != b.isHost) {
          return a.isHost ? -1 : 1;
        }

        final aIndex = a.anonymousIndex ?? 1 << 30;
        final bIndex = b.anonymousIndex ?? 1 << 30;
        return aIndex.compareTo(bIndex);
      });
    final latestMessageByUserId = _buildLatestMessageByUserId(
      messageState.items,
    );
    final onlineUserIds = sessionState.presences
        .map((presence) => presence.userId)
        .toSet();

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final description = (room.description ?? '').trim();

        return BlocProvider.value(
          value: roomMemberFriendCubit,
          child: SafeArea(
            child: FractionallySizedBox(
              heightFactor: 0.82,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.title ?? 'Untitled room',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description.isEmpty ? '익명 그룹채팅' : description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Text(
                          '멤버',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${sortedMembers.length}/${room.maxParticipants})',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child:
                          BlocBuilder<
                            RoomMemberFriendCubit,
                            RoomMemberFriendState
                          >(
                            builder: (context, friendState) {
                              return ListView.separated(
                                itemCount: sortedMembers.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final member = sortedMembers[index];
                                  final latestMessage =
                                      latestMessageByUserId[member.userId];
                                  final isOnline = onlineUserIds.contains(
                                    member.userId,
                                  );
                                  return _RoomMemberTile(
                                    member: member,
                                    fallbackIndex: index + 1,
                                    latestMessage: latestMessage,
                                    isOnline: isOnline,
                                    relation:
                                        friendState.relations[member.userId],
                                    isProcessing: friendState.processingUserIds
                                        .contains(member.userId),
                                  );
                                },
                              );
                            },
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: sessionState.canDeleteRoom
                          ? FilledButton.icon(
                              onPressed: sessionState.isLeaving
                                  ? null
                                  : () async {
                                      final confirmed =
                                          await _showDeleteConfirmDialog(
                                            sheetContext,
                                            sessionState.room ?? room,
                                          );
                                      if (!confirmed || !sheetContext.mounted) {
                                        return;
                                      }

                                      final deleted = await sheetContext
                                          .read<ChatRoomSessionCubit>()
                                          .deleteRoom();
                                      if (deleted && sheetContext.mounted) {
                                        sheetContext.pop();
                                        context.pop(true);
                                      }
                                    },
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('채팅방 삭제'),
                            )
                          : OutlinedButton.icon(
                              onPressed:
                                  sessionState.canLeave &&
                                      !sessionState.isLeaving
                                  ? () async {
                                      final left = await sheetContext
                                          .read<ChatRoomSessionCubit>()
                                          .leave();
                                      if (left && sheetContext.mounted) {
                                        sheetContext.pop();
                                        context.pop();
                                      }
                                    }
                                  : null,
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('채팅방 나가기'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, ChatMessage> _buildLatestMessageByUserId(
    List<ChatMessage> messages,
  ) {
    final latestMessageByUserId = <String, ChatMessage>{};

    for (final message in messages) {
      final previous = latestMessageByUserId[message.senderId];
      if (previous == null || message.createdAt.isAfter(previous.createdAt)) {
        latestMessageByUserId[message.senderId] = message;
      }
    }

    return latestMessageByUserId;
  }

  Future<void> _refreshTimeline(BuildContext context) async {
    final bloc = context.read<ChatMessageListBloc>();
    final currentState = bloc.state;
    if (currentState.isLoading || currentState.isRefreshing) {
      return;
    }

    bloc.refreshList();

    await bloc.stream.firstWhere(
      (state) => !state.isLoading && !state.isRefreshing,
    );
  }

  bool _handleTimelineScroll(
    ScrollNotification notification,
    BuildContext context,
    ChatMessageListState state,
  ) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final reachedOlderMessagesThreshold =
        notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 200;
    if (reachedOlderMessagesThreshold) {
      context.read<ChatMessageListBloc>().fetchMore();
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return MultiBlocListener(
      listeners: [
        BlocListener<ChatRoomSessionCubit, ChatRoomSessionState>(
          listenWhen: (previous, current) =>
              previous.members != current.members,
          listener: (context, state) {
            context.read<RoomMemberFriendCubit>().syncMembers(
              members: state.members,
              currentUserId: currentUserId,
            );
          },
        ),
        BlocListener<ChatComposerCubit, ChatComposerState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          },
        ),
        BlocListener<ChatMessageListBloc, ChatMessageListState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null &&
              current.hasData,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          },
        ),
        BlocListener<ChatMessageListBloc, ChatMessageListState>(
          listenWhen: (previous, current) =>
              previous.roomDeleted != current.roomDeleted &&
              current.roomDeleted,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(const SnackBar(content: Text('채팅방이 삭제되었어요.')));

            if (context.mounted) {
              context.pop(true);
            }
          },
        ),
        BlocListener<RoomMemberFriendCubit, RoomMemberFriendState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            context.read<RoomMemberFriendCubit>().clearFeedback();
          },
        ),
        BlocListener<RoomMemberFriendCubit, RoomMemberFriendState>(
          listenWhen: (previous, current) =>
              previous.noticeMessage != current.noticeMessage &&
              current.noticeMessage != null,
          listener: (context, state) {
            final messenger = ScaffoldMessenger.of(context);
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.noticeMessage!)));
            context.read<RoomMemberFriendCubit>().clearFeedback();
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: BlocBuilder<ChatRoomSessionCubit, ChatRoomSessionState>(
            builder: (context, state) {
              final currentRoom = state.room ?? room;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentRoom.title ?? 'Untitled room',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${state.members.length}명 참여 중',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            BlocBuilder<ChatRoomSessionCubit, ChatRoomSessionState>(
              builder: (context, state) => IconButton(
                tooltip: '멤버 보기',
                onPressed: () => _showRoomInfoBottomSheet(
                  context,
                  state.room ?? room,
                  state,
                  context.read<ChatMessageListBloc>().state,
                ),
                icon: const Icon(Icons.people_alt_outlined),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            const _PresenceEventOverlay(),
            Expanded(
              child: BlocBuilder<ChatMessageListBloc, ChatMessageListState>(
                builder: (context, state) {
                  if (state.isLoading && !state.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.isFailure && !state.hasData) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _InlineStatusCard(
                          icon: Icons.cloud_off_outlined,
                          title: '메시지를 불러오지 못했어요',
                          message: state.errorMessage ?? '잠시 후 다시 시도해 주세요.',
                          actionLabel: '다시 시도',
                          onPressed: context
                              .read<ChatMessageListBloc>()
                              .refreshList,
                        ),
                      ),
                    );
                  }

                  final timelineItems = state.timelineItems;
                  if (timelineItems.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: _InlineStatusCard(
                          icon: Icons.forum_outlined,
                          title: '첫 메시지를 남겨보세요',
                          message: '이 방의 첫 대화를 시작하면 여기부터 채팅이 쌓여요.',
                        ),
                      ),
                    );
                  }

                  final showsLoadMoreState =
                      state.isLoadingMore || (state.isFailure && state.hasData);
                  final itemCount =
                      timelineItems.length + (showsLoadMoreState ? 1 : 0);

                  return RefreshIndicator(
                    onRefresh: () => _refreshTimeline(context),
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (notification) =>
                          _handleTimelineScroll(notification, context, state),
                      child: ListView.separated(
                        reverse: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                        itemBuilder: (context, index) {
                          if (index == timelineItems.length) {
                            if (state.isLoadingMore) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Center(
                                  child: SizedBox.square(
                                    dimension: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return _InlineStatusCard(
                              icon: Icons.refresh_rounded,
                              title: '이전 대화를 더 불러오지 못했어요',
                              message: state.errorMessage ?? '잠시 후 다시 시도해 주세요.',
                              actionLabel: '다시 시도',
                              onPressed: context
                                  .read<ChatMessageListBloc>()
                                  .fetchMore,
                            );
                          }

                          final timelineItem = timelineItems[index];
                          return switch (timelineItem) {
                            ChatTimelineEntryMessage(:final message) =>
                              _MessageBubble(
                                message: message,
                                isMine:
                                    currentUserId != null &&
                                    message.senderId == currentUserId,
                              ),
                            ChatTimelineEntryEvent(:final event) =>
                              _SystemTimelineEvent(event: event),
                          };
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: itemCount,
                      ),
                    ),
                  );
                },
              ),
            ),
            const _ChatComposerBar(),
          ],
        ),
      ),
    );
  }
}

class _RoomMemberTile extends StatelessWidget {
  const _RoomMemberTile({
    required this.member,
    required this.fallbackIndex,
    required this.latestMessage,
    required this.isOnline,
    required this.relation,
    required this.isProcessing,
  });

  final ChatRoomMember member;
  final int fallbackIndex;
  final ChatMessage? latestMessage;
  final bool isOnline;
  final RoomMemberFriendRelation? relation;
  final bool isProcessing;

  String get _anonymousName => '익명 ${member.anonymousIndex ?? fallbackIndex}';

  Future<void> _handleFriendAction(BuildContext context) async {
    final currentRelation = relation;
    if (currentRelation == null || isProcessing) {
      return;
    }

    switch (currentRelation.status) {
      case RoomMemberFriendStatus.canSendRequest:
        await context.read<RoomMemberFriendCubit>().sendFriendRequest(
          member: member,
          anonymousName: _anonymousName,
        );
      case RoomMemberFriendStatus.requestReceived:
        await context.read<RoomMemberFriendCubit>().acceptFriendRequest(
          member: member,
          anonymousName: _anonymousName,
        );
      case RoomMemberFriendStatus.self:
      case RoomMemberFriendStatus.requestSent:
      case RoomMemberFriendStatus.friend:
        return;
    }
  }

  Widget? _buildTrailing(BuildContext context) {
    final currentRelation = relation;
    if (currentRelation == null ||
        currentRelation.status == RoomMemberFriendStatus.self) {
      return null;
    }

    if (isProcessing) {
      return const SizedBox.square(
        dimension: 40,
        child: Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return switch (currentRelation.status) {
      RoomMemberFriendStatus.canSendRequest => IconButton.filledTonal(
        onPressed: () => _handleFriendAction(context),
        tooltip: '친구 요청 보내기',
        icon: const Icon(Icons.person_add_alt_1_rounded),
      ),
      RoomMemberFriendStatus.requestReceived => IconButton.filled(
        onPressed: () => _handleFriendAction(context),
        tooltip: '친구 요청 수락',
        icon: const Icon(Icons.how_to_reg_rounded),
      ),
      RoomMemberFriendStatus.requestSent => IconButton(
        onPressed: null,
        tooltip: '친구 요청 보냄',
        icon: const Icon(Icons.schedule_send_rounded),
      ),
      RoomMemberFriendStatus.friend => IconButton(
        onPressed: null,
        tooltip: '이미 친구',
        icon: const Icon(Icons.check_circle_rounded),
      ),
      RoomMemberFriendStatus.self => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = latestMessage?.content.trim().isNotEmpty == true
        ? latestMessage!.content.trim()
        : '아직 보낸 메시지가 없어요.';

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '${member.anonymousIndex ?? fallbackIndex}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  if (member.isHost) ...[
                    Icon(
                      Icons.workspace_premium_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Expanded(
                    child: Text(
                      _anonymousName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isOnline) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '온라인',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        trailing: _buildTrailing(context),
      ),
    );
  }
}

class _PresenceEventOverlay extends StatefulWidget {
  const _PresenceEventOverlay();

  @override
  State<_PresenceEventOverlay> createState() => _PresenceEventOverlayState();
}

class _PresenceEventOverlayState extends State<_PresenceEventOverlay> {
  Timer? _dismissTimer;
  ChatRoomPresenceEvent? _visibleEvent;

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  void _showEvent(ChatRoomPresenceEvent event) {
    _dismissTimer?.cancel();

    setState(() {
      _visibleEvent = event;
    });

    _dismissTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _visibleEvent = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatRoomSessionCubit, ChatRoomSessionState>(
      listenWhen: (previous, current) =>
          previous.lastPresenceEvent != current.lastPresenceEvent &&
          current.lastPresenceEvent != null,
      listener: (context, state) {
        final event = state.lastPresenceEvent;
        if (event != null) {
          _showEvent(event);
        }
      },
      child: BlocBuilder<ChatRoomSessionCubit, ChatRoomSessionState>(
        builder: (context, state) {
          final event = _visibleEvent;
          final currentUserId = Supabase.instance.client.auth.currentUser?.id;
          if (event == null || event.presence.userId == currentUserId) {
            return const SizedBox.shrink();
          }

          final actor = _resolvePresenceActorLabel(
            members: state.members,
            userId: event.presence.userId,
          );
          final action = switch (event.type) {
            ChatRoomPresenceEventType.joined => '들어왔어요',
            ChatRoomPresenceEventType.left => '나갔어요',
          };

          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _PresenceEventPill(message: '$actor 님이 $action'),
          );
        },
      ),
    );
  }
}

class _PresenceEventPill extends StatelessWidget {
  const _PresenceEventPill({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Container(
          key: ValueKey<String>(message),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            message,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChatComposerBar extends StatefulWidget {
  const _ChatComposerBar();

  @override
  State<_ChatComposerBar> createState() => _ChatComposerBarState();
}

class _ChatComposerBarState extends State<_ChatComposerBar> {
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

  Future<void> _send(BuildContext context) async {
    final message = await context.read<ChatComposerCubit>().send();
    if (!context.mounted || message == null) {
      return;
    }

    context.read<ChatMessageListBloc>().add(
      ChatMessageListEvent.messageReceived(message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatComposerCubit, ChatComposerState>(
      listenWhen: (previous, current) => previous.text != current.text,
      listener: (context, state) {
        if (_controller.text != state.text) {
          _controller.value = _controller.value.copyWith(
            text: state.text,
            selection: TextSelection.collapsed(offset: state.text.length),
            composing: TextRange.empty,
          );
        }
      },
      child: BlocBuilder<ChatComposerCubit, ChatComposerState>(
        builder: (context, state) {
          final colorScheme = Theme.of(context).colorScheme;

          return SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  top: BorderSide(color: colorScheme.outlineVariant),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      onChanged: context.read<ChatComposerCubit>().textChanged,
                      decoration: InputDecoration(
                        hintText: '메시지 보내기',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: state.canSend && !state.isSending
                        ? () => _send(context)
                        : null,
                    icon: state.isSending
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_upward_rounded),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GroupChatRoomPreviewView extends StatelessWidget {
  const _GroupChatRoomPreviewView({required this.state, required this.room});

  final ChatRoomSessionState state;
  final ChatRoom room;

  @override
  Widget build(BuildContext context) {
    final canJoin = state.canJoin;
    final isRestricted = !room.isPublic;
    final isClosed = room.status.name == 'closed';
    final isFull = room.status.name == 'full';

    final title = switch ((isRestricted, isClosed, isFull)) {
      (true, _, _) => '이 채팅방에는 바로 들어갈 수 없어요',
      (_, true, _) => '이 채팅방은 닫혀 있어요',
      (_, _, true) => '정원이 가득 찼어요',
      _ => '이 그룹채팅에 참여할 수 있어요',
    };

    final message = switch ((isRestricted, isClosed, isFull)) {
      (true, _, _) => '비공개 그룹채팅이라 초대나 별도 접근 권한이 필요합니다.',
      (_, true, _) => '종료된 채팅방이라 더 이상 입장할 수 없습니다.',
      (_, _, true) => '누군가 나가기 전까지는 새로 참여할 수 없습니다.',
      _ => '방 설명과 현재 멤버를 확인한 뒤 바로 합류할 수 있어요.',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          room.title ?? 'Untitled room',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _RoomHeroCard(
            room: room,
            members: state.members,
            presences: state.presences,
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            _InlineStatusCard(
              icon: Icons.info_outline_rounded,
              title: '안내',
              message: state.errorMessage!,
            ),
          ],
          const SizedBox(height: 12),
          _InlineStatusCard(
            icon: Icons.login_rounded,
            title: title,
            message: message,
            actionLabel: canJoin
                ? (state.isJoining ? '참여 중...' : '참여하기')
                : '뒤로가기',
            onPressed: canJoin
                ? (state.isJoining
                      ? null
                      : context.read<ChatRoomSessionCubit>().join)
                : () => context.pop(),
          ),
        ],
      ),
    );
  }
}

class _GroupChatRoomLoadingView extends StatelessWidget {
  const _GroupChatRoomLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹채팅')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _GroupChatRoomUnavailableView extends StatelessWidget {
  const _GroupChatRoomUnavailableView({
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('그룹채팅')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _InlineStatusCard(
            icon: icon,
            title: title,
            message: message,
            actionLabel: actionLabel,
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}

class _RoomHeroCard extends StatelessWidget {
  const _RoomHeroCard({
    required this.room,
    required this.members,
    required this.presences,
  });

  final ChatRoom room;
  final List<ChatRoomMember> members;
  final List<ChatRoomPresence> presences;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(
                icon: room.isPublic ? Icons.public_rounded : Icons.lock_rounded,
                label: room.isPublic ? '공개 그룹채팅' : '비공개 그룹채팅',
              ),
              _HeroChip(
                icon: Icons.people_alt_outlined,
                label: '${members.length}/${room.maxParticipants}명',
              ),
              if (room.isHost)
                const _HeroChip(icon: Icons.star_rounded, label: '내가 만든 방'),
              if (presences.isNotEmpty)
                _HeroChip(
                  icon: Icons.circle_rounded,
                  label: '${presences.length}명 접속 중',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            room.title ?? 'Untitled room',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          if ((room.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              room.description!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.86),
                height: 1.4,
              ),
            ),
          ],
          if (room.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              room.tags.take(4).map((tag) => '#$tag').join('   '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.92),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _ParticipantStrip(members: members),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantStrip extends StatelessWidget {
  const _ParticipantStrip({required this.members});

  final List<ChatRoomMember> members;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final visibleMembers = members.take(5).toList(growable: false);

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: List.generate(visibleMembers.length, (index) {
              return Positioned(
                left: index * 26,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: colorScheme.surface,
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: colorScheme.tertiaryContainer,
                    child: Icon(
                      Icons.person_rounded,
                      size: 18,
                      color: colorScheme.onTertiaryContainer,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            visibleMembers.isEmpty
                ? '아직 참여한 멤버가 없어요'
                : '${members.length}명이 익명으로 참여 중이에요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.84),
            ),
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bubbleColor = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final author = isMine ? '나' : _formatAnonymousLabel(message.anonymousIndex);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
              child: Text(
                '$author · ${_formatTime(message.createdAt)}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                message.content,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: textColor,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemTimelineEvent extends StatelessWidget {
  const _SystemTimelineEvent({required this.event});

  final ChatRoomEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final actor = _formatAnonymousLabel(event.anonymousIndex);
    final action = switch (event.type) {
      ChatRoomEventType.joined => '들어왔어요',
      ChatRoomEventType.left => '나갔어요',
      ChatRoomEventType.roomDeleted => '채팅방이 삭제되었어요',
    };

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          event.type == ChatRoomEventType.roomDeleted
              ? action
              : '$actor 님이 $action',
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

String _formatAnonymousLabel(int? anonymousIndex) {
  if (anonymousIndex == null) {
    return '익명';
  }

  return '익명$anonymousIndex';
}

String _resolvePresenceActorLabel({
  required List<ChatRoomMember> members,
  required String userId,
}) {
  for (final member in members) {
    if (member.userId == userId) {
      return _formatAnonymousLabel(member.anonymousIndex);
    }
  }

  return '익명';
}

class _InlineStatusCard extends StatelessWidget {
  const _InlineStatusCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

String _formatTime(DateTime dateTime) {
  final hour = dateTime.hour;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  final period = hour >= 12 ? '오후' : '오전';
  final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$period $hour12:$minute';
}
