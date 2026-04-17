import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pharmacy_service.dart';

class PharmacyApiService {
  final String _apiKey;
  PharmacyApiService(this._apiKey);

  // Google Places Nearby Search
  Future<List<Pharmacy>> searchNearby({
    required double lat,
    required double lng,
    int radius = 2000,
  }) async {
    final url =
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/nearbysearch/json',
        ).replace(
          queryParameters: {
            'location': '$lat,$lng',
            'radius': radius.toString(),
            'type': 'pharmacy',
            'key': _apiKey,
          },
        );

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch pharmacies');
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? []);
    List<Pharmacy> pharmacies = [];
    for (final item in results) {
      final name = item['name'] as String? ?? '';
      final vicinity = item['vicinity'] as String? ?? '';
      final location = item['geometry']?['location'];
      final lat2 = (location?['lat'] as num?)?.toDouble() ?? lat;
      final lng2 = (location?['lng'] as num?)?.toDouble() ?? lng;
      pharmacies.add(
        Pharmacy(
          id: item['place_id'] ?? name,
          name: name,
          address: vicinity,
          distance: 0.0,
          isOpen: true,
          hasStock: true,
          phone: '',
          latitude: lat2,
          longitude: lng2,
        ),
      );
    }
    // Deduplicate by name without using extension
    final Map<String, Pharmacy> unique = {};
    for (final p in pharmacies) {
      unique[p.name] = p;
    }
    return unique.values.toList();
  }
}
