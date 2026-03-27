import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/medical_analyzer_service.dart';
import '../services/ocr_service.dart';

class MedicalDataProvider with ChangeNotifier {
  final MedicalAnalyzerService _analyzerService = MedicalAnalyzerService();
  final OCRService _ocrService = OCRService();

  Medication? currentMedication;
  MedicalDocument? currentDocument;
  MedicalImagingResult? currentImagingResult;
  String? currentImagePath;
  bool isLoading = false;
  String? errorMessage;
  
  List<HistoryItem> history = [];

  MedicalDataProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('analysis_history') ?? [];
      history = historyJson
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
      if (history.length > 20) history.removeLast(); // Keep last 20

      final prefs = await SharedPreferences.getInstance();
      final historyJson = history.map((item) => json.encode(item.toMap())).toList();
      await prefs.setStringList('analysis_history', historyJson);
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving history: $e");
    }
  }

  Future<void> analyzeMedication(String imagePath) async {
    _startLoading();
    currentImagePath = imagePath;
    try {
      final text = await _ocrService.extractTextFromImage(imagePath);
      currentMedication = await _analyzerService.analyzeMedicationText(text);
      currentMedication?.imagePath = imagePath;
      
      if (currentMedication != null && currentMedication!.name != "Unknown Medication") {
        await _saveHistoryItem(HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: 'medication',
          data: currentMedication!,
          imagePath: imagePath,
        ));
      }
      
      _stopLoading();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> analyzeDocument(String imagePath) async {
    _startLoading();
    currentImagePath = imagePath;
    try {
      final text = await _ocrService.extractTextFromImage(imagePath);
      currentDocument = await _analyzerService.analyzeDocument(text);
      currentDocument?.imagePath = imagePath;
      
      if (currentDocument != null) {
        await _saveHistoryItem(HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: 'document',
          data: currentDocument!,
          imagePath: imagePath,
        ));
      }
      
      _stopLoading();
    } catch (e) {
      _handleError(e.toString());
    }
  }

  Future<void> analyzeMedicalImage(String imagePath) async {
    _startLoading();
    currentImagePath = imagePath;
    try {
      currentImagingResult = await _analyzerService.analyzeMedicalImage(imagePath);
      
      if (currentImagingResult != null) {
        await _saveHistoryItem(HistoryItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          timestamp: DateTime.now(),
          type: 'imaging',
          data: currentImagingResult!,
          imagePath: imagePath,
        ));
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
