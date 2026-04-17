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
      name: map['name'] ?? 'Unknown Medication',
      activeIngredient: map['activeIngredient']?.toString(),
      manufacturer: map['manufacturer']?.toString(),
      usedFor: map['usedFor'] != null ? List<String>.from(map['usedFor']) : [],
      whenToUse: map['whenToUse'] != null ? List<String>.from(map['whenToUse']) : [],
      contraindications: map['contraindications'] != null ? List<String>.from(map['contraindications']) : [],
      dosage: map['dosage']?.toString(),
      sideEffects: map['sideEffects'] != null ? List<String>.from(map['sideEffects']) : [],
      simpleExplanation: map['simpleExplanation'] ?? 'No explanation available.',
      requiresPrescription: map['requiresPrescription'] ?? false,
      imagePath: map['imagePath']?.toString(),
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
      documentType: map['documentType'] ?? 'Unknown Document',
      extractedText: map['extractedText'] ?? '',
      keyFindings: map['keyFindings'] != null 
          ? List<KeyFinding>.from(map['keyFindings'].map((x) => KeyFinding.fromMap(x as Map<String, dynamic>))) 
          : [],
      abnormalValues: map['abnormalValues'] != null ? List<String>.from(map['abnormalValues']) : [],
      recommendations: map['recommendations'] != null ? List<String>.from(map['recommendations']) : [],
      dateCreated: map['dateCreated'] != null ? DateTime.tryParse(map['dateCreated']) : null,
      imagePath: map['imagePath']?.toString(),
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
      label: map['label'] ?? 'Unknown',
      value: map['value']?.toString() ?? 'N/A',
      normalRange: map['normalRange']?.toString(),
      isAbnormal: map['isAbnormal'] ?? false,
      interpretation: map['interpretation']?.toString(),
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
      imagingType: map['imagingType'] ?? 'Unknown Imaging',
      bodyPart: map['bodyPart'] ?? 'Unknown',
      description: map['description'] ?? '',
      observedAreas: map['observedAreas'] != null ? List<String>.from(map['observedAreas']) : [],
      areasOfInterest: map['areasOfInterest'] != null ? List<String>.from(map['areasOfInterest']) : [],
      confidenceLevel: map['confidenceLevel'] ?? 'N/A',
      simpleExplanation: map['simpleExplanation'] ?? '',
      requiresUrgentReview: map['requiresUrgentReview'] ?? false,
      imagePath: map['imagePath']?.toString(),
    );
  }
}

class HistoryItem {
  final String id;
  final String userId; 
  final DateTime timestamp;
  final String type; 
  final dynamic data;
  final String? imagePath;

  HistoryItem({
    required this.id,
    required this.userId,
    required this.timestamp,
    required this.type,
    required this.data,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'data': data?.toMap(),
      'imagePath': imagePath,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    final type = map['type']?.toString();
    final dataMap = map['data'] as Map<String, dynamic>?;
    dynamic data;

    if (dataMap != null) {
      if (type == 'medication') {
        data = Medication.fromMap(dataMap);
      } else if (type == 'document') {
        data = MedicalDocument.fromMap(dataMap);
      } else if (type == 'imaging') {
        data = MedicalImagingResult.fromMap(dataMap);
      }
    }

    return HistoryItem(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      userId: map['userId'] ?? 'default',
      timestamp: map['timestamp'] != null ? DateTime.parse(map['timestamp']) : DateTime.now(),
      type: type ?? 'unknown',
      data: data,
      imagePath: map['imagePath']?.toString(),
    );
  }
}

class UserProfile {
  final String id;
  final String name;
  final int? age;
  final String relation; 
  final List<String> allergies;
  final List<String> medicalConditions;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.name,
    this.age,
    this.relation = 'Self',
    required this.allergies,
    required this.medicalConditions,
    this.avatarUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'relation': relation,
      'allergies': allergies,
      'medicalConditions': medicalConditions,
      'avatarUrl': avatarUrl,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['name']?.toString() ?? 'New Profile',
      age: map['age'] is int ? map['age'] : (map['age'] != null ? int.tryParse(map['age'].toString()) : null),
      relation: map['relation']?.toString() ?? 'Self',
      allergies: map['allergies'] != null ? List<String>.from(map['allergies']) : [],
      medicalConditions: map['medicalConditions'] != null ? List<String>.from(map['medicalConditions']) : [],
      avatarUrl: map['avatarUrl']?.toString(),
    );
  }
}
