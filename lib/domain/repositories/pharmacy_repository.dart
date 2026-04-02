import 'package:ai_medicament_scanner/services/pharmacy_service.dart';

abstract class PharmacyRepository {
  Future<List<Pharmacy>> getNearbyPharmacies(String medicationName, {double? lat, double? lng});
}
