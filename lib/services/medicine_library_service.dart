import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'extended_medications_database.dart';

// ---------- DrugEntry ----------

class DrugEntry {
  final String name;
  final String? genericName;
  final String? manufacturer;
  final String? activeIngredient;
  final List<String> usedFor;
  final String? dosage;
  final List<String> sideEffects;
  final List<String> contraindications;
  final String? description;
  final bool requiresPrescription;
  final String source; // 'local', 'openfda', 'rxnorm'
  final String? rxcui;
  final String? ndc;
  final String? route;
  final String? drugClass;

  const DrugEntry({
    required this.name,
    this.genericName,
    this.manufacturer,
    this.activeIngredient,
    required this.usedFor,
    this.dosage,
    required this.sideEffects,
    required this.contraindications,
    this.description,
    this.requiresPrescription = false,
    required this.source,
    this.rxcui,
    this.ndc,
    this.route,
    this.drugClass,
  });

  factory DrugEntry.fromMedication(Medication m) => DrugEntry(
        name: m.name,
        genericName: m.activeIngredient,
        manufacturer: m.manufacturer,
        activeIngredient: m.activeIngredient,
        usedFor: m.usedFor,
        dosage: m.dosage,
        sideEffects: m.sideEffects,
        contraindications: m.contraindications,
        description: m.simpleExplanation,
        requiresPrescription: m.requiresPrescription,
        source: 'local',
      );

  factory DrugEntry.fromOpenFDA(Map<String, dynamic> result) {
    final openfda = result['openfda'] as Map<String, dynamic>? ?? {};

    String _first(String key) =>
        (openfda[key] as List?)?.firstOrNull?.toString() ?? '';

    final brandName = _first('brand_name').isNotEmpty
        ? _first('brand_name')
        : _first('generic_name').isNotEmpty
            ? _first('generic_name')
            : 'Unknown Drug';

    final List<String> usedFor = [];
    final rawInd = result['indications_and_usage'];
    if (rawInd is List && rawInd.isNotEmpty) {
      final text = rawInd.first.toString();
      usedFor.add(text.length > 200 ? '${text.substring(0, 200)}…' : text);
    }

    String? _listFirst(dynamic v) =>
        v is List && v.isNotEmpty ? v.first.toString() : null;

    final List<String> sideEffects = [];
    if (result['adverse_reactions'] is List) {
      for (final e in (result['adverse_reactions'] as List)) {
        sideEffects.add(e.toString());
      }
    }

    final List<String> contra = [];
    if (result['contraindications'] is List) {
      for (final e in (result['contraindications'] as List)) {
        contra.add(e.toString());
      }
    }

    final description = _listFirst(result['description']) ??
        _listFirst(result['purpose']);

    return DrugEntry(
      name: brandName,
      genericName: _first('generic_name').isNotEmpty ? _first('generic_name') : null,
      manufacturer: _first('manufacturer_name').isNotEmpty ? _first('manufacturer_name') : null,
      activeIngredient: _first('generic_name').isNotEmpty ? _first('generic_name') : null,
      usedFor: usedFor.isNotEmpty ? usedFor : ['Refer to full drug label.'],
      dosage: _listFirst(result['dosage_and_administration']),
      sideEffects: sideEffects.isNotEmpty ? sideEffects : ['Consult prescriber.'],
      contraindications: contra.isNotEmpty ? contra : ['Consult prescriber.'],
      description: description,
      requiresPrescription: true,
      source: 'openfda',
      rxcui: (openfda['rxcui'] as List?)?.firstOrNull?.toString(),
      ndc: (openfda['product_ndc'] as List?)?.firstOrNull?.toString(),
      route: (openfda['route'] as List?)?.firstOrNull?.toString(),
      drugClass: (openfda['pharm_class_epc'] as List?)?.firstOrNull?.toString() ??
          (openfda['pharm_class_cs'] as List?)?.firstOrNull?.toString(),
    );
  }

  factory DrugEntry.fromRxNorm(Map<String, dynamic> concept) {
    return DrugEntry(
      name: concept['name']?.toString() ?? 'Unknown Drug',
      usedFor: ['Drug information from RxNorm database.'],
      sideEffects: [],
      contraindications: [],
      requiresPrescription: false,
      source: 'rxnorm',
      rxcui: concept['rxcui']?.toString(),
      drugClass: concept['tty']?.toString() == 'IN' ? 'Generic Ingredient' : concept['tty']?.toString(),
    );
  }

  Medication toMedication() => Medication(
        name: name,
        activeIngredient: activeIngredient ?? genericName,
        manufacturer: manufacturer,
        usedFor: usedFor,
        whenToUse: [],
        contraindications: contraindications,
        dosage: dosage,
        sideEffects: sideEffects,
        simpleExplanation: description ?? 'No description available.',
        requiresPrescription: requiresPrescription,
      );
}

// ---------- DrugInteraction ----------

class DrugInteraction {
  final String drug1;
  final String drug2;
  final String description;
  final String severity;

  const DrugInteraction({
    required this.drug1,
    required this.drug2,
    required this.description,
    required this.severity,
  });
}

// ---------- MedicineCategory ----------

class MedicineCategory {
  final String label;
  final String icon;
  final String searchTerm;
  final Color color;
  // Local DB keywords to match usedFor/activeIngredient fields
  final List<String> localKeywords;

  const MedicineCategory({
    required this.label,
    required this.icon,
    required this.searchTerm,
    required this.color,
    this.localKeywords = const [],
  });
}

class MedicineCategories {
  static const all = MedicineCategory(
    label: 'All', icon: '💊', searchTerm: '', color: Color(0xFF2563EB));

  static const pain = MedicineCategory(
    label: 'Pain & Fever',
    icon: '🌡️',
    searchTerm: 'analgesic',
    color: Color(0xFFEF4444),
    localKeywords: ['pain', 'fever', 'headache', 'ache', 'inflammation'],
  );

  static const antibiotics = MedicineCategory(
    label: 'Antibiotics',
    icon: '🦠',
    searchTerm: 'antibiotic',
    color: Color(0xFF0D9488),
    localKeywords: ['infection', 'bacterial', 'antibiotic', 'bacteria', 'antibiotic'],
  );

  static const cardiac = MedicineCategory(
    label: 'Heart & BP',
    icon: '❤️',
    searchTerm: 'antihypertensive',
    color: Color(0xFFDC2626),
    localKeywords: ['blood pressure', 'cholesterol', 'heart', 'hypertension', 'arrhythmia', 'angina', 'cardiac'],
  );

  static const diabetes = MedicineCategory(
    label: 'Diabetes',
    icon: '🩸',
    searchTerm: 'antidiabetic',
    color: Color(0xFFF59E0B),
    localKeywords: ['diabetes', 'blood sugar', 'insulin', 'diabetic'],
  );

  static const mentalHealth = MedicineCategory(
    label: 'Mental Health',
    icon: '🧠',
    searchTerm: 'antidepressant',
    color: Color(0xFF7C3AED),
    localKeywords: ['depression', 'anxiety', 'mental', 'panic', 'ptsd', 'ocd', 'bulimia'],
  );

  static const allergy = MedicineCategory(
    label: 'Allergy',
    icon: '🌸',
    searchTerm: 'antihistamine',
    color: Color(0xFFEC4899),
    localKeywords: ['allerg', 'itch', 'hive', 'rhinitis', 'antihistamine'],
  );

  static const digestive = MedicineCategory(
    label: 'Digestive',
    icon: '🫃',
    searchTerm: 'antacid',
    color: Color(0xFF10B981),
    localKeywords: ['heartburn', 'stomach', 'acid', 'gerd', 'ulcer', 'digest', 'reflux'],
  );

  static const List<MedicineCategory> all_ = [
    all, pain, antibiotics, cardiac, diabetes, mentalHealth, allergy, digestive,
  ];
}

// ---------- MedicineLibraryService ----------

class MedicineLibraryService {
  static const String _baseOpenFDA = 'https://api.fda.gov/drug/label.json';
  static const String _baseRxNorm = 'https://rxnav.nlm.nih.gov/REST';
  static const String _cachePrefix = 'drug_cache_v2_';
  static const Duration _cacheTtl = Duration(hours: 24);

  // ---- All local entries ----
  List<DrugEntry> getAllEntries() =>
      medications.values.map(DrugEntry.fromMedication).toList();

  // ---- Smart search: local + OpenFDA + RxNorm ----
  Future<List<DrugEntry>> search(String query) async {
    final q = query.trim();
    // Return full local DB for short queries
    if (q.length < 2) return getAllEntries();

    final cacheKey = '${_cachePrefix}search_${q.toLowerCase()}';
    final cached = await _loadFromCache(cacheKey);
    if (cached != null) return cached;

    final results = <DrugEntry>[];

    // 1. Local
    final localMatches = medications.values.where((m) {
      final ql = q.toLowerCase();
      return m.name.toLowerCase().contains(ql) ||
          (m.activeIngredient?.toLowerCase().contains(ql) ?? false) ||
          m.usedFor.any((u) => u.toLowerCase().contains(ql));
    }).map(DrugEntry.fromMedication).toList();
    results.addAll(localMatches);

    // 2. OpenFDA (web-safe try/catch)
    try {
      final fdaResults = await _searchOpenFDA(q, limit: 10);
      for (final r in fdaResults) {
        if (!results.any((e) => e.name.toLowerCase() == r.name.toLowerCase())) {
          results.add(r);
        }
      }
    } catch (e) {
      debugPrint('[MedicineLibrary] OpenFDA search error: $e');
    }

    // 3. RxNorm fallback
    if (results.length < 5) {
      try {
        final rxResults = await _searchRxNorm(q);
        for (final r in rxResults) {
          if (!results.any((e) => e.name.toLowerCase() == r.name.toLowerCase())) {
            results.add(r);
          }
        }
      } catch (e) {
        debugPrint('[MedicineLibrary] RxNorm search error: $e');
      }
    }

    if (results.isNotEmpty) await _saveToCache(cacheKey, results);
    return results;
  }

  // ---- Browse by category ----
  Future<List<DrugEntry>> browseCategory(MedicineCategory category) async {
    if (category.searchTerm.isEmpty) return getAllEntries();

    final cacheKey = '${_cachePrefix}cat_${category.label.toLowerCase()}';
    final cached = await _loadFromCache(cacheKey);
    if (cached != null) return cached;

    final results = <DrugEntry>[];

    // Local — use localKeywords for richer matching
    final keywords = category.localKeywords.isNotEmpty
        ? category.localKeywords
        : [category.searchTerm];

    final localMatches = medications.values.where((m) {
      for (final kw in keywords) {
        if (m.usedFor.any((u) => u.toLowerCase().contains(kw)) ||
            (m.activeIngredient?.toLowerCase().contains(kw) ?? false) ||
            m.name.toLowerCase().contains(kw)) {
          return true;
        }
      }
      return false;
    }).map(DrugEntry.fromMedication).toList();
    results.addAll(localMatches);

    // OpenFDA category
    try {
      final fdaResults = await _searchOpenFDACategory(category.searchTerm, limit: 15);
      for (final r in fdaResults) {
        if (!results.any((e) => e.name.toLowerCase() == r.name.toLowerCase())) {
          results.add(r);
        }
      }
    } catch (e) {
      debugPrint('[MedicineLibrary] OpenFDA category error: $e');
    }

    // Always fall back to at least local results
    if (results.isEmpty) {
      results.addAll(getAllEntries());
    }

    if (results.isNotEmpty) await _saveToCache(cacheKey, results);
    return results;
  }

  // ---- Drug Interactions via RxNorm ----
  Future<List<DrugInteraction>> checkInteractions(List<String> rxcuis) async {
    if (rxcuis.length < 2) return [];
    try {
      final param = rxcuis.join('+');
      final uri = Uri.parse('$_baseRxNorm/interaction/list.json?rxcuis=$param&sources=ONCHigh');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final groups = (data['fullInteractionTypeGroup'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        final interactions = <DrugInteraction>[];
        for (final group in groups) {
          for (final type in (group['fullInteractionType'] as List? ?? []).cast<Map<String, dynamic>>()) {
            for (final pair in (type['interactionPair'] as List? ?? []).cast<Map<String, dynamic>>()) {
              final concepts = (pair['interactionConcept'] as List?)?.cast<Map<String, dynamic>>() ?? [];
              if (concepts.length >= 2) {
                interactions.add(DrugInteraction(
                  drug1: concepts[0]['minConceptItem']?['name']?.toString() ?? '',
                  drug2: concepts[1]['minConceptItem']?['name']?.toString() ?? '',
                  description: pair['description']?.toString() ?? 'Possible interaction.',
                  severity: pair['severity']?.toString() ?? 'Unknown',
                ));
              }
            }
          }
        }
        return interactions;
      }
    } catch (e) {
      debugPrint('[MedicineLibrary] Interaction check error: $e');
    }
    return [];
  }

  // ---- OpenFDA helpers ----
  Future<List<DrugEntry>> _searchOpenFDA(String query, {int limit = 10}) async {
    final q = Uri.encodeComponent('(openfda.brand_name:"$query") OR (openfda.generic_name:"$query")');
    return _fetchOpenFDA(Uri.parse('$_baseOpenFDA?search=$q&limit=$limit'));
  }

  Future<List<DrugEntry>> _searchOpenFDACategory(String term, {int limit = 15}) async {
    final q = Uri.encodeComponent('openfda.pharm_class_epc:"$term"');
    return _fetchOpenFDA(Uri.parse('$_baseOpenFDA?search=$q&limit=$limit'));
  }

  Future<List<DrugEntry>> _fetchOpenFDA(Uri uri) async {
    final response = await http.get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final entries = <DrugEntry>[];
    for (final r in results) {
      try {
        entries.add(DrugEntry.fromOpenFDA(r));
      } catch (_) { /* skip malformed entries */ }
    }
    return entries;
  }

  // ---- RxNorm helpers ----
  Future<List<DrugEntry>> _searchRxNorm(String query) async {
    final uri = Uri.parse('$_baseRxNorm/drugs.json?name=${Uri.encodeComponent(query)}');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return [];
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final drugGroup = data['drugGroup'] as Map<String, dynamic>?;
    final conceptGroups = (drugGroup?['conceptGroup'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final entries = <DrugEntry>[];
    for (final group in conceptGroups) {
      for (final concept in (group['conceptProperties'] as List? ?? []).cast<Map<String, dynamic>>()) {
        try { entries.add(DrugEntry.fromRxNorm(concept)); } catch (_) {}
      }
    }
    return entries;
  }

  // ---- Cache ----
  Future<List<DrugEntry>?> _loadFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(key);
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = DateTime.tryParse(map['ts'] as String? ?? '');
      if (ts == null || DateTime.now().difference(ts) > _cacheTtl) return null;
      return (map['data'] as List).cast<Map<String, dynamic>>().map(_fromJson).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache(String key, List<DrugEntry> entries) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode({
        'ts': DateTime.now().toIso8601String(),
        'data': entries.map(_toJson).toList(),
      }));
    } catch (_) {}
  }

  Map<String, dynamic> _toJson(DrugEntry e) => {
    'name': e.name, 'genericName': e.genericName, 'manufacturer': e.manufacturer,
    'activeIngredient': e.activeIngredient, 'usedFor': e.usedFor, 'dosage': e.dosage,
    'sideEffects': e.sideEffects, 'contraindications': e.contraindications,
    'description': e.description, 'requiresPrescription': e.requiresPrescription,
    'source': e.source, 'rxcui': e.rxcui, 'ndc': e.ndc, 'route': e.route,
    'drugClass': e.drugClass,
  };

  DrugEntry _fromJson(Map<String, dynamic> m) => DrugEntry(
    name: m['name'] ?? '', genericName: m['genericName']?.toString(),
    manufacturer: m['manufacturer']?.toString(), activeIngredient: m['activeIngredient']?.toString(),
    usedFor: List<String>.from(m['usedFor'] ?? []), dosage: m['dosage']?.toString(),
    sideEffects: List<String>.from(m['sideEffects'] ?? []),
    contraindications: List<String>.from(m['contraindications'] ?? []),
    description: m['description']?.toString(), requiresPrescription: m['requiresPrescription'] ?? false,
    source: m['source'] ?? 'unknown', rxcui: m['rxcui']?.toString(),
    ndc: m['ndc']?.toString(), route: m['route']?.toString(), drugClass: m['drugClass']?.toString(),
  );

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    for (final k in prefs.getKeys().where((k) => k.startsWith(_cachePrefix)).toList()) {
      await prefs.remove(k);
    }
  }
}
