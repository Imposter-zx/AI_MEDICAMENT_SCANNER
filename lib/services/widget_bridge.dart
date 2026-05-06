import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

class WidgetBridge {
  static const MethodChannel _channel = MethodChannel('com.aimedic.app/widgets');

  static Future<void> updateWidget(Map<String, String> data) async {
    try {
      await _channel.invokeMethod('updateWidget', data);
      AppLogger.info('Widget update triggered');
    } on PlatformException catch (e) {
      AppLogger.error('Failed to update widget', e);
    }
  }

  static Future<void> setNextDosage(String medName, String time) async {
    await updateWidget({
      'title': 'Next Dosage',
      'detail': '$medName at $time',
    });
  }
}
