import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class UserProfileProvider with ChangeNotifier {
  List<UserProfile> _profiles = [];
  String? _activeProfileId;
  bool _isLoaded = false;

  List<UserProfile> get profiles => _profiles;
  String? get activeProfileId => _activeProfileId;
  bool get isLoaded => _isLoaded;

  UserProfile? get activeProfile {
    if (_activeProfileId == null || _profiles.isEmpty) return null;
    return _profiles.firstWhere((p) => p.id == _activeProfileId, orElse: () => _profiles.first);
  }

  UserProfileProvider() {
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getStringList('user_profiles');
      
      if (profilesJson != null && profilesJson.isNotEmpty) {
        _profiles = profilesJson
            .map((p) => UserProfile.fromMap(json.decode(p)))
            .toList();
        _activeProfileId = prefs.getString('active_profile_id') ?? _profiles.first.id;
      } else {
        // Migration/Initial: Create default profile if none exists
        final oldProfileJson = prefs.getString('user_profile');
        if (oldProfileJson != null) {
          final oldProfile = UserProfile.fromMap(json.decode(oldProfileJson));
          _profiles = [oldProfile];
          _activeProfileId = oldProfile.id;
          await saveProfiles();
          await prefs.remove('user_profile'); // Clean up old key
        }
      }
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading profiles: $e");
      _isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> saveProfiles() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = _profiles.map((p) => json.encode(p.toMap())).toList();
      await prefs.setStringList('user_profiles', profilesJson);
      if (_activeProfileId != null) {
        await prefs.setString('active_profile_id', _activeProfileId!);
      }
    } catch (e) {
      debugPrint("Error saving profiles: $e");
    }
  }

  Future<void> setActiveProfile(String id) async {
    if (_profiles.any((p) => p.id == id)) {
      _activeProfileId = id;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_profile_id', id);
      notifyListeners();
    }
  }

  Future<void> addProfile(UserProfile profile) async {
    _profiles.add(profile);
    if (_activeProfileId == null) {
      _activeProfileId = profile.id;
    }
    await saveProfiles();
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index != -1) {
      _profiles[index] = updatedProfile;
      await saveProfiles();
      notifyListeners();
    }
  }

  Future<void> deleteProfile(String id) async {
    // Prevent deleting the last profile
    if (_profiles.length <= 1) return;
    
    _profiles.removeWhere((p) => p.id == id);
    if (_activeProfileId == id) {
      _activeProfileId = _profiles.first.id;
    }
    await saveProfiles();
    notifyListeners();
  }
}
