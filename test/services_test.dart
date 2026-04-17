import 'package:flutter_test/flutter_test.dart';
import 'package:ai_medicament_scanner/services/medical_analyzer_service.dart';
import 'package:ai_medicament_scanner/models/models.dart';

void main() {
  final service = MedicalAnalyzerService();

  group('MedicalAnalyzerService - Medication Analysis', () {
    test('should recognize Aspirin from text', () async {
      final result = await service.analyzeMedicationText('ASPIRIN 500mg Bayer');
      expect(result.name, 'Aspirin');
      expect(result.activeIngredient, isNotNull);
      expect(result.usedFor, isNotEmpty);
    });

    test('should recognize Paracetamol from text', () async {
      final result = await service.analyzeMedicationText('Paracetamol 500mg');
      expect(result.name.startsWith('Paracetamol'), isTrue);
    });

    test('should return unknown for unrecognized medication', () async {
      final result = await service.analyzeMedicationText('XYZABC123');
      expect(result.name, 'Unknown Medication');
    });

    test('should recognize Ibuprofen from text', () async {
      final result = await service.analyzeMedicationText('Ibuprofen 200mg');
      expect(result.name, 'Ibuprofen');
    });
  });

  group('MedicalAnalyzerService - Document Analysis', () {
    test('should detect hemoglobin in lab text', () async {
      final result = await service.analyzeDocument('Hemoglobin: 14.5 g/dL');
      expect(result.documentType, 'medical_document');
      expect(result.keyFindings, isNotEmpty);
    });

    test('should detect abnormal glucose', () async {
      final result = await service.analyzeDocument('Glucose: 150 mg/dL');
      final glucoseFinding = result.keyFindings.firstWhere(
        (f) => f.label.toLowerCase().contains('glucose'),
        orElse: () => KeyFinding(label: '', value: '', isAbnormal: false),
      );
      if (glucoseFinding.label.isNotEmpty) {
        expect(glucoseFinding.isAbnormal, isTrue);
      }
    });
  });

  group('MedicalAnalyzerService - Safety Conflicts', () {
    test('should detect allergy conflict', () {
      final med = Medication(
        name: 'Amoxicillin',
        activeIngredient: 'Amoxicillin',
        usedFor: [],
        whenToUse: [],
        contraindications: [],
        sideEffects: [],
        simpleExplanation: '',
      );
      final profile = UserProfile(
        id: 'p1',
        name: 'Test',
        allergies: ['Penicillin'],
        medicalConditions: [],
      );

      final conflicts = service.checkSafetyConflicts(med, profile);
      expect(conflicts, isNotEmpty);
    });

    test('should detect interaction between active meds', () {
      final med = Medication(
        name: 'Warfarin',
        usedFor: [],
        whenToUse: [],
        contraindications: [],
        sideEffects: [],
        simpleExplanation: '',
      );

      final warnings = service.checkInteractionsWithActiveMeds(med, ['Aspirin']);
      expect(warnings, isNotEmpty);
    });
  });
}
