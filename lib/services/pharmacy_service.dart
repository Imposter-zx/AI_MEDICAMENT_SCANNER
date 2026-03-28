import 'dart:math';

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
  Future<List<Pharmacy>> getNearbyPharmacies(String medicationName) async {
    // Simulating API call delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    final random = Random();
    return [
      Pharmacy(
        id: '1',
        name: 'City Care Pharmacy',
        address: '123 Main St, Downtown',
        distance: 0.8,
        isOpen: true,
        hasStock: random.nextBool(),
        phone: '(555) 123-4567',
        latitude: 40.7128,
        longitude: -74.0060,
      ),
      Pharmacy(
        id: '2',
        name: 'HealthPoint Wellness',
        address: '456 Oak Ave, Westside',
        distance: 1.5,
        isOpen: true,
        hasStock: true,
        phone: '(555) 987-6543',
        latitude: 40.7138,
        longitude: -74.0070,
      ),
      Pharmacy(
        id: '3',
        name: 'Green Cross Apothecary',
        address: '789 Pine Rd, East End',
        distance: 2.3,
        isOpen: false,
        hasStock: random.nextBool(),
        phone: '(555) 456-7890',
        latitude: 40.7118,
        longitude: -74.0050,
      ),
      Pharmacy(
        id: '4',
        name: 'MedExpress 24/7',
        address: '555 Boulevard of Health',
        distance: 3.1,
        isOpen: true,
        hasStock: true,
        phone: '(555) 111-2222',
        latitude: 40.7148,
        longitude: -74.0040,
      ),
    ];
  }
}
