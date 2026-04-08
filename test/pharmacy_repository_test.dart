import 'package:ai_medicament_scanner/data/pharmacy_repository_impl.dart';
import 'package:ai_medicament_scanner/domain/repositories/pharmacy_repository.dart';
import 'package:test/test.dart';

void main() {
  group('PharmacyRepository production path', () {
    test('requires Google Places API key for live data', () async {
      final repo = PharmacyRepositoryImpl();
      expect(
        repo.getNearbyPharmacies('A', lat: 40.0, lng: -74.0),
        throwsA(isA<Exception>()),
      );
    });
  });
}
