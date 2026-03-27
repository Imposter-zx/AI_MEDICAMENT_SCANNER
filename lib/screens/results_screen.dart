import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/medical_data_provider.dart';
import '../models/models.dart';
import '../providers/user_profile_provider.dart';
import '../services/medical_analyzer_service.dart';
import '../services/report_service.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<MedicalDataProvider, UserProfileProvider>(
        builder: (context, provider, profileProvider, child) {
          Widget content;
          String title = "Analysis Results";
          IconData icon = Icons.bar_chart;

          if (provider.currentMedication != null) {
            content = _buildMedicationResult(context, provider, profileProvider);
            title = "Medication Info";
            icon = Icons.medication;
          } else if (provider.currentDocument != null) {
            content = _buildDocumentResult(context, provider);
            title = "Document Analysis";
            icon = Icons.description;
          } else if (provider.currentImagingResult != null) {
            content = _buildImagingResult(context, provider);
            title = "Imaging Insights";
            icon = Icons.biotech;
          } else {
            content = const Center(child: Text('No results to display'));
          }
// ... (omitting middle part of build method for brevity)
          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                leading: Icon(icon),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: 'Export Report',
                    onPressed: () {
                      if (provider.currentMedication != null) {
                        ReportService().generateAndShareReport(
                          provider.currentMedication!, 
                          profileProvider.profile
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report generation is currently only available for Medication scans.')),
                        );
                      }
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(child: content),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMedicationResult(BuildContext context, MedicalDataProvider provider, UserProfileProvider profileProvider) {
    final med = provider.currentMedication!;
    List<String> safetyConflicts = [];
    
    if (profileProvider.profile != null) {
      safetyConflicts = MedicalAnalyzerService().checkSafetyConflicts(med, profileProvider.profile!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.currentImagePath != null)
            _buildImageCard(provider.currentImagePath!),
          const SizedBox(height: 24),
          
          if (safetyConflicts.isNotEmpty)
            _buildSafetyConflictCard(context, safetyConflicts),
          
          _buildResultHeader(
            context, 
            med.name, 
            med.activeIngredient ?? "General Medication", 
            Icons.medication,
            Colors.blue,
          ),
          
          const SizedBox(height: 24),
          _buildInfoSection(context, 'Indications', med.usedFor, Icons.medication),
          _buildInfoSection(context, 'Usage', med.whenToUse, Icons.access_time),
          _buildDangerSection(context, 'Contraindications', med.contraindications),
          
          if (med.dosage != null)
            _buildPremiumInfoBox(
              context,
              'Dosage Guidance',
              med.dosage!,
              Icons.healing,
              Colors.orange,
            ),
          
          _buildInfoSection(context, 'Side Effects', med.sideEffects, Icons.warning_amber),
          
          _buildPremiumInfoBox(
            context,
            'Simple Explanation',
            med.simpleExplanation,
            Icons.psychology,
            Colors.purple,
          ),
          
          if (med.requiresPrescription)
            _buildWarningBanner(context, 'Prescription Required', 'This medication must only be used under professional medical supervision.'),
          
          const SizedBox(height: 24),
          _buildDisclaimerCard(context),
        ],
      ),
    );
  }

  Widget _buildDocumentResult(BuildContext context, MedicalDataProvider provider) {
    final doc = provider.currentDocument!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.currentImagePath != null)
            _buildImageCard(provider.currentImagePath!),
          const SizedBox(height: 24),
          
          _buildResultHeader(
            context, 
            doc.documentType.replaceAll('_', ' ').toUpperCase(), 
            "Medical Analysis", 
            Icons.description,
            Colors.teal,
          ),
          
          const SizedBox(height: 24),
          if (doc.keyFindings.isNotEmpty)
            _buildFindingsSection(context, doc.keyFindings),
          
          if (doc.abnormalValues.isNotEmpty)
            _buildDangerSection(context, '⚠️ Abnormal Values Detected', doc.abnormalValues),
          
          _buildInfoSection(context, '💡 Recommendations', doc.recommendations, Icons.lightbulb_outline),
          
          const SizedBox(height: 24),
          _buildDisclaimerCard(context),
        ],
      ),
    );
  }

  Widget _buildImagingResult(BuildContext context, MedicalDataProvider provider) {
    final imaging = provider.currentImagingResult!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.currentImagePath != null)
            _buildImageCard(provider.currentImagePath!),
          const SizedBox(height: 24),
          
          _buildResultHeader(
            context, 
            imaging.imagingType, 
            imaging.bodyPart, 
            Icons.biotech,
            Colors.indigo,
          ),
          
          const SizedBox(height: 24),
          _buildPremiumInfoBox(context, 'Assessment', imaging.description, Icons.visibility, Colors.indigo),
          _buildInfoSection(context, 'Observations', imaging.observedAreas, Icons.search),
          
          if (imaging.areasOfInterest.isNotEmpty)
            _buildDangerSection(context, '⚠️ Areas for Review', imaging.areasOfInterest),
          
          _buildPremiumInfoBox(context, 'Explanation', imaging.simpleExplanation, Icons.help_outline, Colors.blueGrey),
          
          const SizedBox(height: 24),
          _buildDisclaimerCard(context),
        ],
      ),
    );
  }

  // ==================== UI Components ====================

  Widget _buildSafetyConflictCard(BuildContext context, List<String> conflicts) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'PERSONAL REACTION WARNING',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...conflicts.map((conflict) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.close, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    conflict,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 8),
          const Text(
            'Important: This is based on your profile health context.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.file(
          File(path),
          height: 240,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildResultHeader(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.circle, size: 6, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 15))),
            ],
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFindingsSection(BuildContext context, List<KeyFinding> findings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('📊 Key Findings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...findings.map((finding) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: Icon(
              finding.isAbnormal ? Icons.warning_rounded : Icons.check_circle_rounded,
              color: finding.isAbnormal ? Colors.red : Colors.green,
            ),
            title: Text(finding.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value: ${finding.value}', style: const TextStyle(fontSize: 13)),
                if (finding.normalRange != null)
                  Text('Normal: ${finding.normalRange!}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: finding.isAbnormal 
              ? const Badge(label: Text('ABNORMAL'), backgroundColor: Colors.red) 
              : null,
          ),
        )),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDangerSection(BuildContext context, String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                const Icon(Icons.remove, size: 14, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(item, style: const TextStyle(color: Colors.red, fontSize: 14))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPremiumInfoBox(BuildContext context, String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildWarningBanner(BuildContext context, String title, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_person, color: Colors.orange, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                Text(message, style: const TextStyle(fontSize: 12, color: Colors.orange)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.gavel, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text('Medical Disclaimer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'This report is generated for educational purposes only. It is not a clinical diagnosis. '
            'Always consult with a qualified medical professional before making any health decisions.',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
