import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// OpenAI configuration using environment variables.
/// Values are provided at runtime by Dreamflow.
const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');

class OpenAIClient {
  const OpenAIClient();

  bool get _isConfigured => apiKey.isNotEmpty && endpoint.isNotEmpty;

  /// Generic chat call that returns the assistant text content.
  Future<String> chat({
    required List<Map<String, dynamic>> messages,
    String model = 'gpt-4o',
    Map<String, dynamic>? responseFormat,
    double temperature = 0.2,
  }) async {
    if (!_isConfigured) {
      debugPrint('OpenAI not configured. Set OPENAI_PROXY_API_KEY and OPENAI_PROXY_ENDPOINT.');
      throw Exception('AI not configured');
    }

    try {
      final uri = Uri.parse(endpoint); // IMPORTANT: endpoint must be full url
      final body = <String, dynamic>{
        'model': model,
        'messages': messages,
        'temperature': temperature,
      };
      if (responseFormat != null) body['response_format'] = responseFormat;

      final res = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        debugPrint('OpenAI error ${res.statusCode}: ${res.body}');
        throw Exception('OpenAI error ${res.statusCode}');
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      if (choices == null || choices.isEmpty) throw Exception('No AI response');
      final msg = choices.first['message'] as Map<String, dynamic>?;
      final content = msg?['content'];
      if (content is String) return content.trim();
      // Some providers return array of content parts
      if (content is List) {
        final textParts = content.whereType<Map<String, dynamic>>()
          .where((p) => p['type'] == 'text')
          .map((p) => (p['text'] ?? '').toString())
          .join('\n');
        return textParts.trim();
      }
      return content?.toString().trim() ?? '';
    } catch (e) {
      debugPrint('OpenAI chat failed: $e');
      rethrow;
    }
  }

  /// Ask the model to output a strict JSON object for task suggestions.
  /// Returns a map with keys: title, description, tags(List<String>).
  Future<Map<String, dynamic>> suggestTaskFields(String contextText) async {
    final system = {
      'role': 'system',
      'content': 'You are a helpful assistant that outputs ONLY a JSON object. '
          'Keys: title (string), description (string), tags (string array). '
          'Output must be a JSON object with those keys.'
    };
    final user = {
      'role': 'user',
      'content': 'Based on the following context, suggest an improved task title, a concise description, '
          'and 2-5 short tags. Context:\n$contextText'
    };

    final content = await chat(
      messages: [system, user],
      model: 'gpt-4o',
      responseFormat: {'type': 'json_object'},
      temperature: 0.4,
    );

    try {
      final jsonMap = jsonDecode(content) as Map<String, dynamic>;
      // Basic validation
      return {
        'title': jsonMap['title']?.toString() ?? '',
        'description': jsonMap['description']?.toString() ?? '',
        'tags': (jsonMap['tags'] is List) ? List<String>.from(jsonMap['tags']) : <String>[],
      };
    } catch (e) {
      debugPrint('Failed to parse AI JSON: $e; raw: $content');
      // Fallback: return empty structure
      return {'title': '', 'description': '', 'tags': <String>[]};
    }
  }

  /// Returns 3-5 short, motivational suggestions tailored to a user's task list.
  Future<List<String>> smartSuggestions(String taskSnapshot) async {
    final sys = {
      'role': 'system',
      'content': 'Output concise bullet suggestions (max 12 words each). '
          'Return one suggestion per line, no numbering.'
    };
    final usr = {
      'role': 'user',
      'content': 'Given this user task snapshot, suggest next-step actions or tips.\n$taskSnapshot'
    };
    final text = await chat(messages: [sys, usr], model: 'gpt-4o', temperature: 0.5);
    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return lines.length > 5 ? lines.take(5).toList() : lines;
  }
}
