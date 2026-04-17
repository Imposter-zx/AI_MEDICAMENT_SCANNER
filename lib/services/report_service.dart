import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../l10n/app_localizations.dart';

class ReportService {
  /// Generate and share a PDF report for any scan type
  Future<void> generateAndShareReport({
    required dynamic result, // Medication, MedicalDocument, or MedicalImagingResult
    required AppLocalizations l10n,
    UserProfile? profile,
  }) async {
    final pdf = pw.Document();
    
    // Load a font that supports international characters and Arabic
    final arabicFont = await PdfGoogleFonts.notoSansArabicRegular();
    final mainFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    
    final date = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final isRtl = l10n.locale.languageCode == 'ar';
    final textDirection = isRtl ? pw.TextDirection.rtl : pw.TextDirection.ltr;

    // Load original image if available
    pw.MemoryImage? resultImage;
    if (result.imagePath != null && result.imagePath!.isNotEmpty) {
      try {
        final file = File(result.imagePath!);
        if (await file.exists()) {
          resultImage = pw.MemoryImage(await file.readAsBytes());
        }
      } catch (e) {
        // Silently skip image if load fails
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: mainFont,
          bold: boldFont,
          fontFallback: [arabicFont],
        ),
        build: (pw.Context context) {
          return [
            _buildHeader(date, l10n, textDirection),
            pw.SizedBox(height: 20),
            if (profile != null) _buildUserProfileSection(profile, l10n, textDirection),
            pw.SizedBox(height: 20),
            
            // Type-specific content
            if (result is Medication) ..._buildMedicationContent(result, l10n, textDirection, resultImage),
            if (result is MedicalDocument) ..._buildDocumentContent(result, l10n, textDirection, resultImage),
            if (result is MedicalImagingResult) ..._buildImagingContent(result, l10n, textDirection, resultImage),
            
            pw.SizedBox(height: 20),
            _buildFooter(l10n, textDirection),
          ];
        },
      ),
    );

    final filename = _getFilename(result);
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: filename,
    );
  }

  String _getFilename(dynamic result) {
    String name = 'Medical_Report';
    if (result is Medication) name = result.name;
    if (result is MedicalDocument) name = result.documentType;
    if (result is MedicalImagingResult) name = '${result.imagingType}_${result.bodyPart}';
    return '${name.replaceAll(' ', '_')}_Report.pdf';
  }

  pw.Widget _buildHeader(String date, AppLocalizations l10n, pw.TextDirection direction) {
    return pw.Directionality(
      textDirection: direction,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l10n.appTitle.toUpperCase(), 
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold, color: PdfColors.blue900)),
              pw.Text(l10n.detailedAnalysis, 
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
            ],
          ),
          pw.Text('${l10n.date}: $date', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ],
      ),
    );
  }

  pw.Widget _buildUserProfileSection(UserProfile profile, AppLocalizations l10n, pw.TextDirection direction) {
    return pw.Directionality(
      textDirection: direction,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          color: PdfColors.blue50,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
          border: pw.Border.all(color: PdfColors.blue100),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(l10n.profile.toUpperCase(), 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.blue800)),
            pw.SizedBox(height: 4),
            pw.Text('${l10n.patientName}: ${profile.name} ${profile.age != null ? '(${profile.age} ${l10n.years})' : ''}'),
            if (profile.allergies.isNotEmpty) 
              pw.Text('${l10n.safetyAlerts}: ${profile.allergies.join(", ")}', 
                style: pw.TextStyle(color: PdfColors.red700, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  List<pw.Widget> _buildMedicationContent(Medication med, AppLocalizations l10n, pw.TextDirection direction, pw.MemoryImage? image) {
    return [
      _buildSectionHeader(med.name.toUpperCase(), PdfColors.blue800, direction),
      pw.SizedBox(height: 10),
      if (image != null) _buildResultImage(image),
      _buildInfoSection(l10n.simpleExplanation, med.simpleExplanation, direction),
      _buildInfoSection(l10n.indications, med.usedFor.join(', '), direction),
      _buildInfoSection(l10n.usageInstructions, med.whenToUse.join('\n• '), direction),
      if (med.dosage != null) _buildInfoSection(l10n.dosageGuidance, med.dosage!, direction),
      _buildInfoSection(l10n.sideEffects, med.sideEffects.join(', '), direction),
      pw.SizedBox(height: 10),
      _buildWarningSection(l10n.contraindications, med.contraindications.join('\n• '), direction),
    ];
  }

  List<pw.Widget> _buildDocumentContent(MedicalDocument doc, AppLocalizations l10n, pw.TextDirection direction, pw.MemoryImage? image) {
    return [
      _buildSectionHeader(doc.documentType.toUpperCase(), PdfColors.orange800, direction),
      pw.SizedBox(height: 10),
      if (image != null) _buildResultImage(image),
      pw.SizedBox(height: 10),
      pw.Text(l10n.keyFindings, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue800)),
      pw.SizedBox(height: 8),
      _buildFindingsTable(doc.keyFindings, l10n, direction),
      pw.SizedBox(height: 15),
      if (doc.abnormalValues.isNotEmpty)
        _buildWarningSection(l10n.abnormalValues, doc.abnormalValues.join('\n• '), direction),
      _buildInfoSection(l10n.recommendations, doc.recommendations.join('\n• '), direction),
    ];
  }

  List<pw.Widget> _buildImagingContent(MedicalImagingResult result, AppLocalizations l10n, pw.TextDirection direction, pw.MemoryImage? image) {
    return [
      _buildSectionHeader('${result.imagingType} - ${result.bodyPart}'.toUpperCase(), PdfColors.teal800, direction),
      pw.SizedBox(height: 10),
      if (image != null) _buildResultImage(image),
      _buildInfoSection(l10n.simpleExplanation, result.simpleExplanation, direction),
      _buildInfoSection(l10n.observations, result.description, direction),
      _buildInfoSection(l10n.assessment, '${l10n.keyFindings}: ${result.observedAreas.join(", ")}', direction),
      _buildInfoSection(l10n.recommendations, result.areasOfInterest.join('\n• '), direction),
      if (result.requiresUrgentReview)
        _buildWarningSection(l10n.safetyAlerts, l10n.consultDoctor, direction, isUrgent: true),
    ];
  }

  pw.Widget _buildSectionHeader(String title, PdfColor color, pw.TextDirection direction) {
    return pw.Directionality(
      textDirection: direction,
      child: pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        color: color,
        child: pw.Text(title, style: pw.TextStyle(color: PdfColors.white, fontSize: 16, fontWeight: pw.FontWeight.bold)),
      ),
    );
  }

  pw.Widget _buildInfoSection(String title, String content, pw.TextDirection direction) {
    return pw.Directionality(
      textDirection: direction,
      child: pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 6),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.blue800)),
            pw.SizedBox(height: 2),
            pw.Text(content, style: const pw.TextStyle(fontSize: 10, lineSpacing: 2)),
            pw.SizedBox(height: 4),
            pw.Divider(color: PdfColors.grey200, thickness: 0.5),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildFindingsTable(List<KeyFinding> findings, AppLocalizations l10n, pw.TextDirection direction) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        // Table Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l10n.testMarker, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l10n.value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(l10n.normalRange, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10))),
          ],
        ),
        // Table Rows
        ...findings.map((f) => pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(f.label, style: pw.TextStyle(fontSize: 9, color: f.isAbnormal ? PdfColors.red : PdfColors.black))),
            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(f.value, style: pw.TextStyle(fontSize: 9, fontWeight: f.isAbnormal ? pw.FontWeight.bold : pw.FontWeight.normal))),
            pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(f.normalRange ?? '-', style: const pw.TextStyle(fontSize: 9))),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildResultImage(pw.MemoryImage image) {
    return pw.Container(
      height: 150,
      width: double.infinity,
      decoration: const pw.BoxDecoration(
        color: PdfColors.grey100,
      ),
      child: pw.Center(
        child: pw.Image(image, fit: pw.BoxFit.contain),
      ),
    );
  }

  pw.Widget _buildWarningSection(String title, String content, pw.TextDirection direction, {bool isUrgent = false}) {
    return pw.Directionality(
      textDirection: direction,
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: isUrgent ? PdfColors.red700 : PdfColors.orange300),
          color: isUrgent ? PdfColors.red50 : PdfColors.orange50,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title.toUpperCase(), 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: isUrgent ? PdfColors.red900 : PdfColors.orange900)),
            pw.SizedBox(height: 4),
            pw.Text(content, style: pw.TextStyle(fontSize: 9, color: isUrgent ? PdfColors.red800 : PdfColors.orange800)),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildFooter(AppLocalizations l10n, pw.TextDirection direction) {
    return pw.Directionality(
      textDirection: direction,
      child: pw.Column(
        children: [
          pw.Divider(thickness: 0.5),
          pw.Text(l10n.medicalDisclaimer, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9, color: PdfColors.grey800)),
          pw.SizedBox(height: 2),
          pw.Text(l10n.disclaimerText,
            textAlign: pw.TextAlign.center,
            style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600)),
        ],
      ),
    );
  }
}
