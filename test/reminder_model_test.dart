import 'package:flutter_test/flutter_test.dart';
import 'package:ai_medicament_scanner/models/reminder_model.dart';
import 'package:flutter/material.dart';

void main() {
  group('MedicationReminder Model', () {
    test('toMap and fromMap should be consistent', () {
      final reminder = MedicationReminder(
        id: 'r1',
        medicationName: 'Aspirin',
        time: const TimeOfDay(hour: 8, minute: 30),
        dosage: '1 tablet',
        daysOfWeek: [1, 2, 3, 4, 5],
        isActive: true,
      );

      final map = reminder.toMap();
      final restored = MedicationReminder.fromMap(map);

      expect(restored.id, 'r1');
      expect(restored.medicationName, 'Aspirin');
      expect(restored.time.hour, 8);
      expect(restored.time.minute, 30);
      expect(restored.dosage, '1 tablet');
      expect(restored.daysOfWeek, [1, 2, 3, 4, 5]);
      expect(restored.isActive, isTrue);
    });

    test('should handle defaults', () {
      final reminder = MedicationReminder.fromMap({
        'id': 'r2',
        'medicationName': 'Ibuprofen',
        'time': {'hour': 12, 'minute': 0},
        'dosage': '2 pills',
      });

      expect(reminder.daysOfWeek, [1, 2, 3, 4, 5, 6, 7]);
      expect(reminder.isActive, isTrue);
      expect(reminder.lastTaken, isNull);
    });

    test('lastTaken should serialize and deserialize', () {
      final taken = DateTime(2026, 3, 30, 8, 30);
      final reminder = MedicationReminder(
        id: 'r3',
        medicationName: 'Metformin',
        time: const TimeOfDay(hour: 9, minute: 0),
        dosage: '500mg',
        lastTaken: taken,
      );

      final map = reminder.toMap();
      final restored = MedicationReminder.fromMap(map);

      expect(restored.lastTaken, taken);
    });
  });
}
