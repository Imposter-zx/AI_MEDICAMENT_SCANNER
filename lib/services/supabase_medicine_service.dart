import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/medicine_cache_model.dart';

class SupabaseMedicineService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _tableName = 'user_medicines';

  // Create user profile on first signup
  Future<void> createUserProfile({
    required String userId,
    required String email,
  }) async {
    try {
      await _client.from('users').insert({
        'id': userId,
        'email': email,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('[Supabase] Created user profile: $userId');
    } catch (e) {
      debugPrint('[Supabase] Error creating user profile: $e');
      // Don't rethrow - user profile might already exist
    }
  }

  // Upload medicine to Supabase
  Future<void> uploadMedicine({
    required String userId,
    required MedicineCache medicine,
  }) async {
    try {
      await _client.from(_tableName).insert({
        'user_id': userId,
        'medicine_id': medicine.medicineId,
        'medicine_name': medicine.medicineName,
        'active_ingredient': medicine.activeIngredient,
        'manufacturer': medicine.manufacturer,
        'last_scanned_date': medicine.lastScannedDate.toIso8601String(),
        'scan_count': medicine.scanCount,
        'extracted_ocr_text': medicine.extractedOCRText,
        'created_at': medicine.createdAt.toIso8601String(),
        'synced': true,
      });

      debugPrint('[Supabase] Uploaded medicine: ${medicine.medicineName}');
    } catch (e) {
      debugPrint('[Supabase] Error uploading medicine: $e');
      rethrow;
    }
  }

  // Get user's medicine history from Supabase
  Future<List<MedicineCache>> getUserMedicineHistory(String userId) async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('last_scanned_date', ascending: false);

      final medicines = (data as List<dynamic>)
          .map(
            (doc) => MedicineCache(
              medicineId: doc['medicine_id'],
              medicineName: doc['medicine_name'],
              activeIngredient: doc['active_ingredient'],
              manufacturer: doc['manufacturer'],
              lastScannedDate: DateTime.parse(doc['last_scanned_date']),
              scanCount: doc['scan_count'] ?? 1,
              extractedOCRText: doc['extracted_ocr_text'],
              synced: true,
              createdAt: DateTime.parse(doc['created_at']),
            ),
          )
          .toList();

      debugPrint(
        '[Supabase] Retrieved ${medicines.length} medicines for user: $userId',
      );
      return medicines;
    } catch (e) {
      debugPrint('[Supabase] Error getting medicine history: $e');
      return [];
    }
  }

  // Batch upload medicines
  Future<void> batchUploadMedicines({
    required String userId,
    required List<MedicineCache> medicines,
  }) async {
    try {
      final batch = medicines.map((medicine) {
        return {
          'user_id': userId,
          'medicine_id': medicine.medicineId,
          'medicine_name': medicine.medicineName,
          'active_ingredient': medicine.activeIngredient,
          'manufacturer': medicine.manufacturer,
          'last_scanned_date': medicine.lastScannedDate.toIso8601String(),
          'scan_count': medicine.scanCount,
          'extracted_ocr_text': medicine.extractedOCRText,
          'created_at': medicine.createdAt.toIso8601String(),
          'synced': true,
        };
      }).toList();

      await _client.from(_tableName).insert(batch);
      debugPrint('[Supabase] Batch uploaded ${medicines.length} medicines');
    } catch (e) {
      debugPrint('[Supabase] Error batch uploading medicines: $e');
      rethrow;
    }
  }

  // Delete medicine from Supabase
  Future<void> deleteMedicine({
    required String userId,
    required String medicineId,
  }) async {
    try {
      await _client.from(_tableName).delete().match({
        'user_id': userId,
        'medicine_id': medicineId,
      });
      debugPrint('[Supabase] Deleted medicine: $medicineId');
    } catch (e) {
      debugPrint('[Supabase] Error deleting medicine: $e');
      rethrow;
    }
  }

  // Real-time subscription to user's medicines (SUPABASE FEATURE!)
  Stream<List<MedicineCache>> subscribeToUserMedicines(String userId) {
    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((data) {
          return (data as List<dynamic>)
              .map(
                (doc) => MedicineCache(
                  medicineId: doc['medicine_id'],
                  medicineName: doc['medicine_name'],
                  activeIngredient: doc['active_ingredient'],
                  manufacturer: doc['manufacturer'],
                  lastScannedDate: DateTime.parse(doc['last_scanned_date']),
                  scanCount: doc['scan_count'] ?? 1,
                  extractedOCRText: doc['extracted_ocr_text'],
                  synced: true,
                  createdAt: DateTime.parse(doc['created_at']),
                ),
              )
              .toList();
        });
  }

  // Get medicine stats (total scans, unique medicines) - PostgreSQL query!
  Future<Map<String, dynamic>> getMedicineStats(String userId) async {
    try {
      final stats = await _client.rpc(
        'get_user_medicine_stats',
        params: {'user_id_param': userId},
      );

      debugPrint('[Supabase] Medicine stats: $stats');
      return stats as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[Supabase] Error getting medicine stats: $e');
      return {'total_unique': 0, 'total_scans': 0};
    }
  }

  // Search medicines by name (PostgreSQL full-text search!)
  Future<List<MedicineCache>> searchMedicines({
    required String userId,
    required String query,
  }) async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .match({'user_id': userId})
          .ilike('medicine_name', '%$query%');

      final medicines = (data as List<dynamic>)
          .map(
            (doc) => MedicineCache(
              medicineId: doc['medicine_id'],
              medicineName: doc['medicine_name'],
              activeIngredient: doc['active_ingredient'],
              manufacturer: doc['manufacturer'],
              lastScannedDate: DateTime.parse(doc['last_scanned_date']),
              scanCount: doc['scan_count'] ?? 1,
              extractedOCRText: doc['extracted_ocr_text'],
              synced: true,
              createdAt: DateTime.parse(doc['created_at']),
            ),
          )
          .toList();

      return medicines;
    } catch (e) {
      debugPrint('[Supabase] Error searching medicines: $e');
      return [];
    }
  }

  // Get most frequently scanned medicines
  Future<List<MedicineCache>> getTopScannedMedicines(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('scan_count', ascending: false)
          .limit(limit);

      final medicines = (data as List<dynamic>)
          .map(
            (doc) => MedicineCache(
              medicineId: doc['medicine_id'],
              medicineName: doc['medicine_name'],
              activeIngredient: doc['active_ingredient'],
              manufacturer: doc['manufacturer'],
              lastScannedDate: DateTime.parse(doc['last_scanned_date']),
              scanCount: doc['scan_count'] ?? 1,
              extractedOCRText: doc['extracted_ocr_text'],
              synced: true,
              createdAt: DateTime.parse(doc['created_at']),
            ),
          )
          .toList();

      return medicines;
    } catch (e) {
      debugPrint('[Supabase] Error getting top scanned medicines: $e');
      return [];
    }
  }
}
