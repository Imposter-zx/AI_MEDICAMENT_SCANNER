import 'package:flutter_test/flutter_test.dart';
import 'package:ai_medicament_scanner/models/models.dart';

void main() {
  group('Medication Model', () {
    test('toMap and fromMap should be consistent', () {
      final med = Medication(
        name: 'Aspirin',
        activeIngredient: 'Acetylsalicylic Acid',
        manufacturer: 'Bayer',
        usedFor: ['Pain relief', 'Fever reduction'],
        whenToUse: ['Take with food'],
        contraindications: ['Allergy to aspirin'],
        dosage: '1 tablet',
        sideEffects: ['Stomach upset'],
        simpleExplanation: 'Pain reliever',
        requiresPrescription: false,
      );

      final map = med.toMap();
      final restored = Medication.fromMap(map);

      expect(restored.name, med.name);
      expect(restored.activeIngredient, med.activeIngredient);
      expect(restored.usedFor, med.usedFor);
      expect(restored.dosage, med.dosage);
      expect(restored.requiresPrescription, med.requiresPrescription);
    });

    test('should handle null optional fields', () {
      final med = Medication(
        name: 'Unknown Med',
        usedFor: ['General use'],
        whenToUse: [],
        contraindications: [],
        sideEffects: [],
        simpleExplanation: 'A medication',
      );

      final map = med.toMap();
      final restored = Medication.fromMap(map);

      expect(restored.activeIngredient, isNull);
      expect(restored.manufacturer, isNull);
      expect(restored.dosage, isNull);
      expect(restored.imagePath, isNull);
    });
  });

  group('MedicalDocument Model', () {
    test('toMap and fromMap should be consistent', () {
      final doc = MedicalDocument(
        documentType: 'lab_report',
        extractedText: 'Blood test results',
        keyFindings: [
          KeyFinding(
            label: 'Hemoglobin',
            value: '14.5',
            normalRange: '12.0-16.0',
            isAbnormal: false,
          ),
        ],
        abnormalValues: [],
        recommendations: ['Continue healthy diet'],
        dateCreated: DateTime(2026, 3, 15),
      );

      final map = doc.toMap();
      final restored = MedicalDocument.fromMap(map);

      expect(restored.documentType, doc.documentType);
      expect(restored.extractedText, doc.extractedText);
      expect(restored.keyFindings.length, 1);
      expect(restored.keyFindings[0].label, 'Hemoglobin');
      expect(restored.abnormalValues, isEmpty);
      expect(restored.dateCreated, DateTime(2026, 3, 15));
    });
  });

  group('KeyFinding Model', () {
    test('toMap and fromMap should be consistent', () {
      final finding = KeyFinding(
        label: 'Glucose',
        value: '120',
        normalRange: '70-100',
        isAbnormal: true,
        interpretation: 'Slightly elevated',
      );

      final map = finding.toMap();
      final restored = KeyFinding.fromMap(map);

      expect(restored.label, 'Glucose');
      expect(restored.value, '120');
      expect(restored.isAbnormal, isTrue);
      expect(restored.interpretation, 'Slightly elevated');
    });
  });

  group('MedicalImagingResult Model', () {
    test('toMap and fromMap should be consistent', () {
      final imaging = MedicalImagingResult(
        imagingType: 'X-Ray',
        bodyPart: 'Chest',
        description: 'Standard chest X-ray',
        observedAreas: ['Lungs', 'Heart'],
        areasOfInterest: ['Right lung opacity'],
        confidenceLevel: 'Medium',
        simpleExplanation: 'Some findings require review',
        requiresUrgentReview: true,
      );

      final map = imaging.toMap();
      final restored = MedicalImagingResult.fromMap(map);

      expect(restored.imagingType, 'X-Ray');
      expect(restored.bodyPart, 'Chest');
      expect(restored.observedAreas.length, 2);
      expect(restored.requiresUrgentReview, isTrue);
    });
  });

  group('HistoryItem Model', () {
    test('toMap and fromMap should work for medication type', () {
      final med = Medication(
        name: 'Paracetamol',
        usedFor: ['Pain'],
        whenToUse: ['As needed'],
        contraindications: [],
        sideEffects: [],
        simpleExplanation: 'Pain reliever',
      );

      final item = HistoryItem(
        id: '123',
        userId: 'user1',
        timestamp: DateTime(2026, 3, 30),
        type: 'medication',
        data: med,
      );

      final map = item.toMap();
      final restored = HistoryItem.fromMap(map);

      expect(restored.id, '123');
      expect(restored.type, 'medication');
      expect(restored.data is Medication, isTrue);
      expect((restored.data as Medication).name, 'Paracetamol');
    });
  });

  group('UserProfile Model', () {
    test('toMap and fromMap should be consistent', () {
      final profile = UserProfile(
        id: 'p1',
        name: 'John',
        age: 30,
        relation: 'Self',
        allergies: ['Penicillin'],
        medicalConditions: ['Diabetes'],
      );

      final map = profile.toMap();
      final restored = UserProfile.fromMap(map);

      expect(restored.id, 'p1');
      expect(restored.name, 'John');
      expect(restored.age, 30);
      expect(restored.allergies, ['Penicillin']);
      expect(restored.medicalConditions, ['Diabetes']);
    });

    test('should handle defaults', () {
      final profile = UserProfile.fromMap({
        'id': 'p2',
        'name': 'Jane',
      });

      expect(profile.relation, 'Self');
      expect(profile.allergies, isEmpty);
      expect(profile.medicalConditions, isEmpty);
    });
  });
}
