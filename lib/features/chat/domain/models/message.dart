import 'package:uuid/uuid.dart';

enum MessageRole { user, assistant }
enum MessageStatus { sending, sent, error }

class Message {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final MessageStatus status;
  final String? thinking;
  final bool isTyping;

  Message({
    String? id,
    required this.content,
    required this.role,
    DateTime? timestamp,
    this.status = MessageStatus.sent,
    this.thinking,
    this.isTyping = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Message copyWith({
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    MessageStatus? status,
    String? thinking,
    bool? isTyping,
  }) {
    return Message(
      id: id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      thinking: thinking ?? this.thinking,
      isTyping: isTyping ?? this.isTyping,
    );
  }

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
}
