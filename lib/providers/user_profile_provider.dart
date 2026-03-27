import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfile? _profile;
  bool _isLoaded = false;

  UserProfile? get profile => _profile;
  bool get isLoaded => _isLoaded;

  UserProfileProvider() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('user_profile');
      if (profileJson != null) {
        _profile = UserProfile.fromMap(json.decode(profileJson));
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading profile: $e");
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    try {
      _profile = profile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(profile.toMap()));
      notifyListeners();
    } catch (e) {
      debugPrint("Error saving profile: $e");
    }
  }

  Future<void> clearProfile() async {
    _profile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    notifyListeners();
  }
}
