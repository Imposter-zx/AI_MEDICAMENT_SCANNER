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

class DocumentAnalysisScreen extends StatefulWidget {
  const DocumentAnalysisScreen({super.key});

  @override
  State<DocumentAnalysisScreen> createState() => _DocumentAnalysisScreenState();
}

class _DocumentAnalysisScreenState extends State<DocumentAnalysisScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webImageBytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).documentAnalysis,
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
                  height: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: Theme.of(context).colorScheme.primary, size: 20),
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
                      Text(
                        AppLocalizations.of(context).howToUseDesc,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Document Selection Area
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: _selectedImage == null
                          ? LinearGradient(
                              colors: [
                                Colors.orange.shade100,
                                Colors.amber.shade100,
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      border: _selectedImage == null
                          ? Border.all(color: Colors.orange.shade300, width: 2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withValues(alpha: 0.2),
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
                                  color: Colors.orange.shade200.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.insert_drive_file_outlined,
                                  size: 56,
                                  color: Colors.orange.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to upload document',
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Camera or Gallery',
                                style: TextStyle(
                                  color: Colors.orange.shade500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                if (_selectedImage != null)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: GradientButton(
                          text: AppLocalizations.of(context).analyzeDocument,
                          icon: Icons.analytics,
                          onPressed: _analyzeDocument,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                            });
                          },
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          label: Text(
                            AppLocalizations.of(context).clearDocument,
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
                              valueColor: AlwaysStoppedAnimation(Colors.blue.shade500),
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

                const SizedBox(height: 20),

                // Safety Notice
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade50, Colors.orange.shade50],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade300),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade200.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.info, color: Colors.amber.shade700, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).safetyNotice,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking document: $e')),
      );
    }
  }

  Future<void> _analyzeDocument() async {
    if (_selectedImage == null && _webImageBytes == null) return;

    final provider = context.read<MedicalDataProvider>();
    final profileProvider = context.read<UserProfileProvider>();
    final userId = profileProvider.activeProfileId ?? 'default';
    
    await provider.analyzeDocument(
      _selectedImage?.path ?? 'web_image',
      userId,
      bytes: _webImageBytes,
    );

    if (mounted && provider.currentDocument != null) {
      Navigator.pushNamed(context, '/results');
    }
  }
}
