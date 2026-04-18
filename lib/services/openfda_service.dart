import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class OpenFDAService {
  static const String _baseUrl = 'https://api.fda.gov/drug/label.json';

  /// Search OpenFDA using a barcode/UPC
  Future<Medication?> searchByUpc(String upc) async {
    try {
      final uri = Uri.parse('$_baseUrl?search=openfda.upc:"$upc"&limit=1');
      return await _fetchMedication(uri);
    } catch (_) {
      return null;
    }
  }

  /// Fuzzy search using a brand or generic name
  Future<Medication?> searchByName(String name) async {
    try {
      final query = Uri.encodeComponent('openfda.brand_name:"$name" openfda.generic_name:"$name"');
      final uri = Uri.parse('$_baseUrl?search=$query&limit=1');
      return await _fetchMedication(uri);
    } catch (_) {
      return null;
    }
  }

  Future<Medication?> _fetchMedication(Uri uri) async {
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final results = data['results'] as List<dynamic>?;
      
      if (results != null && results.isNotEmpty) {
        final result = results.first as Map<String, dynamic>;
        final openfda = result['openfda'] as Map<String, dynamic>? ?? {};

        // Parse fields safely
        final brandName = (openfda['brand_name'] as List<dynamic>?)?.firstOrNull?.toString() ?? 'Unknown Medication';
        final genericName = (openfda['generic_name'] as List<dynamic>?)?.firstOrNull?.toString();
        final manufacturer = (openfda['manufacturer_name'] as List<dynamic>?)?.firstOrNull?.toString();
        
        final usage = (result['indications_and_usage'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final dosage = (result['dosage_and_administration'] as List<dynamic>?)?.firstOrNull?.toString();
        final adverse = (result['adverse_reactions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final contra = (result['contraindications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
        final description = (result['description'] as List<dynamic>?)?.firstOrNull?.toString() ?? 'FDA Registered Medication';

        return Medication(
          name: brandName,
          activeIngredient: genericName,
          manufacturer: manufacturer,
          usedFor: usage.isNotEmpty ? usage : ['Information not available'],
          whenToUse: [],
          contraindications: contra.isNotEmpty ? contra : ['Information not available'],
          dosage: dosage ?? 'Follow precise clinician instructions.',
          sideEffects: adverse.isNotEmpty ? adverse : ['Information not available'],
          simpleExplanation: description.length > 200 ? '${description.substring(0, 200)}...' : description,
          requiresPrescription: true, // Safety default for OpenFDA fetched drugs
        );
      }
    }
    return null;
  }
}
