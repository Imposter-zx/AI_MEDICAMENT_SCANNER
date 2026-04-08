import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _client.auth.currentUser != null;

  // Get user ID
  String? get userId => _client.auth.currentUser?.id;

  // Get user email
  String? get email => _client.auth.currentUser?.email;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );

      debugPrint('[Auth] User signed up: $email');
      return response;
    } on AuthException catch (e) {
      debugPrint('[Auth] Sign up error: ${e.message}');
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('[Auth] User signed in: $email');
      return response;
    } on AuthException catch (e) {
      debugPrint('[Auth] Sign in error: ${e.message}');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('[Auth] User signed out');
    } catch (e) {
      debugPrint('[Auth] Sign out error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      debugPrint('[Auth] Password reset email sent to: $email');
    } on AuthException catch (e) {
      debugPrint('[Auth] Reset password error: ${e.message}');
      rethrow;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> authStateChanges() {
    return _client.auth.onAuthStateChange;
  }
}
