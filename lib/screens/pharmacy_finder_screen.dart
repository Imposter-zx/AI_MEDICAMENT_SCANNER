import 'package:flutter/material.dart';
import '../services/pharmacy_service.dart';

class PharmacyFinderScreen extends StatefulWidget {
  final String? medicationName;
  const PharmacyFinderScreen({super.key, this.medicationName});

  @override
  State<PharmacyFinderScreen> createState() => _PharmacyFinderScreenState();
}

class _PharmacyFinderScreenState extends State<PharmacyFinderScreen> {
  final PharmacyService _pharmacyService = PharmacyService();
  bool _isLoading = true;
  List<Pharmacy> _pharmacies = [];

  @override
  void initState() {
    super.initState();
    _loadPharmacies();
  }

  Future<void> _loadPharmacies() async {
    setState(() => _isLoading = true);
    final results = await _pharmacyService.getNearbyPharmacies(widget.medicationName ?? 'Generic');
    setState(() {
      _pharmacies = results;
      _isLoading = false;
    });
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
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.blue.withValues(alpha: 0.1),
      child: Stack(
        children: [
          // Mock Map Background
          Center(
            child: Icon(Icons.map_outlined, size: 60, color: Colors.blue.withValues(alpha: 0.3)),
          ),
          ..._pharmacies.take(3).map((p) {
             final index = _pharmacies.indexOf(p);
             return Positioned(
               left: 50 + (index * 80.0),
               top: 40 + (index * 30.0),
               child: Column(
                 children: [
                   Container(
                     padding: const EdgeInsets.all(4),
                     decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)]),
                     child: const Icon(Icons.local_pharmacy, color: Colors.red, size: 20),
                   ),
                   const SizedBox(height: 2),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                     decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(4)),
                     child: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 8)),
                   ),
                 ],
               ),
             );
          }),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              onPressed: () {},
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
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
                        onPressed: () {},
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
                        onPressed: () {},
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
