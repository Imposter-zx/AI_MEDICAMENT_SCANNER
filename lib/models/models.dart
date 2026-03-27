

// Note: No .g.dart was found in outpust so manual serialization or build_runner is needed
// I'll provide standard classes for now

class Medication {
  final String name;
  final String? activeIngredient;
  final String? manufacturer;
  final List<String> usedFor;
  final List<String> whenToUse;
  final List<String> contraindications;
  final String? dosage;
  final List<String> sideEffects;
  final String simpleExplanation;
  final bool requiresPrescription;
  String? imagePath;

  Medication({
    required this.name,
    this.activeIngredient,
    this.manufacturer,
    required this.usedFor,
    required this.whenToUse,
    required this.contraindications,
    this.dosage,
    required this.sideEffects,
    required this.simpleExplanation,
    this.requiresPrescription = false,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'activeIngredient': activeIngredient,
      'manufacturer': manufacturer,
      'usedFor': usedFor,
      'whenToUse': whenToUse,
      'contraindications': contraindications,
      'dosage': dosage,
      'sideEffects': sideEffects,
      'simpleExplanation': simpleExplanation,
      'requiresPrescription': requiresPrescription,
      'imagePath': imagePath,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'],
      activeIngredient: map['activeIngredient'],
      manufacturer: map['manufacturer'],
      usedFor: List<String>.from(map['usedFor']),
      whenToUse: List<String>.from(map['whenToUse']),
      contraindications: List<String>.from(map['contraindications']),
      dosage: map['dosage'],
      sideEffects: List<String>.from(map['sideEffects']),
      simpleExplanation: map['simpleExplanation'],
      requiresPrescription: map['requiresPrescription'] ?? false,
      imagePath: map['imagePath'],
    );
  }
}

class MedicalDocument {
  final String documentType;
  final String extractedText;
  final List<KeyFinding> keyFindings;
  final List<String> abnormalValues;
  final List<String> recommendations;
  final DateTime? dateCreated;
  String? imagePath;

  MedicalDocument({
    required this.documentType,
    required this.extractedText,
    required this.keyFindings,
    required this.abnormalValues,
    required this.recommendations,
    this.dateCreated,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentType': documentType,
      'extractedText': extractedText,
      'keyFindings': keyFindings.map((x) => x.toMap()).toList(),
      'abnormalValues': abnormalValues,
      'recommendations': recommendations,
      'dateCreated': dateCreated?.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  factory MedicalDocument.fromMap(Map<String, dynamic> map) {
    return MedicalDocument(
      documentType: map['documentType'],
      extractedText: map['extractedText'],
      keyFindings: List<KeyFinding>.from(map['keyFindings']?.map((x) => KeyFinding.fromMap(x))),
      abnormalValues: List<String>.from(map['abnormalValues']),
      recommendations: List<String>.from(map['recommendations']),
      dateCreated: map['dateCreated'] != null ? DateTime.parse(map['dateCreated']) : null,
      imagePath: map['imagePath'],
    );
  }
}

class KeyFinding {
  final String label;
  final String value;
  final String? normalRange;
  final bool isAbnormal;
  final String? interpretation;

  KeyFinding({
    required this.label,
    required this.value,
    this.normalRange,
    required this.isAbnormal,
    this.interpretation,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'value': value,
      'normalRange': normalRange,
      'isAbnormal': isAbnormal,
      'interpretation': interpretation,
    };
  }

  factory KeyFinding.fromMap(Map<String, dynamic> map) {
    return KeyFinding(
      label: map['label'],
      value: map['value'],
      normalRange: map['normalRange'],
      isAbnormal: map['isAbnormal'],
      interpretation: map['interpretation'],
    );
  }
}

class MedicalImagingResult {
  final String imagingType;
  final String bodyPart;
  final String description;
  final List<String> observedAreas;
  final List<String> areasOfInterest;
  final String confidenceLevel;
  final String simpleExplanation;
  final bool requiresUrgentReview;
  final String? imagePath;

  MedicalImagingResult({
    required this.imagingType,
    required this.bodyPart,
    required this.description,
    required this.observedAreas,
    required this.areasOfInterest,
    required this.confidenceLevel,
    required this.simpleExplanation,
    required this.requiresUrgentReview,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagingType': imagingType,
      'bodyPart': bodyPart,
      'description': description,
      'observedAreas': observedAreas,
      'areasOfInterest': areasOfInterest,
      'confidenceLevel': confidenceLevel,
      'simpleExplanation': simpleExplanation,
      'requiresUrgentReview': requiresUrgentReview,
      'imagePath': imagePath,
    };
  }

  factory MedicalImagingResult.fromMap(Map<String, dynamic> map) {
    return MedicalImagingResult(
      imagingType: map['imagingType'],
      bodyPart: map['bodyPart'],
      description: map['description'],
      observedAreas: List<String>.from(map['observedAreas']),
      areasOfInterest: List<String>.from(map['areasOfInterest']),
      confidenceLevel: map['confidenceLevel'],
      simpleExplanation: map['simpleExplanation'],
      requiresUrgentReview: map['requiresUrgentReview'],
      imagePath: map['imagePath'],
    );
  }
}
class HistoryItem {
  final String id;
  final DateTime timestamp;
  final String type; // 'medication', 'document', 'imaging'
  final dynamic data;
  final String? imagePath;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.data,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'data': data.toMap(),
      'imagePath': imagePath,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    final type = map['type'];
    final dataMap = map['data'];
    dynamic data;

    if (type == 'medication') {
      data = Medication.fromMap(dataMap);
    } else if (type == 'document') {
      data = MedicalDocument.fromMap(dataMap);
    } else if (type == 'imaging') {
      data = MedicalImagingResult.fromMap(dataMap);
    }

    return HistoryItem(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      type: type,
      data: data,
      imagePath: map['imagePath'],
    );
  }
}
class UserProfile {
  final String name;
  final int? age;
  final List<String> allergies;
  final List<String> medicalConditions;

  UserProfile({
    required this.name,
    this.age,
    required this.allergies,
    required this.medicalConditions,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      age: map['age'],
      allergies: List<String>.from(map['allergies'] ?? []),
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
    );
  }
}
