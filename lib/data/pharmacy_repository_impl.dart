import '../../domain/repositories/pharmacy_repository.dart';
import '../../services/pharmacy_service.dart';
import '../../services/pharmacy_api_service.dart';
import '../../services/pharmacy_service.dart' show Pharmacy;

class PharmacyRepositoryImpl implements PharmacyRepository {
  final PharmacyService _service = PharmacyService();

  @override
  Future<List<Pharmacy>> getNearbyPharmacies(String medicationName, {double? lat, double? lng}) {
    return _service.getNearbyPharmacies(medicationName, lat: lat, lng: lng);
  }
}
