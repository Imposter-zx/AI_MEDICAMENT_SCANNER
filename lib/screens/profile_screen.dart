import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../models/models.dart';
import 'package:uuid/uuid.dart';

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
  
  String _selectedRelation = 'Self';
  List<String> _allergies = [];
  List<String> _conditions = [];
  bool _isEditing = false;
  String? _editingId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    
    if (args != null && args['isNew'] == true) {
      _isEditing = false;
    } else {
      final profile = context.read<UserProfileProvider>().activeProfile;
      if (profile != null) {
        _isEditing = true;
        _editingId = profile.id;
        _nameController.text = profile.name;
        _ageController.text = profile.age?.toString() ?? '';
        _selectedRelation = profile.relation;
        _allergies = List.from(profile.allergies);
        _conditions = List.from(profile.medicalConditions);
      }
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
      final provider = context.read<UserProfileProvider>();
      final id = _isEditing && _editingId != null ? _editingId! : const Uuid().v4();
      
      final profile = UserProfile(
        id: id,
        name: _nameController.text.trim(),
        age: int.tryParse(_ageController.text),
        relation: _selectedRelation,
        allergies: _allergies,
        medicalConditions: _conditions,
      );

      if (_isEditing) {
        provider.updateProfile(profile);
      } else {
        provider.addProfile(profile);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Profile updated!' : 'New profile added!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Add Family Profile'),
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
                    value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRelation,
                      decoration: const InputDecoration(
                        labelText: 'Relation',
                        border: OutlineInputBorder(),
                      ),
                      items: ['Self', 'Child', 'Spouse', 'Parent', 'Other']
                          .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedRelation = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Safety: Allergies',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Text('Scanned meds will be checked against these.', 
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildSuggestions(
                ['Penicillin', 'Sulfa', 'Latex', 'Nuts', 'Aspirin'],
                (val) => setState(() => _allergies.contains(val) ? null : _allergies.add(val)),
                _allergies,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergyController,
                      decoration: const InputDecoration(
                        hintText: 'Add allergy...',
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
                'Safety: Medical Conditions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildSuggestions(
                ['Asthma', 'Diabetes', 'Hypertension', 'Stomach Ulcer', 'Heart Disease'],
                (val) => setState(() => _conditions.contains(val) ? null : _conditions.add(val)),
                _conditions,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _conditionController,
                      decoration: const InputDecoration(
                        hintText: 'Add condition...',
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
                  icon: Icon(_isEditing ? Icons.save : Icons.person_add),
                  label: Text(_isEditing ? 'Update Profile' : 'Add Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (_isEditing && _selectedRelation != 'Self')
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        context.read<UserProfileProvider>().deleteProfile(_editingId!);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete Profile', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions(List<String> suggestions, Function(String) onSelected, List<String> current) {
    return Wrap(
      spacing: 8,
      children: suggestions.map((s) {
        final isSelected = current.contains(s);
        return FilterChip(
          label: Text(s, style: const TextStyle(fontSize: 12)),
          selected: isSelected,
          onSelected: isSelected ? null : (selected) => onSelected(s),
          selectedColor: Colors.blue.withValues(alpha: 0.2),
          checkmarkColor: Colors.blue,
        );
      }).toList(),
    );
  }
}
