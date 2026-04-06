import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app
class AppLogger {
  static const String _tag = '[AI Medicament]';

  static void info(String message, [dynamic error]) {
    if (kDebugMode) {
      print('$_tag [INFO] $message');
      if (error != null) print('$_tag Error: $error');
    }
  }

  static void warning(String message, [dynamic error]) {
    if (kDebugMode) {
      print('$_tag [WARNING] $message');
      if (error != null) print('$_tag Error: $error');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('$_tag [ERROR] $message');
      if (error != null) print('$_tag Error: $error');
      if (stackTrace != null) print('$_tag StackTrace: $stackTrace');
    }
  }
}
