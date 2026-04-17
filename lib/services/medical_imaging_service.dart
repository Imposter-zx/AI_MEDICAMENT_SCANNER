import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:ai_medicament_scanner/models/models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class MedicalImagingService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<MedicalImagingResult?> analyzeImage(String imagePath) async {
    if (kIsWeb) {
      return MedicalImagingResult(
        imagingType: 'Simulation',
        bodyPart: 'Chest/Abdomen',
        description: 'Web simulation of medical imaging analysis.',
        observedAreas: ['Area A clear', 'Area B normal'],
        areasOfInterest: [],
        confidenceLevel: 'High (Mock)',
        simpleExplanation: 'Imaging analysis is simulated on web.',
        requiresUrgentReview: false,
      );
    }
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      final text = recognizedText.text;
      final lines = text.split(RegExp(r"\\n|\r\n|\n")).where((l) => l.trim().isNotEmpty).toList();
      final result = MedicalImagingResult(
        imagingType: 'Text OCR',
        bodyPart: 'Unknown',
        description: 'OCR extracted text from image',
        observedAreas: lines,
        areasOfInterest: lines.take(3).toList(),
        confidenceLevel: 'Unknown',
        simpleExplanation: 'OCR extracted text markers found',
        requiresUrgentReview: false,
      );
      return result;
    } catch (e) {
      return MedicalImagingResult(
        imagingType: 'Error',
        bodyPart: 'Unknown',
        description: 'Imaging analysis failed: $e',
        observedAreas: [],
        areasOfInterest: [],
        confidenceLevel: 'Low',
        simpleExplanation: 'Imaging analysis encountered an error',
        requiresUrgentReview: false,
      );
    }
  }
}
