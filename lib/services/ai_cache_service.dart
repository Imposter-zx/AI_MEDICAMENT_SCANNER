import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class AICacheService {
  static final AICacheService _instance = AICacheService._internal();
  factory AICacheService() => _instance;
  AICacheService._internal();

  static const String _cacheKey = 'ai_response_cache';
  
  // SHA-256 hashing for prompt privacy and key fixed-length
  String _hashPrompt(String prompt) {
    return sha256.convert(utf8.encode(prompt.trim().toLowerCase())).toString();
  }

  Future<String?> getCachedResponse(String prompt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey);
      if (cacheData == null) return null;

      final decoded = jsonDecode(cacheData);
      final Map<String, dynamic> cache = decoded is Map ? decoded.cast<String, dynamic>() : {};
      final hash = _hashPrompt(prompt);
      
      return cache[hash];
    } catch (e) {
      return null;
    }
  }

  Future<void> saveResponse(String prompt, String response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString(_cacheKey);
      
      Map<String, dynamic> cache = {};
      if (cacheData != null) {
        final decoded = jsonDecode(cacheData);
        if (decoded is Map) {
          cache = decoded.cast<String, dynamic>();
        }
      }

      final hash = _hashPrompt(prompt);
      cache[hash] = response;

      await prefs.setString(_cacheKey, jsonEncode(cache));
    } catch (e) {
      // Silently fail on cache write
    }
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }
}
