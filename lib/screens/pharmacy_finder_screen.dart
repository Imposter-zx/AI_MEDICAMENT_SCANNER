import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../data/pharmacy_repository_impl.dart';
import '../domain/repositories/pharmacy_repository.dart';
import '../services/pharmacy_service.dart';

class PharmacyFinderScreen extends StatefulWidget {
  final String? medicationName;
  const PharmacyFinderScreen({super.key, this.medicationName});

  @override
  State<PharmacyFinderScreen> createState() => _PharmacyFinderScreenState();
}

class _PharmacyFinderScreenState extends State<PharmacyFinderScreen> {
  late PharmacyRepository _pharmacyRepo;
  // Deprecated: using repository in production path
  bool _isLoading = true;
  List<Pharmacy> _pharmacies = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _pharmacyRepo = PharmacyRepositoryImpl();
    _loadPharmacies();
  }

  Future<void> _loadPharmacies() async {
    setState(() => _isLoading = true);
    // Try to get current location; fallback to a default if unavailable
    double lat = 40.7128;
    double lng = -74.0060;
    try {
      Position pos = await _determinePosition();
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {
      // keep defaults
    }
    try {
      final results = await _pharmacyRepo.getNearbyPharmacies(widget.medicationName ?? 'Generic', lat: lat, lng: lng);
      setState(() {
        _pharmacies = results;
        _isLoading = false;
        _errorMessage = (results.isEmpty) ? 'Live data unavailable. Please configure a Places API key.' : null;
      });
    } catch (e) {
      setState(() {
        _pharmacies = [];
        _isLoading = false;
        _errorMessage = 'Unable to fetch live data: ${e.toString()}';
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable in settings
      throw Exception('Location services are disabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Pharmacy Finder'),
        actions: [
          IconButton(
            onPressed: _loadPharmacies,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null) ...[
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                ],
              ),
            )
          ],
          _buildMapHeader(),
          _buildSearchContext(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPharmacyList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapHeader() {
    final markers = _pharmacies.map((p) {
      return Marker(
        markerId: MarkerId(p.id),
        position: LatLng(p.latitude, p.longitude),
        infoWindow: InfoWindow(title: p.name, snippet: p.address),
      );
    }).toSet();

    return SizedBox(
      height: 260,
      width: double.infinity,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(40.7128, -74.0060), zoom: 12),
        markers: markers,
        onMapCreated: (_) {},
      ),
    );
  }

  Widget _buildSearchContext() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.medicationName != null
                  ? 'Showing pharmacies stocked with "${widget.medicationName}" near current location.'
                  : 'Showing nearby pharmacies near current location.',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyList() {
    if (_pharmacies.isEmpty) {
      return const Center(child: Text('No pharmacies found nearby.'));
    }

    return ListView.builder(
      itemCount: _pharmacies.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final pharmacy = _pharmacies[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        pharmacy.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '${pharmacy.distance} km',
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  pharmacy.address,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildTag(
                      pharmacy.isOpen ? 'OPEN' : 'CLOSED',
                      pharmacy.isOpen ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    if (pharmacy.hasStock)
                      _buildTag('IN STOCK', Colors.blue)
                    else
                      _buildTag('OUT OF STOCK', Colors.orange),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final telUri = Uri.parse('tel:${pharmacy.phone}');
                          if (await canLaunchUrl(telUri)) {
                            await launchUrl(telUri);
                          }
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final mapsUri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${pharmacy.latitude},${pharmacy.longitude}');
                          if (await canLaunchUrl(mapsUri)) {
                            await launchUrl(mapsUri);
                          }
                        },
                        icon: const Icon(Icons.directions),
                        label: const Text('Directions'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }
}
