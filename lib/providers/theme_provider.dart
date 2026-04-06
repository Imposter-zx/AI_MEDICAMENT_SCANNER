import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Provider for managing app theme
class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  /// Initialize theme from stored preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getInt(_themeModeKey) ?? 0;
      _themeMode = ThemeMode.values[savedTheme];
      _isInitialized = true;
      AppLogger.info('Theme initialized: ${_themeMode.toString()}');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to initialize theme', e);
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, mode.index);
      _themeMode = mode;
      AppLogger.info('Theme changed to: ${mode.toString()}');
      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to save theme mode', e);
    }
  }
}
