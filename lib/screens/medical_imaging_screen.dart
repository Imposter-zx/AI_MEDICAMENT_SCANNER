import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/medical_data_provider.dart';
import '../providers/user_profile_provider.dart';
import '../services/medical_imaging_service.dart';

class MedicalImagingScreen extends StatefulWidget {
  const MedicalImagingScreen({Key? key}) : super(key: key);

  @override
  State<MedicalImagingScreen> createState() => _MedicalImagingScreenState();
}

class _MedicalImagingScreenState extends State<MedicalImagingScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicalDataProvider>();
    final userId = context.read<UserProfileProvider>().activeProfileId ?? 'default';
    return Scaffold(
      appBar: AppBar(
        title: const Text('🩺 Medical Imaging'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 210,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_selectedImage!, fit: BoxFit.cover),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.photo, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('Tap to select an image'),
                            ],
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedImage != null)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _analyzeImage(userId),
                    icon: const Icon(Icons.search),
                    label: const Text('Analyze Image'),
                  ),
                ),
              if (_selectedImage != null) const SizedBox(height: 8),
              if (provider.isLoading) const Center(child: CircularProgressIndicator()),
              if (provider.currentImagingResult != null)
                Card(child: ListTile(title: Text('Imaging: ${provider.currentImagingResult!.imagingType}'), subtitle: Text(provider.currentImagingResult!.description))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text('Always consult a radiologist for official interpretation.')),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() { _selectedImage = File(pickedFile.path); });
      }
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _analyzeImage(String userId) async {
    if (_selectedImage == null) return;
    final provider = context.read<MedicalDataProvider>();
    await provider.analyzeMedicalImage(_selectedImage!.path, userId);
    if (mounted && provider.currentImagingResult != null) {
      Navigator.pushNamed(context, '/results');
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🩺 Medical Imaging'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.info_outline, size: 48, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Coming Soon: Medical Imaging Analysis',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'This feature is under active development. A medical professional should interpret imaging results.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
