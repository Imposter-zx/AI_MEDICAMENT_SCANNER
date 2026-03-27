import '../models/models.dart';
import 'EXTENDED_MEDICATIONS_DATABASE.dart';

class MedicalAnalyzerService {
  // Mock medication data
  final Map<String, Medication> _medicationDB = medications;

  Future<Medication> analyzeMedicationText(String text) async {
    // Simulate process delay
    await Future.delayed(const Duration(seconds: 2));

    final normalizedText = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-0\s]'), '');
    
    // Fuzzy matching: check for brand names and generic names
    for (final entry in _medicationDB.entries) {
      final key = entry.key.toLowerCase();
      final name = entry.value.name.toLowerCase();
      final active = entry.value.activeIngredient?.toLowerCase() ?? "";

      // Check for exact word containment to avoid sub-word partial matches (like 'in' matches 'aspirin')
      final words = normalizedText.split(RegExp(r'\s+'));
      if (words.contains(key) || words.contains(name) || words.contains(active)) {
        return entry.value;
      }
      
      // Fallback to substring matching if it's very specific
      if (key.length > 5 && normalizedText.contains(key)) return entry.value;
    }

    return Medication(
      name: "Unknown Medication",
      simpleExplanation: "We couldn't identify this medication in our database.",
      requiresPrescription: false,
      usedFor: [],
      whenToUse: [],
      contraindications: [],
      sideEffects: [],
    );
  }

  Future<MedicalDocument> analyzeDocument(String text) async {
    await Future.delayed(const Duration(seconds: 2));

    final normalizedText = text.toLowerCase();
    String type = "medical_document";
    
    if (normalizedText.contains("blood") || normalizedText.contains("lab")) {
      type = "lab_test";
    } else if (normalizedText.contains("prescription") || normalizedText.contains("rx")) {
      type = "prescription";
    }

    List<KeyFinding> findings = [];
    
    // Simple regex lab value parsing
    final hemoglobinMatch = RegExp(r'hemoglobin[\:\s]+(\d+\.?\d*)').firstMatch(normalizedText);
    if (hemoglobinMatch != null) {
      final val = double.parse(hemoglobinMatch.group(1)!);
      findings.add(KeyFinding(
        label: "Hemoglobin",
        value: val.toString(),
        normalRange: "12.0 - 16.0 g/dL",
        isAbnormal: val < 12.0 || val > 16.0,
      ));
    }

    final glucoseMatch = RegExp(r'glucose[\:\s]+(\d+)').firstMatch(normalizedText);
    if (glucoseMatch != null) {
      final val = int.parse(glucoseMatch.group(1)!);
      findings.add(KeyFinding(
        label: "Glucose",
        value: val.toString(),
        normalRange: "70 - 100 mg/dL",
        isAbnormal: val < 70 || val > 100,
      ));
    }

    return MedicalDocument(
      documentType: type,
      extractedText: text,
      keyFindings: findings,
      abnormalValues: findings.where((f) => f.isAbnormal).map((f) => f.label).toList(),
      recommendations: findings.any((f) => f.isAbnormal) 
          ? ["Consult a specialist regarding abnormal lab results."] 
          : ["All values appear within normal range. Continue regular monitoring."],
    );
  }

  Future<MedicalImagingResult> analyzeMedicalImage(String imagePath) async {
    // Heuristic detection based on filename
    final fileName = imagePath.split('/').last.toLowerCase();
    
    String type = 'X-Ray';
    String bodyPart = 'Chest';
    
    if (fileName.contains('mri')) type = 'MRI';
    else if (fileName.contains('ct')) type = 'CT Scan';
    else if (fileName.contains('ultrasound')) type = 'Ultrasound';

    if (fileName.contains('head') || fileName.contains('brain')) bodyPart = 'Head/Brain';
    else if (fileName.contains('knee')) bodyPart = 'Knee';
    else if (fileName.contains('spine')) bodyPart = 'Spine';

    return MedicalImagingResult(
      imagingType: type,
      bodyPart: bodyPart,
      description: 'The scan shows the structural integrity of the $bodyPart area using $type technology.',
      observedAreas: ['Primary structures of the $bodyPart', 'Surrounding soft tissue'],
      areasOfInterest: [],
      confidenceLevel: '85% (Heuristic)',
      simpleExplanation: 'This is a $type of your $bodyPart. It helps doctors see inside your body without surgery.',
      requiresUrgentReview: false,
      imagePath: imagePath,
    );
  }

  List<String> checkSafetyConflicts(Medication med, UserProfile profile) {
    List<String> conflicts = [];
    
    // Check allergies
    if (med.activeIngredient != null) {
      for (var allergy in profile.allergies) {
        if (med.activeIngredient!.toLowerCase().contains(allergy.toLowerCase()) ||
            med.name.toLowerCase().contains(allergy.toLowerCase())) {
          conflicts.add("Potential Allergy: You are allergic to $allergy, which might be present in ${med.name}.");
        }
      }
    }
    
    // Check contraindications
    for (var condition in profile.medicalConditions) {
      for (var contra in med.contraindications) {
        if (contra.toLowerCase().contains(condition.toLowerCase())) {
          conflicts.add("Condition Warning: ${med.name} is generally not recommended for people with $condition.");
        }
      }
    }
    
    return conflicts;
  }

  /// New feature: Basic Drug-Drug Interaction Check
  List<String> checkDrugInteractions(List<Medication> meds) {
    List<String> interactions = [];
    if (meds.length < 2) return interactions;

    final names = meds.map((m) => m.name.toLowerCase()).toList();
    
    // Example interaction logic
    if (names.contains('aspirin') && names.contains('ibuprofen')) {
      interactions.add("Moderate Interaction: Taking Aspirin and Ibuprofen together may increase risk of stomach bleeding.");
    }
    
    if (names.contains('warfarin') && names.contains('aspirin')) {
      interactions.add("Major Interaction: High risk of severe bleeding when combining blood thinners.");
    }

    return interactions;
  }
}
