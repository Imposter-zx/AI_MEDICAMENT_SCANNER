import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'pharmacy_api_service.dart';

class Pharmacy {
  final String id;
  final String name;
  final String address;
  final double distance; // in km
  final bool isOpen;
  final bool hasStock;
  final String phone;
  final double latitude;
  final double longitude;

  Pharmacy({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.isOpen,
    required this.hasStock,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });
}

class PharmacyService {
  Future<List<Pharmacy>> getNearbyPharmacies(String medicationName, {double? lat, double? lng}) async {
    // Attempt real API first if key is provided
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString('places_api_key');
      if (apiKey != null && apiKey.isNotEmpty) {
        final api = PharmacyApiService(apiKey);
        // Use provided coordinates if available, otherwise fall back to a default
        final double latVal = lat ?? 40.7128;
        final double lngVal = lng ?? -74.0060;
        final results = await api.searchNearby(lat: latVal, lng: lngVal);
        if (results.isNotEmpty) return results;
      }
    } catch (_) {
      // Fall back to mock data on error
    }
    // Production path requires a Places API key; if missing we error out to production-friendly UI
    // Do not return mock data in production path
    throw Exception('Missing Google Places API Key. Please set the key in Settings (Places API Key).');
  }
}
