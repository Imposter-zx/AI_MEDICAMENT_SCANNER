import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static Future<void> init({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    try {
      await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
      debugPrint('[Supabase] Initialized successfully');
    } catch (e) {
      debugPrint('[Supabase] Initialization error: $e');
      rethrow;
    }
  }

  // Get Supabase client instance
  static SupabaseClient get client => Supabase.instance.client;

  // Get current session
  static Session? get currentSession =>
      Supabase.instance.client.auth.currentSession;
}
