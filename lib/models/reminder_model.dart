import 'package:flutter/material.dart';

class MedicationReminder {
  final String id;
  final String medicationName;
  final TimeOfDay time;
  final String dosage;
  final List<int> daysOfWeek; // 1 = Monday, 7 = Sunday
  bool isActive;
  DateTime? lastTaken;

  MedicationReminder({
    required this.id,
    required this.medicationName,
    required this.time,
    required this.dosage,
    this.daysOfWeek = const [1, 2, 3, 4, 5, 6, 7],
    this.isActive = true,
    this.lastTaken,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationName': medicationName,
      'hour': time.hour,
      'minute': time.minute,
      'dosage': dosage,
      'daysOfWeek': daysOfWeek,
      'isActive': isActive,
      'lastTaken': lastTaken?.toIso8601String(),
    };
  }

  factory MedicationReminder.fromMap(Map<String, dynamic> map) {
    return MedicationReminder(
      id: map['id'] ?? '',
      medicationName: map['medicationName'] ?? '',
      time: TimeOfDay(
        hour: map['hour'] ?? 0,
        minute: map['minute'] ?? 0,
      ),
      dosage: map['dosage'] ?? '',
      daysOfWeek: map['daysOfWeek'] != null
          ? List<int>.from(map['daysOfWeek'])
          : const [1, 2, 3, 4, 5, 6, 7],
      isActive: map['isActive'] ?? true,
      lastTaken: map['lastTaken'] != null ? DateTime.parse(map['lastTaken']) : null,
    );
  }
}
