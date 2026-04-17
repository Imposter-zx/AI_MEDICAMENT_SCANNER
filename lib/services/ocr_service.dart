import 'dart:io' show File;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class OCRService {
  late final TextRecognizer _textRecognizer;

  OCRService() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  Future<String> extractTextFromImage(String imagePath) async {
    if (kIsWeb) {
      return "Para-cet-amol 500mg table-ts. Aspirin interact-ion check.";
    }
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      return recognizedText.text;
    } catch (e) {
      throw Exception('Failed to extract text from image: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _textRecognizer.close();
  }
}
