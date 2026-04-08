#!/usr/bin/env python3
# Create clean screen files

scan_code = """import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MedicationScanScreen extends StatefulWidget {
  const MedicationScanScreen({super.key});
  
  @override
  State<MedicationScanScreen> createState() => _MedicationScanScreenState();
}

class _MedicationScanScreenState extends State<MedicationScanScreen> {
  final _picker = ImagePicker();
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Scanner'),
        backgroundColor: Colors.blue.shade600,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) 
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(border: Border.all(color: Colors.blue)),
                child: Image.file(_image!, fit: BoxFit.cover),
              )
            else
              const Text('No image selected'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.camera),
              icon: const Icon(Icons.camera),
              label: const Text('Camera'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () => _getImage(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      if (file != null) {
        setState(() => _image = File(file.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
    }
  }
}
"""

doc_code = scan_code.replace('Medication Scanner', 'Document Analysis').replace('Colors.blue', 'Colors.orange')
imaging_code = scan_code.replace('Medication Scanner', 'Medical Imaging').replace('Colors.blue', 'Colors.purple')

with open('lib/screens/medication_scan_screen.dart', 'w', encoding='utf-8') as f:
    f.write(scan_code)

with open('lib/screens/document_analysis_screen.dart', 'w', encoding='utf-8') as f:
    f.write(doc_code)
    
with open('lib/screens/medical_imaging_screen.dart', 'w', encoding='utf-8') as f:
    f.write(imaging_code)

print("Created 3 clean screens successfully!")
