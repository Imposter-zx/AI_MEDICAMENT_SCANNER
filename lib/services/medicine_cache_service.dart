import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/medicine_cache_model.dart';

class MedicineCacheService {
  static const String _cacheFileName = 'medicine_cache.json';
  late Directory _appDocsDir;
  List<MedicineCache> _cache = [];
  bool _initialized = false;

  // Initialize cache from file
  Future<void> init() async {
    try {
      _appDocsDir = await getApplicationDocumentsDirectory();
      await _loadCacheFromFile();
      _initialized = true;
      debugPrint(
        '[MedicineCache] Initialized with ${_cache.length} cached medicines',
      );
    } catch (e) {
      debugPrint('[MedicineCache] Init error: $e');
    }
  }

  // Load cache from JSON file
  Future<void> _loadCacheFromFile() async {
    try {
      final cacheFile = File('${_appDocsDir.path}/$_cacheFileName');

      if (await cacheFile.exists()) {
        final content = await cacheFile.readAsString();
        final List<dynamic> jsonList = json.decode(content) ?? [];

        _cache = jsonList
            .map((item) => MedicineCache.fromJson(item as Map<String, dynamic>))
            .toList();

        debugPrint(
          '[MedicineCache] Loaded ${_cache.length} medicines from cache file',
        );
      }
    } catch (e) {
      debugPrint('[MedicineCache] Error loading cache: $e');
      _cache = [];
    }
  }

  // Save cache to JSON file
  Future<void> _saveCacheToFile() async {
    try {
      final cacheFile = File('${_appDocsDir.path}/$_cacheFileName');
      final jsonList = _cache.map((m) => m.toJson()).toList();
      await cacheFile.writeAsString(json.encode(jsonList));
      debugPrint(
        '[MedicineCache] Saved ${_cache.length} medicines to cache file',
      );
    } catch (e) {
      debugPrint('[MedicineCache] Error saving cache: $e');
    }
  }

  // Search for medicine in cache by name
  MedicineCache? getMedicineByName(String medicineName) {
    try {
      return _cache.firstWhere(
        (m) => m.medicineName.toLowerCase() == medicineName.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Get all cached medicines
  List<MedicineCache> getAllCachedMedicines() => List.from(_cache);

  // Add or update medicine in cache
  Future<void> addOrUpdateMedicine(MedicineCache medicine) async {
    final existingIndex = _cache.indexWhere(
      (m) => m.medicineId == medicine.medicineId,
    );

    if (existingIndex >= 0) {
      // Update existing: increment scan count
      _cache[existingIndex] = _cache[existingIndex].copyWith(
        lastScannedDate: DateTime.now(),
        scanCount: _cache[existingIndex].scanCount + 1,
        synced: false, // Mark for re-sync
      );
      debugPrint('[MedicineCache] Updated cache for: ${medicine.medicineName}');
    } else {
      // Add new
      _cache.insert(0, medicine);
      debugPrint(
        '[MedicineCache] Added new medicine to cache: ${medicine.medicineName}',
      );
    }

    await _saveCacheToFile();
  }

  // Mark medicine as synced
  Future<void> markMedicineSynced(String medicineId) async {
    final index = _cache.indexWhere((m) => m.medicineId == medicineId);
    if (index >= 0) {
      _cache[index] = _cache[index].copyWith(synced: true);
      await _saveCacheToFile();
      debugPrint('[MedicineCache] Marked synced: $medicineId');
    }
  }

  // Get unsynced medicines
  List<MedicineCache> getUnsyncedMedicines() {
    return _cache.where((m) => !m.synced).toList();
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      _cache.clear();
      final cacheFile = File('${_appDocsDir.path}/$_cacheFileName');
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      debugPrint('[MedicineCache] Cache cleared');
    } catch (e) {
      debugPrint('[MedicineCache] Error clearing cache: $e');
    }
  }

  // Check cache size
  int getCacheSize() => _cache.length;

  // Get cache file path for debugging
  String getCacheFilePath() => '${_appDocsDir.path}/$_cacheFileName';
}
