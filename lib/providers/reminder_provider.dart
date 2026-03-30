import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/reminder_model.dart';
import '../models/models.dart';
import '../services/notification_service.dart';
import '../services/medical_analyzer_service.dart';
import '../services/storage_service.dart';

class ReminderProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
  List<MedicationReminder> _reminders = [];
  bool _isLoading = true;
  List<String> _activeWarnings = [];

  final NotificationService _notificationService = NotificationService();
  final MedicalAnalyzerService _analyzerService = MedicalAnalyzerService();

  List<MedicationReminder> get reminders => _reminders;
  bool get isLoading => _isLoading;
  List<String> get activeWarnings => _activeWarnings;

  ReminderProvider() {
    init();
  }

  Future<void> init() async {
    await _notificationService.init();
    await _loadReminders();
    _checkAllInteractions();
  }

  Future<void> _loadReminders() async {
    _isLoading = true;
    notifyListeners();

    final remindersJson = await _storage.getReminders();

    _reminders = remindersJson
        .map((item) => MedicationReminder.fromMap(json.decode(item)))
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(MedicationReminder reminder) async {
    _reminders.add(reminder);
    await _saveReminders();
    
    if (reminder.isActive) {
      _scheduleNotification(reminder);
    }
    
    _checkAllInteractions();
    notifyListeners();
  }

  Future<void> toggleReminder(String id) async {
    final index = _reminders.indexWhere((r) => r.id == id);
    if (index != -1) {
      _reminders[index].isActive = !_reminders[index].isActive;
      
      if (_reminders[index].isActive) {
        _scheduleNotification(_reminders[index]);
      } else {
        _notificationService.cancelReminder(id.hashCode);
      }
      
      await _saveReminders();
      _checkAllInteractions();
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
    _notificationService.cancelReminder(id.hashCode);
    await _saveReminders();
    _checkAllInteractions();
    notifyListeners();
  }

  void _scheduleNotification(MedicationReminder reminder) {
    _notificationService.scheduleMedicationReminder(
      id: reminder.id.hashCode,
      title: 'Time for ${reminder.medicationName}',
      body: 'Dosage: ${reminder.dosage}',
      hour: reminder.time.hour,
      minute: reminder.time.minute,
      daysOfWeek: reminder.daysOfWeek,
    );
  }

  void _checkAllInteractions() {
    if (_reminders.isEmpty) {
      _activeWarnings = [];
      return;
    }

    // Convert reminders to a list of medication names for the service
    final activeMedNames = _reminders
        .where((r) => r.isActive)
        .map((r) => r.medicationName)
        .toList();

    // In a real app, we'd have Medication objects for each reminder.
    // For now, we'll check each one against the list of names using the heuristic service.
    Set<String> allWarnings = {};
    for (var reminder in _reminders.where((r) => r.isActive)) {
      // Mocking a Medication object for the check
      final med = Medication(
        name: reminder.medicationName,
        usedFor: [],
        whenToUse: [],
        contraindications: [],
        sideEffects: [],
        simpleExplanation: "",
      );
      
      final otherMeds = activeMedNames.where((name) => name != reminder.medicationName).toList();
      final warnings = _analyzerService.checkInteractionsWithActiveMeds(med, otherMeds);
      allWarnings.addAll(warnings);
    }
    
    _activeWarnings = allWarnings.toList();
  }

  Future<void> _saveReminders() async {
    final remindersJson = _reminders
        .map((item) => json.encode(item.toMap()))
        .toList();
    await _storage.setReminders(remindersJson);
  }

  void clearAll() {
    for (var r in _reminders) {
      _notificationService.cancelReminder(r.id.hashCode);
    }
    _reminders = [];
    _activeWarnings = [];
    notifyListeners();
  }
}
