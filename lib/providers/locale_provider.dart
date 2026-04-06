import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Provider for managing app locale/language
class LocaleProvider with ChangeNotifier {
  static const String _languageKey = 'language';
  static const String _defaultLanguage = 'en';

  Locale _locale = const Locale('en');
  bool _isInitialized = false;

  Locale get locale => _locale;
  bool get isInitialized => _isInitialized;

  /// Initialize locale from stored preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey) ?? _defaultLanguage;
      _locale = Locale(languageCode);
      _isInitialized = true;
      AppLogger.info('Locale initialized: $languageCode');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to initialize locale', e);
      _locale = const Locale(_defaultLanguage);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update locale and save to preferences
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, locale.languageCode);
      _locale = locale;
      AppLogger.info('Locale changed to: ${locale.languageCode}');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to save locale', e);
    }
  }

  /// Update locale by language code
  Future<void> setLanguageCode(String languageCode) async {
    if (languageCode.isEmpty) {
      AppLogger.warning('Empty language code provided');
      return;
    }
    await setLocale(Locale(languageCode));
  }
}
