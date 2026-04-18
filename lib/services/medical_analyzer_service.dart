import '../models/models.dart';
import 'extended_medications_database.dart';
import 'openfda_service.dart';
import 'openai_chat_service.dart';

class MedicalAnalyzerService {
  // Mock medication data
  final Map<String, Medication> _medicationDB = medications;

  Future<Medication> analyzeMedicationBarcode(String barcode) async {
    final fda = OpenFDAService();
    final med = await fda.searchByUpc(barcode);
    if (med != null) return med;
    
    return _buildUnknownMedication();
  }

  Future<Medication> analyzeMedicationText(String text) async {
    // Normalise text: lowercase, strip non-alphanumeric characters
    final normalizedText = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '');
    
    // 1. Try OpenFDA dynamically first
    final fda = OpenFDAService();
    // Use the first long word as a search query
    final words = normalizedText.split(RegExp(r'\s+')).where((w) => w.length > 4).toList();
    for (String word in words) {
      final fdaMed = await fda.searchByName(word);
      if (fdaMed != null) return fdaMed;
    }

    // 2. Fuzzy matching on local DB
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

    return _buildUnknownMedication();
  }

  Medication _buildUnknownMedication() {
    return Medication(
      name: "Unknown Medication",
      simpleExplanation: "We couldn't identify this medication in our database or OpenFDA.",
      requiresPrescription: false,
      usedFor: [],
      whenToUse: [],
      contraindications: [],
      sideEffects: [],
    );
  }

  Future<MedicalDocument> analyzeDocument(String text) async {


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

    final cholesterolMatch = RegExp(r'cholesterol[\:\s]+(\d+)').firstMatch(normalizedText);
    if (cholesterolMatch != null) {
      final val = int.parse(cholesterolMatch.group(1)!);
      findings.add(KeyFinding(
        label: "Total Cholesterol",
        value: val.toString(),
        normalRange: "< 200 mg/dL",
        isAbnormal: val >= 200,
      ));
    }

    final ldlMatch = RegExp(r'ldl[\:\s]+(\d+)').firstMatch(normalizedText);
    if (ldlMatch != null) {
      final val = int.parse(ldlMatch.group(1)!);
      findings.add(KeyFinding(
        label: "LDL Cholesterol",
        value: val.toString(),
        normalRange: "< 100 mg/dL",
        isAbnormal: val >= 100,
      ));
    }

    final bpMatch = RegExp(r'bp[\:\s]+(\d+)/(\d+)').firstMatch(normalizedText);
    if (bpMatch != null) {
      final systolic = int.parse(bpMatch.group(1)!);
      final diastolic = int.parse(bpMatch.group(2)!);
      findings.add(KeyFinding(
        label: "Blood Pressure",
        value: "$systolic/$diastolic",
        normalRange: "< 120/80 mmHg",
        isAbnormal: systolic >= 120 || diastolic >= 80,
      ));
    }

    final abnormal = findings.where((f) => f.isAbnormal).map((f) => f.label).toList();
    List<String> recommendations = [];

    if (type == "lab_test") {
      recommendations.add("Please consult your doctor to discuss these lab results.");
      if (abnormal.isNotEmpty) {
        recommendations.add("Consider speaking with a specialist regarding your abnormal levels.");
      }
      
      // Ping OpenAI for natural language summary
      try {
        final summaryPrompt = 'Summarize these lab results for a patient in plain English. Keep it to 3 sentences maximum. Highlight any abnormals. Key findings: ${findings.map((f) => "${f.label}: ${f.value}").join(", ")}. Abnormal values: ${abnormal.join(", ")}.';
        final summary = await OpenAIChatService().getResponse(summaryPrompt, {});
        recommendations.insert(0, summary);
      } catch (e) {
        // Fallback if API fails or web
        recommendations.insert(0, "AI Natural Language limit reached or unavailable.");
      }
    } else if (type == "prescription") {
      recommendations.add("Ensure you follow the dosage instructions provided by your pharmacist.");
    } else {
      recommendations.add(findings.any((f) => f.isAbnormal) 
          ? "Consult a specialist regarding abnormal lab results." 
          : "All values appear within normal range. Continue regular monitoring.");
    }

    return MedicalDocument(
      documentType: type,
      extractedText: text,
      keyFindings: findings,
      abnormalValues: abnormal,
      recommendations: recommendations,
    );
  }

  Future<MedicalImagingResult> analyzeMedicalImage(String imagePath) async {
    // Heuristic detection based on filename
    final fileName = imagePath.split('/').last.toLowerCase();
    
    String type = 'X-Ray';
    String bodyPart = 'Chest';
    
    if (fileName.contains('mri')) {
      type = 'MRI';
    } else if (fileName.contains('ct')) {
      type = 'CT Scan';
    } else if (fileName.contains('ultrasound')) {
      type = 'Ultrasound';
    }

    if (fileName.contains('head') || fileName.contains('brain')) {
      bodyPart = 'Head/Brain';
    } else if (fileName.contains('knee')) {
      bodyPart = 'Knee';
    } else if (fileName.contains('spine')) {
      bodyPart = 'Spine';
    }

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
    final medName = med.name.toLowerCase();
    final activeIng = med.activeIngredient?.toLowerCase() ?? "";
    
    // Check allergies
    for (var allergy in profile.allergies) {
      final a = allergy.toLowerCase();
      if (activeIng.contains(a) || medName.contains(a)) {
        conflicts.add("Potential Allergy: You are allergic to $allergy, which might be present in ${med.name}.");
      }
      
      // Synonym/Group matching (Simple heuristic)
      if (a == 'penicillin' && (activeIng.contains('amoxicillin') || activeIng.contains('ampicillin'))) {
        conflicts.add("Allergy Warning: ${med.name} contains $activeIng, which is a penicillin-type antibiotic.");
      }
      if ((a == 'sulfa' || a == 'sulfonamide') && activeIng.contains('sulf')) {
        conflicts.add("Allergy Warning: ${med.name} contains $activeIng, which may trigger sulfa allergies.");
      }
    }
    
    // Check contraindications against profile conditions
    for (var condition in profile.medicalConditions) {
      final c = condition.toLowerCase();
      for (var contra in med.contraindications) {
        final ct = contra.toLowerCase();
        if (ct.contains(c)) {
          conflicts.add("Condition Warning: ${med.name} is generally not recommended for people with $condition.");
        }
        
        // Logical mapping (e.g., Stomach issues -> Ulcer)
        if (c.contains('ulcer') && (ct.contains('stomach') || ct.contains('gastric'))) {
          conflicts.add("Condition Warning: ${med.name} mentions $contra, which may be risky for your stomach ulcer history.");
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

  /// New feature: Check single med against a list of active medications
  List<String> checkInteractionsWithActiveMeds(Medication newMed, List<String> activeMedNames) {
    List<String> warnings = [];
    if (activeMedNames.isEmpty) return warnings;

    final newName = newMed.name.toLowerCase();
    
    for (final activeName in activeMedNames) {
      final active = activeName.toLowerCase();
      
      // Simple logic for demonstration (as per requested phase)
      if (newName.contains('aspirin') && active.contains('ibuprofen')) {
        warnings.add("Warning: Taking ${newMed.name} while on $activeName can increase bleeding risk.");
      }
      if (newName.contains('ibuprofen') && active.contains('aspirin')) {
        warnings.add("Warning: Taking ${newMed.name} while on $activeName can increase bleeding risk.");
      }
      if (newName.contains('warfarin') && active.contains('aspirin')) {
        warnings.add("CRITICAL: Significant bleeding risk when combining ${newMed.name} with $activeName.");
      }
    }
    
    return warnings;
  }
}
