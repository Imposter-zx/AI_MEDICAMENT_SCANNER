import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_auth_service.dart';
import '../services/supabase_service.dart';
import '../services/supabase_medicine_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseAuthService _authService = SupabaseAuthService();
  final SupabaseMedicineService _medicineService = SupabaseMedicineService();
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  bool _supabaseInitialized = false;

  User? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get supabaseInitialized => _supabaseInitialized;

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Note: Supabase is already initialized in main.dart via SupabaseService
      _supabaseInitialized = true;

      _authService.authStateChanges().listen((authState) {
        _currentUser = authState.session?.user;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('[AuthProvider] Init error: $e');
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.signUp(
        email: email,
        password: password,
      );

      // Create user profile in Supabase
      if (authResponse.user != null) {
        await _medicineService.createUserProfile(
          userId: authResponse.user!.id,
          email: email,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = _formatErrorMessage(e.toString());
      notifyListeners();
    }
  }

  Future<bool> resetPassword({required String email}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email: email);
      _isLoading = false;
      _errorMessage = 'Password reset email sent. Check your inbox.';
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _formatErrorMessage(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  String _formatErrorMessage(String error) {
    if (error.contains('weak-password')) {
      return 'Password is too weak. Use at least 6 characters.';
    } else if (error.contains('email-already-in-use')) {
      return 'Email is already in use. Try logging in.';
    } else if (error.contains('user-not-found')) {
      return 'User not found. Please sign up first.';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Try again.';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address.';
    } else {
      return error;
    }
  }
}
