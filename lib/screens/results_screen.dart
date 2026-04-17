import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../providers/medical_data_provider.dart';
import '../models/models.dart';
import '../providers/user_profile_provider.dart';
import '../services/medical_analyzer_service.dart';
import '../services/report_service.dart';
import '../providers/reminder_provider.dart';
import '../models/reminder_model.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/premium_background.dart';
import '../l10n/app_localizations.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  String _getShareSummary(MedicalDataProvider provider) {
    if (provider.currentMedication != null) {
      final med = provider.currentMedication!;
      return 'AI Medicament Scanner Results\n\n'
          'Medication: ${med.name}\n'
          'Active Ingredient: ${med.activeIngredient ?? "N/A"}\n'
          'Used For: ${med.usedFor.join(", ")}\n'
          'Dosage: ${med.dosage ?? "See package"}\n'
          'Side Effects: ${med.sideEffects.join(", ")}\n\n'
          'Disclaimer: For educational purposes only. Consult your doctor.';
    } else if (provider.currentDocument != null) {
      final doc = provider.currentDocument!;
      return 'AI Medicament Scanner Results\n\n'
          'Document Type: ${doc.documentType}\n'
          'Key Findings: ${doc.keyFindings.length} identified\n'
          'Abnormal Values: ${doc.abnormalValues.length} detected\n\n'
          'Disclaimer: For educational purposes only. Consult your doctor.';
    } else if (provider.currentImagingResult != null) {
      final img = provider.currentImagingResult!;
      return 'AI Medicament Scanner Results\n\n'
          'Imaging Type: ${img.imagingType}\n'
          'Body Part: ${img.bodyPart}\n'
          'Areas of Interest: ${img.areasOfInterest.join(", ")}\n\n'
          'Disclaimer: For educational purposes only. Consult your doctor.';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PremiumBackground(
        child: Consumer2<MedicalDataProvider, UserProfileProvider>(
          builder: (context, provider, profileProvider, child) {
          final l10n = AppLocalizations.of(context);
          Widget content;
          String title = l10n.results;
          if (provider.currentMedication != null) {
            content = _buildMedicationResult(context, provider, profileProvider);
            title = l10n.medicationScanner;
          } else if (provider.currentDocument != null) {
            content = _buildDocumentResult(context, provider);
            title = l10n.documentAnalysis;
          } else if (provider.currentImagingResult != null) {
            content = _buildImagingResult(context, provider);
            title = l10n.medicalImaging;
          } else {
            content = Center(child: Text(l10n.done));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: l10n.share,
                    onPressed: () {
                      final summary = _getShareSummary(provider);
                      if (summary.isNotEmpty) {
                        Share.share(summary, subject: '${l10n.appTitle} - ${l10n.results}');
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf),
                    tooltip: l10n.export,
                    onPressed: () {
                      final res = provider.currentMedication ?? provider.currentDocument ?? provider.currentImagingResult;
                      if (res != null) {
                        ReportService().generateAndShareReport(
                          result: res,
                          l10n: l10n,
                          profile: profileProvider.activeProfile,
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
    ),
  );
}

  Widget _buildMedicationResult(BuildContext context, MedicalDataProvider provider, UserProfileProvider profileProvider) {
    final l10n = AppLocalizations.of(context);
    final med = provider.currentMedication!;
    List<String> safetyConflicts = [];
    
    if (profileProvider.activeProfile != null) {
      safetyConflicts = MedicalAnalyzerService().checkSafetyConflicts(med, profileProvider.activeProfile!);
    }

    final reminderProvider = context.watch<ReminderProvider>();
    final activeMedNames = reminderProvider.reminders
        .where((r) => r.isActive)
        .map((r) => r.medicationName)
        .toList();
    
    final interactionWarnings = MedicalAnalyzerService()
        .checkInteractionsWithActiveMeds(med, activeMedNames);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.currentImagePath != null || provider.currentImageBytes != null)
            _buildImageCard(context, provider),
          const SizedBox(height: 24),
          
          if (safetyConflicts.isNotEmpty)
            _buildSafetyConflictCard(context, safetyConflicts),
            
          if (interactionWarnings.isNotEmpty)
            _buildInteractionWarningCard(context, interactionWarnings),
          
          _buildResultHeader(
            context, 
            med.name, 
            med.activeIngredient ?? l10n.medicationScanner, 
            Icons.medication,
            Colors.blue,
          ),
          
          const SizedBox(height: 24),
          _buildActionButtons(context, med),
          const SizedBox(height: 32),
          
          _buildInfoSection(context, l10n.indications, med.usedFor, Icons.medication),
          _buildInfoSection(context, l10n.usageInstructions, med.whenToUse, Icons.access_time),
          _buildDangerSection(context, l10n.contraindications, med.contraindications),
          
          if (med.dosage != null)
            _buildPremiumInfoBox(
              context,
              l10n.dosageGuidance,
              med.dosage!,
              Icons.healing,
              Colors.orange,
            ),
          
          _buildInfoSection(context, l10n.sideEffects, med.sideEffects, Icons.warning_amber),
          
          _buildPremiumInfoBox(
            context,
            l10n.simpleExplanation,
            med.simpleExplanation,
            Icons.psychology,
            Colors.purple,
          ),
          
          if (med.requiresPrescription)
            _buildWarningBanner(context, l10n.safetyAlerts, l10n.disclaimerText),
          
          const SizedBox(height: 24),
          _buildDisclaimerCard(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Medication med) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showSetReminderDialog(context, med),
            icon: const Icon(Icons.alarm_add),
            label: Text(AppLocalizations.of(context).setReminder),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/pharmacy', arguments: med.name);
            },
            icon: const Icon(Icons.local_pharmacy_outlined),
            label: Text(AppLocalizations.of(context).findPharmacy),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              side: const BorderSide(color: Colors.blue),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentResult(BuildContext context, MedicalDataProvider provider) {
    final l10n = AppLocalizations.of(context);
    final doc = provider.currentDocument!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.currentImagePath != null || provider.currentImageBytes != null)
            _buildImageCard(context, provider),
          const SizedBox(height: 24),
          
          _buildResultHeader(
            context, 
            doc.documentType.replaceAll('_', ' ').toUpperCase(), 
            AppLocalizations.of(context).detailedAnalysis, 
            Icons.description,
            Colors.teal,
          ),
          
          const SizedBox(height: 24),
          if (doc.keyFindings.isNotEmpty)
            _buildFindingsSection(context, doc.keyFindings),
          
          if (doc.abnormalValues.isNotEmpty)
            _buildDangerSection(context, '⚠️ ${AppLocalizations.of(context).abnormalValues}', doc.abnormalValues),
          
          _buildInfoSection(context, '💡 ${AppLocalizations.of(context).recommendations}', doc.recommendations, Icons.lightbulb_outline),
          
          const SizedBox(height: 24),
          _buildDisclaimerCard(context),
        ],
      ),
    );
  }

  Widget _buildImagingResult(BuildContext context, MedicalDataProvider provider) {
    final l10n = AppLocalizations.of(context);
    final imaging = provider.currentImagingResult!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.currentImagePath != null || provider.currentImageBytes != null)
            _buildImageCard(context, provider),
          const SizedBox(height: 24),
          
          _buildResultHeader(
            context, 
            imaging.imagingType, 
            imaging.bodyPart, 
            Icons.biotech,
            Colors.indigo,
          ),
          
          const SizedBox(height: 24),
          _buildPremiumInfoBox(context, AppLocalizations.of(context).assessment, imaging.description, Icons.visibility, Colors.indigo),
          _buildInfoSection(context, AppLocalizations.of(context).observations, imaging.observedAreas, Icons.search),
          
          if (imaging.areasOfInterest.isNotEmpty)
            _buildDangerSection(context, '⚠️ ${AppLocalizations.of(context).keyFindings}', imaging.areasOfInterest),
          
          _buildPremiumInfoBox(context, AppLocalizations.of(context).simpleExplanation, imaging.simpleExplanation, Icons.help_outline, Colors.blueGrey),
          
          const SizedBox(height: 24),
          _buildDisclaimerCard(context),
        ],
      ),
    );
  }

  Widget _buildSafetyConflictCard(BuildContext context, List<String> conflicts) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.red.shade300, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.red.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.privacy_tip, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).safetyAlerts.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 32, thickness: 1, color: Colors.red.shade200),
          ...conflicts.map((conflict) {
            final isAllergy = conflict.toLowerCase().contains('allergy');
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    isAllergy ? Icons.science_outlined : Icons.health_and_safety_outlined,
                    color: Colors.red.shade900,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      conflict,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.red.shade900),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).safetyReminder,
                    style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, MedicalDataProvider provider) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: kIsWeb && provider.currentImageBytes != null
            ? Image.memory(
                provider.currentImageBytes!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Image.file(
                File(provider.currentImagePath!),
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
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: color.withValues(alpha: 0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Text(item, style: const TextStyle(fontSize: 14, height: 1.5))),
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text('📊 ${AppLocalizations.of(context).keyFindings}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
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
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.1)),
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
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, size: 18, color: Colors.grey),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context).medicalDisclaimer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).disclaimerText,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _showSetReminderDialog(BuildContext context, Medication med) async {
    TimeOfDay? selectedTime = const TimeOfDay(hour: 9, minute: 0);
    final dosageController = TextEditingController(text: med.dosage?.split(' ').first ?? '1 pill');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Reminder for ${med.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Time'),
                subtitle: Text(selectedTime!.format(context)),
                leading: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(context: context, initialTime: selectedTime!);
                  if (time != null) setState(() => selectedTime = time);
                },
              ),
              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: 'Dosage',
                  hintText: 'e.g. 1 pill, 5ml',
                  prefixIcon: Icon(Icons.healing),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final reminder = MedicationReminder(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  medicationName: med.name,
                  time: selectedTime!,
                  dosage: dosageController.text,
                );
                context.read<ReminderProvider>().addReminder(reminder);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reminder set for ${med.name} at ${selectedTime!.format(context)}')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionWarningCard(BuildContext context, List<String> warnings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Drug-Drug Interaction Alert', 
                   style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...warnings.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                Expanded(child: Text(w, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
