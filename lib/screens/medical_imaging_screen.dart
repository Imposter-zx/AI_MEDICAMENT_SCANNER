import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/medical_data_provider.dart';
import '../providers/user_profile_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/medical_imaging_service.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/premium_background.dart';

class MedicalImagingScreen extends StatefulWidget {
  const MedicalImagingScreen({Key? key}) : super(key: key);

  @override
  State<MedicalImagingScreen> createState() => _MedicalImagingScreenState();
}

class _MedicalImagingScreenState extends State<MedicalImagingScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webImageBytes;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MedicalDataProvider>();
    final userId =
        context.read<UserProfileProvider>().activeProfileId ?? 'default';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).medicalImaging,
          style: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: PremiumBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Selection Area
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: _selectedImage == null
                          ? LinearGradient(
                              colors: [
                                Colors.teal.shade100,
                                Colors.cyan.shade100,
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      border: _selectedImage == null
                          ? Border.all(color: Colors.teal.shade300, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _selectedImage != null || _webImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: kIsWeb
                                ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                                : Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade200.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.image_search,
                                    size: 64,
                                    color: Colors.teal.shade600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  AppLocalizations.of(context).selectImage,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.teal.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context).cameraOrGallery,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.teal.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                if (_selectedImage != null || _webImageBytes != null)
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      text: AppLocalizations.of(context).analyzeImage,
                      icon: Icons.search,
                      onPressed: () => _analyzeImage(userId),
                    ),
                  ),
                if (_selectedImage != null || _webImageBytes != null) const SizedBox(height: 20),
                if (provider.isLoading)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.teal.shade500),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context).analyzing,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (provider.currentImagingResult != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green.shade50, Colors.teal.shade50],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.currentImagingResult!.imagingType,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          provider.currentImagingResult!.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // Safety Notice
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  height: 100, // Reduced from implicit height to fit cleanly
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).safetyNotice,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _selectedImage = null;
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _webImageBytes = null;
          });
        }
      }
    } catch (e) {
      // ignore errors
    }
  }

  Future<void> _analyzeImage(String userId) async {
    if (_selectedImage == null && _webImageBytes == null) return;
    final provider = context.read<MedicalDataProvider>();
    await provider.analyzeMedicalImage(
      _selectedImage?.path ?? 'web_image', 
      userId,
      bytes: _webImageBytes,
    );
    if (mounted && provider.currentImagingResult != null) {
      Navigator.pushNamed(context, '/results');
    }
  }
}
