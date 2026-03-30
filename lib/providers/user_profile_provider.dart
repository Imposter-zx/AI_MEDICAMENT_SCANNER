import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class UserProfileProvider with ChangeNotifier {
  final StorageService _storage = StorageService();
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
      await _storage.migrateIfNeeded();
      final profilesJson = await _storage.getProfiles();

      if (profilesJson.isNotEmpty) {
        _profiles = profilesJson
            .map((p) => UserProfile.fromMap(json.decode(p)))
            .toList();
        _activeProfileId = await _storage.getActiveProfileId() ?? _profiles.first.id;
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
      final profilesJson = _profiles.map((p) => json.encode(p.toMap())).toList();
      await _storage.setProfiles(profilesJson);
      if (_activeProfileId != null) {
        await _storage.setActiveProfileId(_activeProfileId!);
      }
    } catch (e) {
      debugPrint("Error saving profiles: $e");
    }
  }

  Future<void> setActiveProfile(String id) async {
    if (_profiles.any((p) => p.id == id)) {
      _activeProfileId = id;
      await _storage.setActiveProfileId(id);
      notifyListeners();
    }
  }

  void clearAll() {
    _profiles = [];
    _activeProfileId = null;
    notifyListeners();
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
