import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/providers.dart';
import '../../domain/models/message.dart';

/// Chat messages state
final messagesProvider = StateNotifierProvider<MessagesNotifier, List<Message>>((ref) {
  return MessagesNotifier(ref);
});

class MessagesNotifier extends StateNotifier<List<Message>> {
  final Ref _ref;

  MessagesNotifier(this._ref) : super([]);

  /// Send a message to Sombra
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = Message(
      content: content,
      role: MessageRole.user,
      status: MessageStatus.sent,
    );
    state = [...state, userMessage];

    // Add placeholder for assistant
    final assistantMessage = Message(
      content: '',
      role: MessageRole.assistant,
      status: MessageStatus.sending,
      isTyping: true,
    );
    state = [...state, assistantMessage];

    try {
      final api = _ref.read(sombraApiProvider);
      final response = await api.sendMessage(content);

      // Update assistant message with response
      state = [
        ...state.sublist(0, state.length - 1),
        assistantMessage.copyWith(
          content: response.response,
          thinking: response.thinking,
          status: MessageStatus.sent,
          isTyping: false,
        ),
      ];
    } catch (e) {
      // Update with error
      state = [
        ...state.sublist(0, state.length - 1),
        assistantMessage.copyWith(
          content: 'Ошибка: ${e.toString()}',
          status: MessageStatus.error,
          isTyping: false,
        ),
      ];
    }
  }

  /// Clear all messages
  void clearMessages() {
    state = [];
  }
}
