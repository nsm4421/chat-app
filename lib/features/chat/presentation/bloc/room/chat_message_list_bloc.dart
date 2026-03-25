import 'dart:async';

import 'package:domodachi/core/error/failure.dart';
import 'package:domodachi/features/chat/domain/entity/chat_message.dart';
import 'package:domodachi/features/chat/domain/entity/chat_room_event.dart';
import 'package:domodachi/features/chat/domain/use_case/chat_use_cases.dart';
import 'package:domodachi/features/chat/presentation/bloc/room/chat_message_list_event.dart';
import 'package:domodachi/features/chat/presentation/bloc/room/chat_message_list_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatMessageListBloc
    extends Bloc<ChatMessageListEvent, ChatMessageListState> {
  ChatMessageListBloc(this._chatUseCases, @factoryParam this._chatRoomId)
    : super(ChatMessageListState.initial()) {
    on<ChatMessageListInitialized>(_onInitialized);
    on<ChatMessageListRefreshRequested>(_onRefreshRequested);
    on<ChatMessageListFetchMoreRequested>(_onFetchMoreRequested);
    on<ChatMessageListMessageReceived>(_onMessageReceived);
    on<ChatMessageListRoomEventReceived>(_onRoomEventReceived);
    on<ChatMessageListMessageDeleted>(_onMessageDeleted);
    on<ChatMessageListSubscriptionFailed>(_onSubscriptionFailed);

    initialize();
  }

  static const _pageSize = 50;

  final ChatUseCases _chatUseCases;
  final String _chatRoomId;

  StreamSubscription<ChatMessage>? _newMessageSubscription;
  StreamSubscription<ChatRoomEvent>? _newEventSubscription;

  void initialize() {
    add(ChatMessageListEvent.initialize(_chatRoomId));
  }

  void refreshList() {
    add(const ChatMessageListEvent.refreshRequested());
  }

  void fetchMore() {
    add(const ChatMessageListEvent.fetchMoreRequested());
  }

  void removeMessageLocally(String chatMessageId) {
    add(ChatMessageListEvent.messageDeleted(chatMessageId));
  }

  Future<void> deleteMessage(String chatMessageId) async {
    await _chatUseCases.deleteChatMessage(chatMessageId);
    removeMessageLocally(chatMessageId);
  }

  Future<void> _onInitialized(
    ChatMessageListInitialized event,
    Emitter<ChatMessageListState> emit,
  ) async {
    await _newMessageSubscription?.cancel();
    await _newEventSubscription?.cancel();

    emit(
      ChatMessageListState(
        status: ChatMessageListStatus.loading,
        chatRoomId: event.chatRoomId,
      ),
    );

    await _loadFirstPage(event.chatRoomId, emit);
    _bindRealtime(event.chatRoomId);
  }

  Future<void> _onRefreshRequested(
    ChatMessageListRefreshRequested event,
    Emitter<ChatMessageListState> emit,
  ) async {
    final chatRoomId = state.chatRoomId;
    if (chatRoomId == null || state.isLoading || state.isRefreshing) {
      return;
    }

    emit(
      state.copyWith(
        status: state.hasData
            ? ChatMessageListStatus.refreshing
            : ChatMessageListStatus.loading,
        errorMessage: null,
      ),
    );

    await _loadFirstPage(chatRoomId, emit);
  }

  Future<void> _onFetchMoreRequested(
    ChatMessageListFetchMoreRequested event,
    Emitter<ChatMessageListState> emit,
  ) async {
    final chatRoomId = state.chatRoomId;
    if (chatRoomId == null ||
        state.isLoading ||
        state.isRefreshing ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    emit(
      state.copyWith(
        status: ChatMessageListStatus.loadingMore,
        errorMessage: null,
      ),
    );

    try {
      final messagesFuture = _chatUseCases.fetchChatMessages(
        chatRoomId: chatRoomId,
        limit: _pageSize,
        cursor: state.nextCursor,
      );
      final eventsFuture = _chatUseCases.fetchChatRoomEvents(
        chatRoomId: chatRoomId,
        limit: _pageSize,
        cursor: state.nextCursor,
      );
      final messages = await messagesFuture;
      final events = await eventsFuture;
      final nextCursor = _resolveNextCursor(
        items: [...state.items, ...messages],
        events: [...state.events, ...events],
      );

      emit(
        state.copyWith(
          items: _mergeMessages(state.items, messages),
          events: _mergeEvents(state.events, events),
          nextCursor: nextCursor,
          hasMore:
              (messages.length >= _pageSize || events.length >= _pageSize) &&
              nextCursor != null,
          status: ChatMessageListStatus.success,
        ),
      );
    } on Failure catch (error) {
      emit(
        state.copyWith(
          status: ChatMessageListStatus.failure,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ChatMessageListStatus.failure,
          errorMessage: '메시지를 더 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  void _onMessageReceived(
    ChatMessageListMessageReceived event,
    Emitter<ChatMessageListState> emit,
  ) {
    final existingIndex = state.items.indexWhere(
      (message) => message.id == event.message.id,
    );

    if (existingIndex >= 0) {
      final nextItems = [...state.items];
      nextItems[existingIndex] = event.message;
      if (listEquals(nextItems, state.items)) {
        return;
      }

      emit(state.copyWith(items: nextItems));
      return;
    }

    emit(
      state.copyWith(
        items: [event.message, ...state.items],
        status: ChatMessageListStatus.success,
      ),
    );
  }

  void _onRoomEventReceived(
    ChatMessageListRoomEventReceived event,
    Emitter<ChatMessageListState> emit,
  ) {
    if (event.event.type == ChatRoomEventType.roomDeleted) {
      emit(
        state.copyWith(
          roomDeleted: true,
          status: ChatMessageListStatus.success,
        ),
      );
      return;
    }

    final existingIndex = state.events.indexWhere(
      (roomEvent) => roomEvent.id == event.event.id,
    );

    if (existingIndex >= 0) {
      final nextEvents = [...state.events];
      nextEvents[existingIndex] = event.event;
      if (listEquals(nextEvents, state.events)) {
        return;
      }

      emit(state.copyWith(events: nextEvents));
      return;
    }

    emit(
      state.copyWith(
        events: [event.event, ...state.events],
        status: ChatMessageListStatus.success,
      ),
    );
  }

  void _onMessageDeleted(
    ChatMessageListMessageDeleted event,
    Emitter<ChatMessageListState> emit,
  ) {
    final nextItems = state.items
        .where((message) => message.id != event.chatMessageId)
        .toList(growable: false);

    if (listEquals(nextItems, state.items)) {
      return;
    }

    emit(state.copyWith(items: nextItems));
  }

  void _onSubscriptionFailed(
    ChatMessageListSubscriptionFailed event,
    Emitter<ChatMessageListState> emit,
  ) {
    emit(state.copyWith(errorMessage: event.message));
  }

  Future<void> _loadFirstPage(
    String chatRoomId,
    Emitter<ChatMessageListState> emit,
  ) async {
    try {
      final messagesFuture = _chatUseCases.fetchChatMessages(
        chatRoomId: chatRoomId,
        limit: _pageSize,
      );
      final eventsFuture = _chatUseCases.fetchChatRoomEvents(
        chatRoomId: chatRoomId,
        limit: _pageSize,
      );
      final messages = await messagesFuture;
      final events = await eventsFuture;
      final nextCursor = _resolveNextCursor(items: messages, events: events);

      emit(
        ChatMessageListState(
          status: ChatMessageListStatus.success,
          chatRoomId: chatRoomId,
          items: messages,
          events: events,
          nextCursor: nextCursor,
          hasMore:
              (messages.length >= _pageSize || events.length >= _pageSize) &&
              nextCursor != null,
          roomDeleted: false,
        ),
      );
    } on Failure catch (error) {
      emit(
        ChatMessageListState(
          status: ChatMessageListStatus.failure,
          chatRoomId: chatRoomId,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        ChatMessageListState(
          status: ChatMessageListStatus.failure,
          chatRoomId: chatRoomId,
          errorMessage: '메시지 목록을 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
        ),
      );
    }
  }

  void _bindRealtime(String chatRoomId) {
    _newMessageSubscription = _chatUseCases
        .watchNewChatMessages(chatRoomId: chatRoomId)
        .listen(
          (message) => add(ChatMessageListEvent.messageReceived(message)),
          onError: (Object error) {
            if (error is Failure) {
              add(ChatMessageListEvent.subscriptionFailed(error.message));
              return;
            }

            add(
              const ChatMessageListEvent.subscriptionFailed(
                '실시간 메시지를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
              ),
            );
          },
        );

    _newEventSubscription = _chatUseCases
        .watchNewChatRoomEvents(chatRoomId: chatRoomId)
        .listen(
          (event) => add(ChatMessageListEvent.roomEventReceived(event)),
          onError: (Object error) {
            if (error is Failure) {
              add(ChatMessageListEvent.subscriptionFailed(error.message));
              return;
            }

            add(
              const ChatMessageListEvent.subscriptionFailed(
                '실시간 채팅 이벤트를 불러오지 못했어요. 잠시 후 다시 시도해 주세요.',
              ),
            );
          },
        );
  }

  List<ChatMessage> _mergeMessages(
    List<ChatMessage> current,
    List<ChatMessage> incoming,
  ) {
    final messagesById = <String, ChatMessage>{
      for (final message in current) message.id: message,
    };

    for (final message in incoming) {
      messagesById[message.id] = message;
    }

    final merged = messagesById.values.toList(growable: false);
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  List<ChatRoomEvent> _mergeEvents(
    List<ChatRoomEvent> current,
    List<ChatRoomEvent> incoming,
  ) {
    final eventsById = <String, ChatRoomEvent>{
      for (final event in current) event.id: event,
    };

    for (final event in incoming) {
      eventsById[event.id] = event;
    }

    final merged = eventsById.values.toList(growable: false);
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  String? _resolveNextCursor({
    required List<ChatMessage> items,
    required List<ChatRoomEvent> events,
  }) {
    DateTime? oldestTimestamp;

    if (items.isNotEmpty) {
      oldestTimestamp = items.last.createdAt;
    }

    if (events.isNotEmpty) {
      final oldestEventTimestamp = events.last.createdAt;
      if (oldestTimestamp == null ||
          oldestEventTimestamp.isBefore(oldestTimestamp)) {
        oldestTimestamp = oldestEventTimestamp;
      }
    }

    return oldestTimestamp?.toIso8601String();
  }

  @override
  Future<void> close() async {
    await _newMessageSubscription?.cancel();
    await _newEventSubscription?.cancel();
    return super.close();
  }
}
