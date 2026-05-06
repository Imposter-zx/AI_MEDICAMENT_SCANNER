import 'package:flutter/material.dart';
import 'storage_service.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final StorageService _storage = StorageService();
  bool _enabled = false;
  Map<String, dynamic> _data = {};

  bool get isEnabled => _enabled;
  Map<String, dynamic> get data => _data;

  Future<void> init() async {
    _data = await _storage.getAnalytics();
    _enabled = _data['enabled'] == true;
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    _data['enabled'] = value;
    await _storage.setAnalytics(_data);
  }

  Future<void> trackEvent(String event, {Map<String, dynamic>? params}) async {
    if (!_enabled) return;
    try {
      final events = (_data['events'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      events.add({
        'event': event,
        'params': params ?? {},
        'timestamp': DateTime.now().toIso8601String(),
      });
      if (events.length > 100) {
        events.removeRange(0, events.length - 100);
      }
      _data['events'] = events;
      await _storage.setAnalytics(_data);
    } catch (e) {
      debugPrint('Analytics error: $e');
    }
  }

  Future<void> trackFeatureUsage(String feature) async {
    if (!_enabled) return;
    final usage = (_data['featureUsage'] as Map<String, dynamic>?) ?? {};
    usage[feature] = ((usage[feature] as int?) ?? 0) + 1;
    _data['featureUsage'] = usage;
    await _storage.setAnalytics(_data);
  }

  Future<void> trackMedicationSearch(String query) async {
    if (!_enabled) return;
    final searches = (_data['searches'] as List?)?.cast<String>() ?? [];
    searches.add(query);
    if (searches.length > 50) {
      searches.removeRange(0, searches.length - 50);
    }
    _data['searches'] = searches;
    await _storage.setAnalytics(_data);
  }

  Map<String, dynamic> getUsageSummary() {
    final featureUsage = (_data['featureUsage'] is Map) 
        ? (_data['featureUsage'] as Map).cast<String, dynamic>() 
        : <String, dynamic>{};
    return {
      'featureUsage': featureUsage,
      'totalEvents': ((_data['events'] as List?) ?? []).length,
      'totalSearches': ((_data['searches'] as List?) ?? []).length,
    };
  }
}
