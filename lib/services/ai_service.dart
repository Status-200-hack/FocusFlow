import 'package:flutter/foundation.dart';
import 'package:focusflow/openai/openai_config.dart';
import 'package:focusflow/models/task_model.dart';

class AiMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  AiMessage({required this.role, required this.content});
}

class AIService extends ChangeNotifier {
  final OpenAIClient _client = const OpenAIClient();
  final List<AiMessage> _messages = [];
  bool _isLoading = false;

  List<AiMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    _messages.add(AiMessage(role: 'user', content: text));
    _isLoading = true;
    notifyListeners();

    try {
      final content = await _client.chat(
        messages: [
          for (final m in _messages) {'role': m.role, 'content': m.content},
        ],
        model: 'gpt-4o',
        temperature: 0.3,
      );
      _messages.add(AiMessage(role: 'assistant', content: content));
    } catch (e) {
      debugPrint('AI chat failed: $e');
      _messages.add(AiMessage(role: 'assistant', content: 'Sorry, I ran into an issue. Please try again.'));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> suggestForTask({String? title, String? description}) async {
    try {
      final context = 'Title: ${title ?? ''}\nDescription: ${description ?? ''}'.trim();
      return await _client.suggestTaskFields(context);
    } catch (e) {
      debugPrint('AI suggestForTask failed: $e');
      return {'title': '', 'description': '', 'tags': <String>[]};
    }
  }

  Future<List<String>> getSmartSuggestions(List<TaskModel> tasks) async {
    try {
      final snapshot = tasks.map((t) => '- ${t.title} [${t.priority.name}] ${t.isCompleted ? '(done)' : ''}').join('\n');
      return await _client.smartSuggestions(snapshot);
    } catch (e) {
      debugPrint('AI smartSuggestions failed: $e');
      return <String>[];
    }
  }
}
