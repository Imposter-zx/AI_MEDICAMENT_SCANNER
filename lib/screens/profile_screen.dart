import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/models.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _allergyController = TextEditingController();
  final _conditionController = TextEditingController();

  List<String> _allergies = [];
  List<String> _conditions = [];

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _ageController.text = profile.age?.toString() ?? '';
      _allergies = List.from(profile.allergies);
      _conditions = List.from(profile.medicalConditions);
    }
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text.trim());
        _allergyController.clear();
      });
    }
  }

  void _addCondition() {
    if (_conditionController.text.isNotEmpty) {
      setState(() {
        _conditions.add(_conditionController.text.trim());
        _conditionController.clear();
      });
    }
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = UserProfile(
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text),
        allergies: _allergies,
        medicalConditions: _conditions,
      );
      context.read<UserProfileProvider>().saveProfile(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Health Profile'),
        actions: [
          IconButton(
            onPressed: _saveProfile,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Age',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Allergies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Add allergies to get warnings during scans.', 
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergyController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Penicillin, Peanuts',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addAllergy(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addAllergy,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _allergies.map((a) => Chip(
                  label: Text(a),
                  onDeleted: () => setState(() => _allergies.remove(a)),
                )).toList(),
              ),
              
              const SizedBox(height: 24),
              
              const Text(
                'Medical Conditions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _conditionController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Asthma, Diabetes',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _addCondition(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addCondition,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _conditions.map((c) => Chip(
                  label: Text(c),
                  onDeleted: () => setState(() => _conditions.remove(c)),
                )).toList(),
              ),
              
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
