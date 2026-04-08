import 'package:flutter/material.dart';
import '../models/medicine_cache_model.dart';
import '../services/medicine_cache_service.dart';
import '../services/supabase_medicine_service.dart';
import '../services/supabase_auth_service.dart';

class MedicineSyncProvider with ChangeNotifier {
  final MedicineCacheService _cacheService = MedicineCacheService();
  final SupabaseMedicineService _supabaseService = SupabaseMedicineService();
  final SupabaseAuthService _authService = SupabaseAuthService();

  List<MedicineCache> _cachedMedicines = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicineCache> get cachedMedicines => _cachedMedicines;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MedicineSyncProvider() {
    _init();
  }

  Future<void> _init() async {
    await _cacheService.init();
  }

  // Load cached medicines from local storage
  Future<void> loadCachedMedicines() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cachedMedicines = _cacheService.getAllCachedMedicines();
      _isLoading = false;
      notifyListeners();
      debugPrint(
        '[MedicineSyncProvider] Loaded ${_cachedMedicines.length} medicines',
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[MedicineSyncProvider] Error loading medicines: $e');
    }
  }

  // Add medicine to cache and sync to Supabase
  Future<void> addMedicineAndSync(MedicineCache medicine) async {
    try {
      // Add to local cache
      await _cacheService.addOrUpdateMedicine(medicine);
      _cachedMedicines = _cacheService.getAllCachedMedicines();
      notifyListeners();

      // Sync to Supabase if user is signed in
      if (_authService.isSignedIn && _authService.userId != null) {
        await _supabaseService.uploadMedicine(
          userId: _authService.userId!,
          medicine: medicine,
        );
        await _cacheService.markMedicineSynced(medicine.medicineId);
        _cachedMedicines = _cacheService.getAllCachedMedicines();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[MedicineSyncProvider] Error adding medicine: $e');
    }
  }

  // Sync unsynced medicines to Supabase
  Future<void> syncUnsyncedMedicines() async {
    if (!_authService.isSignedIn || _authService.userId == null) {
      _errorMessage = 'User not signed in. Please sign in to sync.';
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final unsyncedMedicines = _cacheService.getUnsyncedMedicines();

      if (unsyncedMedicines.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _supabaseService.batchUploadMedicines(
        userId: _authService.userId!,
        medicines: unsyncedMedicines,
      );

      // Mark all as synced
      for (final medicine in unsyncedMedicines) {
        await _cacheService.markMedicineSynced(medicine.medicineId);
      }

      _cachedMedicines = _cacheService.getAllCachedMedicines();
      _isLoading = false;
      notifyListeners();
      debugPrint(
        '[MedicineSyncProvider] Synced ${unsyncedMedicines.length} medicines',
      );
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('[MedicineSyncProvider] Error syncing: $e');
    }
  }

  // Delete medicine from cache and Supabase
  Future<void> deleteMedicine(String medicineId) async {
    try {
      // Delete from Supabase if user is signed in
      if (_authService.isSignedIn && _authService.userId != null) {
        await _supabaseService.deleteMedicine(
          userId: _authService.userId!,
          medicineId: medicineId,
        );
      }

      // Remove from cache
      _cachedMedicines.removeWhere((m) => m.medicineId == medicineId);
      notifyListeners();
      debugPrint('[MedicineSyncProvider] Deleted medicine: $medicineId');
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      debugPrint('[MedicineSyncProvider] Error deleting medicine: $e');
    }
  }

  // Check if medicine exists in cache by name
  MedicineCache? getMedicineByName(String medicineName) {
    return _cacheService.getMedicineByName(medicineName);
  }

  // Search medicines in Supabase (SUPABASE FEATURE!)
  Future<List<MedicineCache>> searchMedicines(String query) async {
    if (!_authService.isSignedIn || _authService.userId == null) {
      return [];
    }

    try {
      return await _supabaseService.searchMedicines(
        userId: _authService.userId!,
        query: query,
      );
    } catch (e) {
      debugPrint('[MedicineSyncProvider] Error searching: $e');
      return [];
    }
  }

  // Get top scanned medicines (SUPABASE FEATURE!)
  Future<List<MedicineCache>> getTopScannedMedicines({int limit = 10}) async {
    if (!_authService.isSignedIn || _authService.userId == null) {
      return [];
    }

    try {
      return await _supabaseService.getTopScannedMedicines(
        _authService.userId!,
        limit: limit,
      );
    } catch (e) {
      debugPrint('[MedicineSyncProvider] Error getting top scanned: $e');
      return [];
    }
  }

  // Clear all cache
  Future<void> clearCache() async {
    try {
      await _cacheService.clearCache();
      _cachedMedicines.clear();
      notifyListeners();
      debugPrint('[MedicineSyncProvider] Cache cleared');
    } catch (e) {
      debugPrint('[MedicineSyncProvider] Error clearing cache: $e');
    }
  }

  // Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'totalMedicines': _cachedMedicines.length,
      'unsyncedCount': _cacheService.getUnsyncedMedicines().length,
      'syncedCount': _cachedMedicines.where((m) => m.synced).length,
      'totalScans': _cachedMedicines.fold<int>(
        0,
        (sum, m) => sum + m.scanCount,
      ),
    };
  }
}
