class MedicineCache {
  final String medicineId;
  final String medicineName;
  final String? activeIngredient;
  final String? manufacturer;
  final DateTime lastScannedDate;
  final int scanCount;
  final String? extractedOCRText;
  final String? imagePath;
  final bool synced; // Track if synced to Firebase
  final DateTime createdAt;

  MedicineCache({
    required this.medicineId,
    required this.medicineName,
    this.activeIngredient,
    this.manufacturer,
    required this.lastScannedDate,
    this.scanCount = 1,
    this.extractedOCRText,
    this.imagePath,
    this.synced = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for file storage
  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'activeIngredient': activeIngredient,
      'manufacturer': manufacturer,
      'lastScannedDate': lastScannedDate.toIso8601String(),
      'scanCount': scanCount,
      'extractedOCRText': extractedOCRText,
      'imagePath': imagePath,
      'synced': synced,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON file
  factory MedicineCache.fromJson(Map<String, dynamic> json) {
    return MedicineCache(
      medicineId: json['medicineId'] ?? '',
      medicineName: json['medicineName'] ?? 'Unknown',
      activeIngredient: json['activeIngredient'],
      manufacturer: json['manufacturer'],
      lastScannedDate: DateTime.parse(
        json['lastScannedDate'] ?? DateTime.now().toIso8601String(),
      ),
      scanCount: json['scanCount'] ?? 1,
      extractedOCRText: json['extractedOCRText'],
      imagePath: json['imagePath'],
      synced: json['synced'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Copy with updated fields
  MedicineCache copyWith({
    String? medicineId,
    String? medicineName,
    String? activeIngredient,
    String? manufacturer,
    DateTime? lastScannedDate,
    int? scanCount,
    String? extractedOCRText,
    String? imagePath,
    bool? synced,
  }) {
    return MedicineCache(
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      activeIngredient: activeIngredient ?? this.activeIngredient,
      manufacturer: manufacturer ?? this.manufacturer,
      lastScannedDate: lastScannedDate ?? this.lastScannedDate,
      scanCount: scanCount ?? this.scanCount,
      extractedOCRText: extractedOCRText ?? this.extractedOCRText,
      imagePath: imagePath ?? this.imagePath,
      synced: synced ?? this.synced,
      createdAt: createdAt,
    );
  }

  @override
  String toString() =>
      'MedicineCache($medicineName, scanCount: $scanCount, synced: $synced)';
}
