import 'dart:async';

import 'package:domodachi/app/router/app_route_path.dart';
import 'package:domodachi/core/error/failure.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room.dart';
import 'package:domodachi/features/chat/domain/use_case/chat_use_cases.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

class GroupChatSearchPage extends StatefulWidget {
  const GroupChatSearchPage({super.key});

  @override
  State<GroupChatSearchPage> createState() => _GroupChatSearchPageState();
}

class _GroupChatSearchPageState extends State<GroupChatSearchPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;
  List<ChatRoom> _results = const <ChatRoom>[];
  List<String> _recentQueries = const <String>[];

  bool get _canSearch => _controller.text.trim().length >= 2 && !_isLoading;

  bool get _showRecentQueries => _controller.text.trim().isEmpty;

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.length < 2) {
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _errorMessage = null;
    });

    try {
      final results = await GetIt.instance<ChatUseCases>().searchGroupChatRooms(
        query: query,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _results = results;
        _isLoading = false;
      });
      await GetIt.instance<ChatUseCases>().saveRecentGroupChatSearchQuery(
        query,
      );
      await _loadRecentQueries();
    } on Failure catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _results = const <ChatRoom>[];
        _isLoading = false;
        _errorMessage = error.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _results = const <ChatRoom>[];
        _isLoading = false;
        _errorMessage = '검색 결과를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.';
      });
    }
  }

  Future<void> _loadRecentQueries() async {
    try {
      final queries = await GetIt.instance<ChatUseCases>()
          .fetchRecentGroupChatSearchQueries();
      if (!mounted) {
        return;
      }

      setState(() {
        _recentQueries = queries;
      });
    } catch (_) {}
  }

  Future<void> _deleteRecentQuery(String query) async {
    try {
      await GetIt.instance<ChatUseCases>().deleteRecentGroupChatSearchQuery(
        query,
      );
      if (!mounted) {
        return;
      }

      setState(() {
        _recentQueries = _recentQueries
            .where((candidate) => candidate != query)
            .toList(growable: false);
      });
    } catch (_) {}
  }

  Future<void> _openRoom(ChatRoom room) async {
    final didDelete = await context.push<bool>(
      AppRoutePath.groupChatRoomPath(room.id),
    );
    if (!mounted || didDelete != true) {
      return;
    }

    setState(() {
      _results = _results
          .where((candidate) => candidate.id != room.id)
          .toList(growable: false);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
    unawaited(_loadRecentQueries());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: '제목 또는 #해시태그 검색',
                  prefixIcon: IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: '뒤로가기',
                  ),
                  suffixIcon: IconButton(
                    onPressed: _canSearch ? _search : null,
                    icon: const Icon(Icons.search_rounded),
                    tooltip: '검색',
                  ),
                ),
              ),
            ),
            if (_showRecentQueries && _recentQueries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _recentQueries
                        .map((query) {
                          return InputChip(
                            label: Text(query),
                            onPressed: () {
                              _controller.text = query;
                              _controller.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(offset: query.length),
                                  );
                              _search();
                            },
                            onDeleted: () => _deleteRecentQuery(query),
                          );
                        })
                        .toList(growable: false),
                  ),
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _buildBody(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _GroupChatSearchEmptyState(
        key: const ValueKey('search-error'),
        icon: Icons.cloud_off_outlined,
        title: '검색을 완료하지 못했어요',
        message: _errorMessage!,
        actionLabel: '다시 시도',
        onAction: _search,
      );
    }

    if (!_hasSearched) {
      return _GroupChatSearchEmptyState(
        key: ValueKey('search-idle'),
        icon: Icons.travel_explore_outlined,
        title: '검색어를 입력해 보세요',
        message: _recentQueries.isEmpty
            ? '제목이나 #해시태그로 공개 그룹채팅을 찾을 수 있어요.'
            : '최근 검색어를 다시 눌러 바로 찾아볼 수 있어요.',
      );
    }

    if (_results.isEmpty) {
      return _GroupChatSearchEmptyState(
        key: const ValueKey('search-empty'),
        icon: Icons.search_off_rounded,
        title: '검색 결과가 없어요',
        message: '다른 제목이나 #해시태그로 다시 찾아보세요.',
        actionLabel: '다시 검색',
        onAction: () => _focusNode.requestFocus(),
      );
    }

    return ListView.separated(
      key: const ValueKey('search-results'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      itemCount: _results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final room = _results[index];
        return _GroupChatSearchResultTile(
          room: room,
          onTap: () => _openRoom(room),
        );
      },
    );
  }
}

class _GroupChatSearchResultTile extends StatelessWidget {
  const _GroupChatSearchResultTile({required this.room, required this.onTap});

  final ChatRoom room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lastActivity = room.lastMessageAt ?? room.createdAt;
    final summary = room.description ?? '설명이 아직 없는 채팅방입니다.';

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                room.title ?? 'Untitled room',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GroupChatSearchMetaChip(label: _statusLabel(room)),
                  _GroupChatSearchMetaChip(
                    label: '${room.memberCount}/${room.maxParticipants}명',
                  ),
                  _GroupChatSearchMetaChip(
                    label: _formatRelativeTime(lastActivity),
                  ),
                ],
              ),
              if (room.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  room.tags.take(3).map((tag) => '#$tag').join('  '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupChatSearchMetaChip extends StatelessWidget {
  const _GroupChatSearchMetaChip({required this.label});

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

class _GroupChatSearchEmptyState extends StatelessWidget {
  const _GroupChatSearchEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

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

String _statusLabel(ChatRoom room) {
  return switch (room.status.name) {
    'open' => '지금 참여 가능',
    'full' => '정원 마감',
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
