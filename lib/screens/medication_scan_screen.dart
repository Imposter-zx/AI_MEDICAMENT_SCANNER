import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/medical_data_provider.dart';
import '../providers/user_profile_provider.dart';
import '../l10n/app_localizations.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/premium_background.dart';

class MedicationScanScreen extends StatefulWidget {
  const MedicationScanScreen({super.key});

  @override
  State<MedicationScanScreen> createState() => _MedicationScanScreenState();
}

class _MedicationScanScreenState extends State<MedicationScanScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webImageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).medicationScanner,
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
                // Instructions Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  height: 120, // Reduced from implicit height to fit cleanly
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.camera_alt, color: Theme.of(context).colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            AppLocalizations.of(context).howToUse,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '1. Take a photo or upload an image of the medication box\n'
                        '2. Make sure the label is clear and readable',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Image Selection Area
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: _selectedImage == null
                          ? LinearGradient(
                              colors: [
                                Colors.purple.shade100.withValues(alpha: 0.5),
                                Colors.indigo.shade100.withValues(alpha: 0.5),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      border: _selectedImage == null
                          ? Border.all(color: Colors.purple.shade300.withValues(alpha: 0.5), width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purple.withValues(alpha: 0.1),
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
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade200.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 56,
                                  color: Colors.purple.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(context).selectImage,
                                style: TextStyle(
                                  color: Colors.purple.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppLocalizations.of(context).cameraOrGallery,
                                style: TextStyle(
                                  color: Colors.purple.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                if (_selectedImage != null || _webImageBytes != null)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: AppLocalizations.of(context).analyzeMedication,
                          icon: Icons.search,
                          onPressed: _analyzeMedication,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _webImageBytes = null;
                            });
                          },
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          label: Text(
                            AppLocalizations.of(context).clearImage,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Loading State
                Consumer<MedicalDataProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor.withValues(alpha: 0.8),
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
                              valueColor: AlwaysStoppedAnimation(Colors.blue.shade500),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppLocalizations.of(context).analyzing,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (provider.errorMessage != null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.red.shade50, Colors.orange.shade50],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade300),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade200.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Error',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    provider.errorMessage!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: Text(AppLocalizations.of(context).takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context).chooseGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _selectedImage = null; // Ensure File is null on web
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
            _webImageBytes = null;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _analyzeMedication() async {
    if (_selectedImage == null && _webImageBytes == null) return;

    final provider = context.read<MedicalDataProvider>();
    final profileProvider = context.read<UserProfileProvider>();
    final userId = profileProvider.activeProfileId ?? 'default';
    
    await provider.analyzeMedication(
      _selectedImage?.path ?? 'web_image',
      userId,
      bytes: _webImageBytes,
    );

    if (mounted && provider.currentMedication != null) {
      Navigator.pushNamed(context, '/results');
    }
  }
}
