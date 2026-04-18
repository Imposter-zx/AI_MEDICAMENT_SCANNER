import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class BarcodeService {
  late final BarcodeScanner _barcodeScanner;

  BarcodeService() {
    _barcodeScanner = BarcodeScanner();
  }

  /// Extract a barcode value from an image file path
  Future<String?> extractBarcodeFromImage(String imagePath) async {
    if (kIsWeb) {
      // Mock barcode response on Web because ML Kit is not supported
      // Returning null simulates no barcode found, falling back to OCR.
      return null;
    }
    
    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
      
      for (Barcode barcode in barcodes) {
        if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
          return barcode.rawValue;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _barcodeScanner.close();
  }
}
