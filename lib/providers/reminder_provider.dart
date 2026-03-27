import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reminder_model.dart';

class ReminderProvider with ChangeNotifier {
  List<MedicationReminder> _reminders = [];
  bool _isLoading = true;

  List<MedicationReminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  ReminderProvider() {
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getStringList('medication_reminders') ?? [];
    
    _reminders = remindersJson
        .map((item) => MedicationReminder.fromMap(json.decode(item)))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(MedicationReminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> toggleReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isActive = !_reminders[index].isActive;
      await _saveReminders();
      notifyListeners();
    }
  }

  Future<void> markAsTaken(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].lastTaken = DateTime.now();
      await _saveReminders();
      notifyListeners();
    }
  }

  Future<void> deleteReminder(String id) async {
    _reminders.removeWhere((r) => r.id == id);
    await _saveReminders();
    notifyListeners();
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = _reminders
        .map((item) => json.encode(item.toMap()))
        .toList();
    await prefs.setStringList('medication_reminders', remindersJson);
  }
}
