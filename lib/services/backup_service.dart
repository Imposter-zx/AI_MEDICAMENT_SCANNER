import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'storage_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final StorageService _storage = StorageService();

  Future<String> exportAndShare() async {
    try {
      final data = await _storage.exportAllData();
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/mediscanner_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(data);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'AI Medicament Scanner - Data Backup',
        subject: 'Mediscanner Backup',
      );

      return file.path;
    } catch (e) {
      debugPrint('Export error: $e');
      rethrow;
    }
  }

  Future<bool> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) return false;

      final file = File(result.files.single.path!);
      final content = await file.readAsString();

      return await _storage.importData(content);
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  Future<void> clearAllData() async {
    await _storage.deleteAllSecure();
  }
}
