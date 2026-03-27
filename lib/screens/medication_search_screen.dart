import 'package:flutter/material.dart';
import '../services/EXTENDED_MEDICATIONS_DATABASE.dart';
import '../models/models.dart';

class MedicationSearchScreen extends StatefulWidget {
  const MedicationSearchScreen({super.key});

  @override
  State<MedicationSearchScreen> createState() => _MedicationSearchScreenState();
}

class _MedicationSearchScreenState extends State<MedicationSearchScreen> {
  List<Medication> _filteredMeds = [];

  @override
  void initState() {
    super.initState();
    _filteredMeds = medications.values.toList();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredMeds = medications.values.toList();
      } else {
        _filteredMeds = medications.values.where((med) {
          final nameMatch = med.name.toLowerCase().contains(query.toLowerCase());
          final ingredientMatch = med.activeIngredient?.toLowerCase().contains(query.toLowerCase()) ?? false;
          final useMatch = med.usedFor.any((use) => use.toLowerCase().contains(query.toLowerCase()));
          return nameMatch || ingredientMatch || useMatch;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Database'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search by name, ingredient, or use...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _filteredMeds.isEmpty
          ? const Center(child: Text('No medications found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMeds.length,
              itemBuilder: (context, index) {
                final med = _filteredMeds[index];
                return _buildMedCard(med);
              },
            ),
    );
  }

  Widget _buildMedCard(Medication med) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.medication, color: Colors.blue),
        ),
        title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(med.activeIngredient ?? 'Unknown active ingredient', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: med.usedFor.take(2).map((use) => Chip(
                label: Text(use, style: const TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              )).toList(),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Show details or set reminder
          _showMedDetails(med);
        },
      ),
    );
  }

  void _showMedDetails(Medication med) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              Text(med.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(med.activeIngredient ?? '', style: TextStyle(color: Colors.blue.shade700, fontSize: 16)),
              const Divider(height: 32),
              _buildInfoSection('Used For', med.usedFor.join(', ')),
              _buildInfoSection('When to Use', med.whenToUse.join('\n')),
              _buildInfoSection('Safe Dosage', med.dosage ?? 'Consult your doctor'),
              _buildInfoSection('Common Side Effects', med.sideEffects.join(', ')),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}
