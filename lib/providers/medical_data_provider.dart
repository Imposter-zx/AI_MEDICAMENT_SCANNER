import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../models/medicine_cache_model.dart';
import '../services/medical_analyzer_service.dart';
import '../services/ocr_service.dart';
import '../services/medical_imaging_service.dart';
import '../services/storage_service.dart';
import '../services/medicine_cache_service.dart';

class MedicalDataProvider with ChangeNotifier {
  final MedicalAnalyzerService _analyzerService = MedicalAnalyzerService();
  final OCRService _ocrService = OCRService();
  final StorageService _storage = StorageService();
  final MedicineCacheService _cacheService = MedicineCacheService();

  bool _cacheHit = false;
  String? _cacheStatus;

  Medication? currentMedication;
  MedicalDocument? currentDocument;
  MedicalImagingResult? currentImagingResult;
  String? currentImagePath;
  bool isLoading = false;
  String? errorMessage;

  List<HistoryItem> history = [];

  // Getters for cache status
  bool get wasCacheHit => _cacheHit;
  String? get cacheStatus => _cacheStatus;

  MedicalDataProvider() {
    _loadHistory();
    _initializeCache();
  }

  Future<void> _initializeCache() async {
    try {
      await _cacheService.init();
      debugPrint('[MedicalDataProvider] Cache service initialized');
    } catch (e) {
      debugPrint('[MedicalDataProvider] Error initializing cache: $e');
    }
  }

  Future<void> analyzeMedicalImage(String imagePath, String userId) async {
    _startLoading();
    currentImagePath = imagePath;
    try {
      currentImagingResult = await MedicalImagingService().analyzeImage(
        imagePath,
      );
      if (currentImagingResult != null) {
        await _saveHistoryItem(
          HistoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            timestamp: DateTime.now(),
            type: 'imaging',
            data: currentImagingResult!,
            imagePath: imagePath,
          ),
        );
      }
      _stopLoading();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> _loadHistory() async {
    try {
      final historyJson = await _storage.getHistory();
      history =
          historyJson
              .map((item) => HistoryItem.fromMap(json.decode(item)))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading history: $e");
    }
  }

  Future<void> _saveHistoryItem(HistoryItem item) async {
    try {
      history.insert(0, item);
      if (history.length > 20) history.removeLast();

      final historyJson = history
          .map((item) => json.encode(item.toMap()))
          .toList();
      await _storage.setHistory(historyJson);
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving history: $e");
    }
  }

  Future<void> analyzeMedication(String imagePath, String userId) async {
    _startLoading();
    currentImagePath = imagePath;
    _cacheHit = false;
    _cacheStatus = null;

    try {
      final text = await _ocrService.extractTextFromImage(imagePath);

      // Check cache first
      currentMedication = await _analyzerService.analyzeMedicationText(text);

      if (currentMedication != null &&
          currentMedication!.name != "Unknown Medication") {
        // Check if a similar medicine exists in cache
        final cachedMedicine = _cacheService.getMedicineByName(
          currentMedication!.name,
        );

        if (cachedMedicine != null) {
          _cacheHit = true;
          _cacheStatus =
              'Loaded from cache (${cachedMedicine.scanCount} scans)';
          debugPrint(
            '[MedicalDataProvider] Cache hit for: ${currentMedication!.name}',
          );
        } else {
          _cacheStatus = 'New medicine added to cache';
        }

        // Save to cache with OCR text
        final medicineCache = MedicineCache(
          medicineId: currentMedication!.name
              .replaceAll(' ', '_')
              .toLowerCase(),
          medicineName: currentMedication!.name,
          activeIngredient: currentMedication!.activeIngredient,
          manufacturer: currentMedication!.manufacturer,
          lastScannedDate: DateTime.now(),
          extractedOCRText: text,
          scanCount: cachedMedicine?.scanCount ?? 1,
        );

        await _cacheService.addOrUpdateMedicine(medicineCache);

        currentMedication?.imagePath = imagePath;

        await _saveHistoryItem(
          HistoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            timestamp: DateTime.now(),
            type: 'medication',
            data: currentMedication!,
            imagePath: imagePath,
          ),
        );
      }

      _stopLoading();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> analyzeDocument(String imagePath, String userId) async {
    _startLoading();
    currentImagePath = imagePath;
    try {
      final text = await _ocrService.extractTextFromImage(imagePath);
      currentDocument = await _analyzerService.analyzeDocument(text);
      currentDocument?.imagePath = imagePath;

      if (currentDocument != null) {
        await _saveHistoryItem(
          HistoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            timestamp: DateTime.now(),
            type: 'document',
            data: currentDocument!,
            imagePath: imagePath,
          ),
        );
      }

      _stopLoading();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> _analyzeMedicalImage(String imagePath, String userId) async {
    _startLoading();
    currentImagePath = imagePath;
    try {
      currentImagingResult = await _analyzerService.analyzeMedicalImage(
        imagePath,
      );

      if (currentImagingResult != null) {
        await _saveHistoryItem(
          HistoryItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userId: userId,
            timestamp: DateTime.now(),
            type: 'imaging',
            data: currentImagingResult!,
            imagePath: imagePath,
          ),
        );
      }

      _stopLoading();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  void _startLoading() {
    isLoading = true;
    errorMessage = null;
    currentMedication = null;
    currentDocument = null;
    currentImagingResult = null;
    notifyListeners();
  }

  void _stopLoading() {
    isLoading = false;
    notifyListeners();
  }

  void _handleError(String message) {
    isLoading = false;
    errorMessage = message;
    notifyListeners();
  }

  void clearAll() {
    currentMedication = null;
    currentDocument = null;
    currentImagingResult = null;
    currentImagePath = null;
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }
}
