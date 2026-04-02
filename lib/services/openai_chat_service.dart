// lib/services/openai_chat_service.dart
// Production-ready AI chat service using OpenAI's GPT-3.5-turbo
// Security: API key is stored securely on device (Flutter Secure Storage).

import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class OpenAIChatService {
  static final OpenAIChatService _instance = OpenAIChatService._internal();
  factory OpenAIChatService() => _instance;
  OpenAIChatService._internal();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const String _apiKeyKey = 'openai_api_key';

  Future<void> setApiKey(String key) async {
    await _secure.write(key: _apiKeyKey, value: key);
  }

  Future<String?> getApiKey() async {
    return await _secure.read(key: _apiKeyKey);
  }

  Future<String> getResponse(String userMessage, Map<String, dynamic> context) async {
    if (kIsWeb) {
      throw UnsupportedError('OpenAI chat is not supported on web in this MVP.');
    }
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('OpenAI API key is not configured. Please add it in Settings.');
    }

    final List<Map<String, dynamic>> messages = [
      {
        'role': 'system',
        'content': 'You are a medical AI assistant. Provide concise, safe medical information. Do not diagnose; advise consulting a clinician when necessary. Include a short disclaimer that the information is not a substitute for professional medical advice.'
      }
    ];

    // Optional context: profile/history
    final profile = context['profile'];
    if (profile != null) {
      messages.add({'role': 'user', 'content': 'Patient profile: ${profile.toString()}'});
    }
    final history = context['history'];
    if (history != null && history is List) {
      // Serialize history minimally to avoid large payloads
      messages.add({'role': 'user', 'content': 'History length: ${history.length} items.'});
    }

    messages.add({'role': 'user', 'content': userMessage});

    final payload = {
      'model': 'gpt-3.5-turbo',
      'messages': messages,
      'temperature': 0.6,
      'max_tokens': 1500,
    };

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final resp = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(payload));

    if (resp.statusCode != 200) {
      try {
        final error = jsonDecode(resp.body);
        final message = error['error']?['message'] ?? 'OpenAI API error';
        throw Exception(message);
      } catch (_) {
        throw Exception('OpenAI API error: ${resp.statusCode}');
      }
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final String content = (data['choices']?.first?['message']?['content'] ?? '') as String;
    return content.trim();
  }
}
