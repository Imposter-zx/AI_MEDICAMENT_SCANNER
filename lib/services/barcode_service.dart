import 'dart:io' show File;
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BarcodeService {
  late final BarcodeScanner _barcodeScanner;

  BarcodeService() {
    _barcodeScanner = BarcodeScanner();
  }

  Future<String?> extractBarcodeFromImage(String imagePath) async {
    if (kIsWeb) {
      // Mock barcode for web testing
      return "0300450449102"; // Example Tylenol UPC
    }

    try {
      final inputImage = InputImage.fromFile(File(imagePath));
      final barcodes = await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        return barcodes.first.displayValue;
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
