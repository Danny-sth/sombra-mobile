import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

class SombraApi {
  final Dio _dio;
  final String baseUrl;
  final String sessionId;

  SombraApi({
    required this.baseUrl,
    required this.sessionId,
  }) : _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'X-Session-Id': sessionId,
          },
        ));

  /// Send chat message and get response
  Future<ChatResponse> sendMessage(String query) async {
    try {
      final response = await _dio.post(
        '/api/chat',
        data: {
          'query': query,
          'sessionId': sessionId,
        },
      );

      return ChatResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw SombraApiException(
        message: e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Stream thinking updates via SSE
  Stream<ThinkingEvent> streamThinking(String sessionId) async* {
    try {
      final response = await _dio.get(
        '/api/thinking/stream/$sessionId',
        options: Options(
          responseType: ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
      );

      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);

        while (buffer.contains('\n\n')) {
          final eventEnd = buffer.indexOf('\n\n');
          final eventData = buffer.substring(0, eventEnd);
          buffer = buffer.substring(eventEnd + 2);

          if (eventData.startsWith('data: ')) {
            final jsonStr = eventData.substring(6);
            try {
              final json = jsonDecode(jsonStr);
              yield ThinkingEvent.fromJson(json);
            } catch (_) {}
          }
        }
      }
    } on DioException catch (e) {
      throw SombraApiException(
        message: e.message ?? 'Stream error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  /// Get system version
  Future<String> getVersion() async {
    final response = await _dio.get('/api/system/version');
    return response.data['version'] ?? 'unknown';
  }
}

class ChatResponse {
  final String response;
  final String? thinking;
  final int? tokensUsed;

  ChatResponse({
    required this.response,
    this.thinking,
    this.tokensUsed,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      response: json['response'] ?? '',
      thinking: json['thinking'],
      tokensUsed: json['tokensUsed'],
    );
  }
}

class ThinkingEvent {
  final String type;
  final String? content;
  final String? toolName;
  final Map<String, dynamic>? toolInput;

  ThinkingEvent({
    required this.type,
    this.content,
    this.toolName,
    this.toolInput,
  });

  factory ThinkingEvent.fromJson(Map<String, dynamic> json) {
    return ThinkingEvent(
      type: json['type'] ?? 'unknown',
      content: json['content'],
      toolName: json['toolName'],
      toolInput: json['toolInput'],
    );
  }
}

class SombraApiException implements Exception {
  final String message;
  final int? statusCode;

  SombraApiException({required this.message, this.statusCode});

  @override
  String toString() => 'SombraApiException: $message (status: $statusCode)';
}
