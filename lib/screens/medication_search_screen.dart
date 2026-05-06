import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/medicine_library_service.dart';

// ---- colour constants ----
const _blue   = Color(0xFF2563EB);
const _teal   = Color(0xFF0D9488);
const _purple = Color(0xFF7C3AED);
const _red    = Color(0xFFEF4444);
const _amber  = Color(0xFFF59E0B);
const _green  = Color(0xFF10B981);

class MedicationSearchScreen extends StatefulWidget {
  const MedicationSearchScreen({super.key});

  @override
  State<MedicationSearchScreen> createState() => _MedicationSearchScreenState();
}

class _MedicationSearchScreenState extends State<MedicationSearchScreen>
    with TickerProviderStateMixin {

  final _service = MedicineLibraryService();
  final _searchCtrl = TextEditingController();
  final _focus = FocusNode();

  List<DrugEntry> _results = [];
  bool _loading = false;
  String _error = '';
  int _selectedCatIndex = 0;
  Timer? _debounce;

  final List<DrugEntry> _selectedForInteraction = [];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  /// Category list — labels are resolved at build time from AppLocalizations
  List<_CatDef> _catDefs(AppLocalizations l10n) => [
    _CatDef(l10n.catAll,        '💊', '', MedicineCategories.all),
    _CatDef(l10n.catPainFever,  '🌡️', 'analgesic',        MedicineCategories.pain),
    _CatDef(l10n.catAntibiotics,'🦠', 'antibiotic',       MedicineCategories.antibiotics),
    _CatDef(l10n.catHeartBP,    '❤️', 'antihypertensive', MedicineCategories.cardiac),
    _CatDef(l10n.catDiabetes,   '🩸', 'antidiabetic',     MedicineCategories.diabetes),
    _CatDef(l10n.catMentalHealth,'🧠','antidepressant',   MedicineCategories.mentalHealth),
    _CatDef(l10n.catAllergy,    '🌸', 'antihistamine',    MedicineCategories.allergy),
    _CatDef(l10n.catDigestive,  '🫃', 'antacid',          MedicineCategories.digestive),
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadCategory(0);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _focus.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ---------- Data loading ----------

  Future<void> _loadCategory(int index) async {
    setState(() {
      _loading = true; _error = ''; _results = []; _selectedCatIndex = index;
    });
    _fadeCtrl.reset();

    try {
      final cat = MedicineCategories.all_[index];
      List<DrugEntry> entries;

      if (cat.searchTerm.isEmpty) {
        entries = _service.getAllEntries();
        _enrichAllAsync(entries);
      } else {
        entries = await _service.browseCategory(cat);
      }

      if (mounted) {
        setState(() { _results = entries; _loading = false; });
        _fadeCtrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Failed to load. Showing local results.';
          _results = _service.getAllEntries();
        });
        _fadeCtrl.forward();
      }
    }
  }

  Future<void> _enrichAllAsync(List<DrugEntry> initial) async {
    try {
      final api = await _service.search('aspirin');
      if (!mounted) return;
      final combined = List<DrugEntry>.from(initial);
      for (final r in api) {
        if (!combined.any((e) => e.name.toLowerCase() == r.name.toLowerCase())) {
          combined.add(r);
        }
      }
      setState(() => _results = combined);
    } catch (_) {}
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) { _loadCategory(_selectedCatIndex); return; }
    _debounce = Timer(const Duration(milliseconds: 450), () => _doSearch(q));
  }

  Future<void> _doSearch(String query) async {
    setState(() { _loading = true; _error = ''; _results = []; });
    _fadeCtrl.reset();
    try {
      final results = await _service.search(query);
      if (mounted) {
        setState(() { _results = results; _loading = false; });
        _fadeCtrl.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Search failed. Check your connection.';
          _results = _service.getAllEntries()
              .where((d) => d.name.toLowerCase().contains(query.toLowerCase())).toList();
        });
        _fadeCtrl.forward();
      }
    }
  }

  // ---------- Build ----------

  @override
  Widget build(BuildContext context) {
    final l10n  = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg    = isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
    final isRTL = l10n.isRTL;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            // Gradient blobs
            Positioned(top: -80, right: -60,
              child: Container(width: 260, height: 260,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [_blue.withOpacity(0.15), Colors.transparent])))),
            Positioned(bottom: 80, left: -80,
              child: Container(width: 200, height: 200,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [_teal.withOpacity(0.10), Colors.transparent])))),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(l10n, isDark),
                  _buildSearchBar(l10n, isDark),
                  _buildCategoryChips(l10n, isDark),
                  const SizedBox(height: 4),
                  Expanded(child: _buildBody(l10n, isDark)),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _selectedForInteraction.isNotEmpty
            ? FloatingActionButton.extended(
                onPressed: _showInteractionChecker,
                backgroundColor: _purple,
                icon: const Icon(Icons.compare_arrows, color: Colors.white),
                label: Text(
                  '${l10n.checkInteraction} (${_selectedForInteraction.length})',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )
            : null,
      ),
    );
  }

  // ---- Header ----
  Widget _buildHeader(AppLocalizations l10n, bool isDark) {
    final txt = isDark ? Colors.white : const Color(0xFF0F172A);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8)],
              ),
              child: Icon(
                l10n.isRTL ? Icons.arrow_back_ios : Icons.arrow_back_ios_new,
                size: 18, color: txt,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.medicineLibrary,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: txt)),
                Text(l10n.medicineLibrarySubtitle,
                    style: TextStyle(fontSize: 12,
                        color: isDark ? Colors.white38 : Colors.black38)),
              ],
            ),
          ),
          if (_selectedForInteraction.isNotEmpty)
            GestureDetector(
              onTap: () => setState(() => _selectedForInteraction.clear()),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                    color: _red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(l10n.clearSelection,
                    style: const TextStyle(color: _red, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  // ---- Search bar ----
  Widget _buildSearchBar(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? const Color(0xFF1E293B) : Colors.white).withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: TextField(
              controller: _searchCtrl,
              focusNode: _focus,
              onChanged: _onSearchChanged,
              textAlign: l10n.isRTL ? TextAlign.right : TextAlign.left,
              textDirection: l10n.isRTL ? TextDirection.rtl : TextDirection.ltr,
              textInputAction: TextInputAction.search,
              onSubmitted: (q) { if (q.trim().length >= 2) _doSearch(q); },
              style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF0F172A), fontSize: 15),
              decoration: InputDecoration(
                hintText: l10n.searchDrugHint,
                hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: _blue, size: 22),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, size: 18,
                            color: isDark ? Colors.white54 : Colors.black45),
                        onPressed: () { _searchCtrl.clear(); _loadCategory(_selectedCatIndex); })
                    : null,
                filled: false,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---- Category chips ----
  Widget _buildCategoryChips(AppLocalizations l10n, bool isDark) {
    final cats = _catDefs(l10n);
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = cats[i];
          final selected = _selectedCatIndex == i;
          final color = cat.category.color;
          return GestureDetector(
            onTap: () { _searchCtrl.clear(); _loadCategory(i); },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(colors: [color, color.withOpacity(0.75)])
                    : null,
                color: selected ? null : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: selected ? color : (isDark ? Colors.white12 : Colors.black12),
                    width: selected ? 0 : 1),
                boxShadow: selected
                    ? [BoxShadow(color: color.withOpacity(0.30), blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(cat.icon, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(cat.label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          color: selected ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- Body ----
  Widget _buildBody(AppLocalizations l10n, bool isDark) {
    if (_loading) return _buildShimmer(isDark);
    if (_error.isNotEmpty && _results.isEmpty) return _buildError(isDark);
    if (_results.isEmpty) return _buildEmpty(l10n, isDark);
    return FadeTransition(
      opacity: _fadeAnim,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
        itemCount: _results.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) return _buildListHeader(l10n, isDark);
          return _buildDrugCard(l10n, _results[i - 1], isDark);
        },
      ),
    );
  }

  Widget _buildListHeader(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Row(
        children: [
          Text('${_results.length} ${l10n.results.toLowerCase()}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontSize: 13)),
          const Spacer(),
          if (_selectedForInteraction.isNotEmpty)
            Text('${_selectedForInteraction.length} ${l10n.checkInteraction.toLowerCase()}',
                style: const TextStyle(fontSize: 12, color: _purple, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ---- Drug Card ----
  Widget _buildDrugCard(AppLocalizations l10n, DrugEntry drug, bool isDark) {
    final isSelected = _selectedForInteraction.contains(drug);
    final srcColor   = _sourceColor(drug.source);
    final catIcon    = _iconFor(drug);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showDrugDetail(l10n, drug, isDark),
        onLongPress: () => _toggleInteraction(l10n, drug),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: isSelected ? _purple.withOpacity(0.55)
                    : (isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05)),
                width: isSelected ? 2 : 1),
            boxShadow: [
              BoxShadow(
                  color: isSelected ? _purple.withOpacity(0.14) : Colors.black.withOpacity(0.05),
                  blurRadius: isSelected ? 14 : 8,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: srcColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: srcColor.withOpacity(0.18)),
                  ),
                  child: Center(child: Text(catIcon, style: const TextStyle(fontSize: 22))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(drug.name,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          _sourceBadge(l10n, drug.source, srcColor),
                        ],
                      ),
                      if ((drug.genericName ?? drug.activeIngredient) != null) ...[
                        const SizedBox(height: 2),
                        Text(drug.genericName ?? drug.activeIngredient ?? '',
                            style: TextStyle(fontSize: 12, color: srcColor, fontWeight: FontWeight.w500),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 5),
                      Text(drug.usedFor.take(2).join(' · '),
                          style: TextStyle(fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black54),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (drug.requiresPrescription) ...[
                            _pill(l10n.prescriptionRequired.length > 10 ? 'Rx' : l10n.prescriptionRequired, _red),
                            const SizedBox(width: 6)],
                          if (drug.route != null) ...[
                            _pill(drug.route!.toUpperCase(), _teal),
                            const SizedBox(width: 6)],
                          if (drug.drugClass != null)
                            Expanded(
                              child: Text(drug.drugClass!,
                                  style: TextStyle(fontSize: 10,
                                      color: isDark ? Colors.white30 : Colors.black38),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          if (isSelected)
                            const Icon(Icons.check_circle, color: _purple, size: 18),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right,
                    color: isDark ? Colors.white30 : Colors.black26, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- Shimmer loading ----
  Widget _buildShimmer(bool isDark) {
    final base = isDark ? const Color(0xFF1E293B) : Colors.white;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 100,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(width: 52, height: 52,
                    decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 14, width: 160,
                          decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(6))),
                      const SizedBox(height: 8),
                      Container(height: 10, width: 100,
                          decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(shape: BoxShape.circle, color: _red.withOpacity(0.1)),
              child: const Icon(Icons.wifi_off_rounded, color: _red, size: 36)),
          const SizedBox(height: 12),
          Text(_error, textAlign: TextAlign.center,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () => _loadCategory(_selectedCatIndex),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💊', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(l10n.noResultsFound,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                  color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 6),
          Text(l10n.tryDifferentSearch,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }

  // ---- Drug Detail ----
  void _showDrugDetail(AppLocalizations l10n, DrugEntry drug, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DrugDetailSheet(
        drug: drug,
        isDark: isDark,
        l10n: l10n,
        onAddToInteraction: () {
          _toggleInteraction(l10n, drug);
          Navigator.pop(context);
        },
      ),
    );
  }

  // ---- Interaction ----
  void _toggleInteraction(AppLocalizations l10n, DrugEntry drug) {
    setState(() {
      if (_selectedForInteraction.contains(drug)) {
        _selectedForInteraction.remove(drug);
      } else if (_selectedForInteraction.length < 5) {
        _selectedForInteraction.add(drug);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.maxDrugsSelection)));
      }
    });
  }

  Future<void> _showInteractionChecker() async {
    final l10n  = AppLocalizations.of(context);
    final rxcuis = _selectedForInteraction
        .where((d) => d.rxcui != null).map((d) => d.rxcui!).toList();

    if (rxcuis.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.maxDrugsSelection)));
      return;
    }

    showDialog(context: context, barrierDismissible: false,
        builder: (_) => _LoadingDialog(message: l10n.searchingDatabases));

    List<DrugInteraction> interactions = [];
    try { interactions = await _service.checkInteractions(rxcuis); } catch (_) {}
    if (mounted) Navigator.pop(context);
    if (mounted) _showInteractionResults(l10n, interactions);
  }

  void _showInteractionResults(AppLocalizations l10n, List<DrugInteraction> interactions) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: l10n.isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            const Icon(Icons.compare_arrows, color: _purple),
            const SizedBox(width: 10),
            Text(l10n.interactionResults),
          ]),
          content: SizedBox(
            width: double.maxFinite,
            child: interactions.isEmpty
                ? Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.check_circle, color: _green, size: 48),
                    const SizedBox(height: 12),
                    Text(l10n.noInteractionsFound, textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(l10n.consultPharmacist,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ])
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: interactions.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final ix = interactions[i];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.warning_amber_rounded, color: _amber),
                        title: Text('${ix.drug1} ↔ ${ix.drug2}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text(ix.description,
                            style: const TextStyle(fontSize: 12)),
                      );
                    }),
          ),
          actions: [TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.done))],
        ),
      ),
    );
  }

  // ---- Helpers ----
  Color _sourceColor(String source) => switch (source) {
        'openfda' => _blue, 'rxnorm' => _teal, _ => _purple,
      };

  String _iconFor(DrugEntry d) {
    final text = '${d.name} ${d.usedFor.join()}'.toLowerCase();
    if (text.contains('pain') || text.contains('fever') || text.contains('ibuprofen') || text.contains('aspirin')) return '🌡️';
    if (text.contains('infect') || text.contains('antibiotic') || text.contains('amoxicillin')) return '🦠';
    if (text.contains('blood pressure') || text.contains('cholesterol') || text.contains('heart')) return '❤️';
    if (text.contains('diabet') || text.contains('insulin') || text.contains('metformin')) return '🩸';
    if (text.contains('depress') || text.contains('anxiety') || text.contains('mental')) return '🧠';
    if (text.contains('allerg') || text.contains('histamine') || text.contains('cetirizine')) return '🌸';
    if (text.contains('stomach') || text.contains('acid') || text.contains('heartburn')) return '🫃';
    return '💊';
  }

  Widget _sourceBadge(AppLocalizations l10n, String src, Color color) {
    final label = switch (src) {
      'openfda' => 'FDA', 'rxnorm' => 'RxNorm', _ => 'Local'
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.25))),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
    );
  }

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700)),
      );
}

// ============================================================
// Helper model for category chip definitions
// ============================================================

class _CatDef {
  final String label;
  final String icon;
  final String searchTerm;
  final MedicineCategory category;
  const _CatDef(this.label, this.icon, this.searchTerm, this.category);
}

// ============================================================
// Drug Detail Bottom Sheet
// ============================================================

class _DrugDetailSheet extends StatelessWidget {
  final DrugEntry drug;
  final bool isDark;
  final AppLocalizations l10n;
  final VoidCallback onAddToInteraction;

  const _DrugDetailSheet({
    required this.drug,
    required this.isDark,
    required this.l10n,
    required this.onAddToInteraction,
  });

  @override
  Widget build(BuildContext context) {
    final bg  = isDark ? const Color(0xFF1E293B) : Colors.white;
    final txt = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? Colors.white60 : Colors.black54;
    final src = _srcColor(drug.source);

    return Directionality(
      textDirection: l10n.isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: DraggableScrollableSheet(
        initialChildSize: 0.70, maxChildSize: 0.95, minChildSize: 0.35,
        expand: false,
        builder: (context, sc) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: Container(
            color: bg,
            child: ListView(
              controller: sc,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
              children: [
                // Handle
                Center(
                  child: Container(width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                ),

                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 56, height: 56,
                        decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [_blue, Color(0xFF3B82F6)]),
                            borderRadius: BorderRadius.circular(16)),
                        child: const Center(child: Icon(Icons.medication, color: Colors.white, size: 28))),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(drug.name,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: txt)),
                          if (drug.genericName != null)
                            Text(drug.genericName!,
                                style: const TextStyle(color: _blue, fontSize: 14, fontWeight: FontWeight.w500)),
                          if (drug.manufacturer != null)
                            Text(drug.manufacturer!, style: TextStyle(fontSize: 12, color: sub)),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Tags
                Wrap(
                  spacing: 8, runSpacing: 6,
                  children: [
                    if (drug.requiresPrescription) _tag(l10n.prescriptionRequired, _red),
                    if (drug.route != null) _tag(drug.route!.toUpperCase(), _teal),
                    if (drug.drugClass != null) _tag(drug.drugClass!, _purple),
                    _tag(_srcLabel(), src),
                    if (drug.rxcui != null) _tag('RxCUI: ${drug.rxcui}', Colors.grey.shade500),
                    if (drug.ndc != null) _tag('NDC: ${drug.ndc}', Colors.grey.shade500),
                  ],
                ),

                const SizedBox(height: 20),

                if (drug.description != null) ...[
                  _secHeader('📋 ${l10n.description}', txt),
                  _infoBox(drug.description!, isDark, sub),
                  const SizedBox(height: 16),
                ],

                _secHeader('✅ ${l10n.usedFor}', txt),
                ...drug.usedFor.map((u) => _bullet(u, isDark, sub)),

                if (drug.dosage != null) ...[
                  const SizedBox(height: 16),
                  _secHeader('💉 ${l10n.dosage}', txt),
                  _infoBox(drug.dosage!, isDark, sub),
                ],

                if (drug.sideEffects.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _secHeader('⚠️ ${l10n.sideEffects}', txt),
                  ...drug.sideEffects.take(5).map((s) => _bullet(s, isDark, sub)),
                ],

                if (drug.contraindications.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _secHeader('🚫 ${l10n.contraindications}', txt),
                  ...drug.contraindications.take(4).map((c) => _bullet(c, isDark, _red)),
                ],

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAddToInteraction,
                        icon: const Icon(Icons.compare_arrows, size: 16),
                        label: Text(l10n.checkInteraction),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _purple,
                          side: const BorderSide(color: _purple),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, size: 16),
                        label: Text(l10n.done),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _blue, foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Text(l10n.educationalOnly,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _srcColor(String s) =>
      s == 'openfda' ? _blue : s == 'rxnorm' ? _teal : _purple;

  String _srcLabel() => switch (drug.source) {
        'openfda' => l10n.sourceOpenFDA,
        'rxnorm'  => l10n.sourceRxNorm,
        _         => l10n.sourceLocal,
      };

  Widget _secHeader(String title, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
      );

  Widget _infoBox(String text, bool isDark, Color sub) {
    final t = text.length > 450 ? '${text.substring(0, 450)}…' : text;
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black.withOpacity(0.06)),
      ),
      child: Text(t, style: TextStyle(fontSize: 13, color: sub, height: 1.5)),
    );
  }

  Widget _bullet(String text, bool isDark, Color color) {
    final t = text.length > 220 ? '${text.substring(0, 220)}…' : text;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.only(top: 5),
              child: Container(width: 6, height: 6,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle))),
          const SizedBox(width: 10),
          Expanded(child: Text(t,
              style: TextStyle(fontSize: 13,
                  color: isDark ? Colors.white70 : Colors.black87, height: 1.4))),
        ],
      ),
    );
  }

  Widget _tag(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.30)),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
      );
}

// ============================================================
// Loading Dialog
// ============================================================

class _LoadingDialog extends StatelessWidget {
  final String message;
  const _LoadingDialog({required this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const CircularProgressIndicator(color: _purple),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
