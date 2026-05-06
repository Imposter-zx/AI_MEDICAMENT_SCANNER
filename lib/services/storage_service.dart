import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const String _keyProfiles = 'user_profiles';
  static const String _keyActiveProfile = 'active_profile_id';
  static const String _keyReminders = 'medication_reminders';
  static const String _keyHistory = 'analysis_history';
  static const String _keyAnalytics = 'app_analytics';
  static const String _keySettings = 'app_settings';
  static const String _keyMigration = 'data_migrated_to_secure';

  Future<void> migrateIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final migrated = prefs.getBool(_keyMigration) ?? false;
    if (migrated) return;

    try {
      final profiles = prefs.getStringList(_keyProfiles);
      if (profiles != null && profiles.isNotEmpty) {
        await _secure.write(key: _keyProfiles, value: json.encode(profiles));
      }

      final activeProfile = prefs.getString(_keyActiveProfile);
      if (activeProfile != null) {
        await _secure.write(key: _keyActiveProfile, value: activeProfile);
      }

      final reminders = prefs.getStringList(_keyReminders);
      if (reminders != null && reminders.isNotEmpty) {
        await _secure.write(key: _keyReminders, value: json.encode(reminders));
      }

      final history = prefs.getStringList('analysis_history');
      if (history != null && history.isNotEmpty) {
        await _secure.write(key: _keyHistory, value: json.encode(history));
      }

      await prefs.setBool(_keyMigration, true);
      debugPrint('Migration to secure storage complete');
    } catch (e) {
      debugPrint('Migration error: $e');
    }
  }

  Future<List<String>> getSecureStringList(String key) async {
    final raw = await _secure.read(key: key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) return decoded.cast<String>();
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> setSecureStringList(String key, List<String> value) async {
    await _secure.write(key: key, value: json.encode(value));
  }

  Future<String?> getSecureString(String key) async {
    return await _secure.read(key: key);
  }

  Future<void> setSecureString(String key, String value) async {
    await _secure.write(key: key, value: value);
  }

  Future<void> deleteSecureKey(String key) async {
    await _secure.delete(key: key);
  }

  Future<void> deleteAllSecure() async {
    await _secure.deleteAll();
  }

  Future<List<String>> getProfiles() => getSecureStringList(_keyProfiles);
  Future<void> setProfiles(List<String> profiles) => setSecureStringList(_keyProfiles, profiles);
  Future<String?> getActiveProfileId() => getSecureString(_keyActiveProfile);
  Future<void> setActiveProfileId(String id) => setSecureString(_keyActiveProfile, id);

  Future<List<String>> getReminders() => getSecureStringList(_keyReminders);
  Future<void> setReminders(List<String> reminders) => setSecureStringList(_keyReminders, reminders);

  Future<List<String>> getHistory() => getSecureStringList(_keyHistory);
  Future<void> setHistory(List<String> history) => setSecureStringList(_keyHistory, history);

  Future<Map<String, dynamic>> getSettings() async {
    final raw = await _secure.read(key: _keySettings);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> setSettings(Map<String, dynamic> settings) async {
    await _secure.write(key: _keySettings, value: json.encode(settings));
  }

  Future<Map<String, dynamic>> getAnalytics() async {
    final raw = await _secure.read(key: _keyAnalytics);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> setAnalytics(Map<String, dynamic> data) async {
    await _secure.write(key: _keyAnalytics, value: json.encode(data));
  }

  Future<String> exportAllData() async {
    final data = {
      'profiles': await getProfiles(),
      'activeProfileId': await getActiveProfileId(),
      'reminders': await getReminders(),
      'history': await getHistory(),
      'settings': await getSettings(),
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
    };
    return json.encode(data);
  }

  Future<bool> importData(String jsonString) async {
    try {
      final decoded = json.decode(jsonString);
      if (decoded is! Map) return false;
      final data = decoded.cast<String, dynamic>();

      if (data['profiles'] != null) {
        await setProfiles(List<String>.from(data['profiles']));
      }
      if (data['activeProfileId'] != null) {
        await setActiveProfileId(data['activeProfileId'] as String);
      }
      if (data['reminders'] != null) {
        await setReminders(List<String>.from(data['reminders']));
      }
      if (data['history'] != null) {
        await setHistory(List<String>.from(data['history']));
      }
      if (data['settings'] != null) {
        final settingsMap = data['settings'];
        if (settingsMap is Map) {
          await setSettings(settingsMap.cast<String, dynamic>());
        }
      }

      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }
}
