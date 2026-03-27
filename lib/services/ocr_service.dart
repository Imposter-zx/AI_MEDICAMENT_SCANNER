import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  late final TextRecognizer _textRecognizer;

  OCRService() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  /// Extract text from an image file
  Future<String> extractTextFromImage(String imagePath) async {
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
