import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/add_medical_history_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../utils/app_snackbar.dart';

class AddMedicalHistoryDialog extends StatefulWidget {
  const AddMedicalHistoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    Get.put(AddMedicalHistoryController());
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddMedicalHistoryDialog(),
    ).then((_) {
      if (Get.isRegistered<AddMedicalHistoryController>()) {
        Get.delete<AddMedicalHistoryController>();
      }
    });
  }

  @override
  State<AddMedicalHistoryDialog> createState() =>
      _AddMedicalHistoryDialogState();
}

class _AddMedicalHistoryDialogState extends State<AddMedicalHistoryDialog> {
  late final AddMedicalHistoryController _controller;
  late final HomeController _homeController;

  int _currentStep = 0; // 0 = details, 1 = medication (Diseases only)

  // Step 1 fields
  String _selectedCategory = 'Diseases';
  DateTime? _consultationDate;
  final TextEditingController _diseaseSearchController =
      TextEditingController();
  static const String _notePrefix = 'Copied from admission paper, ';
  final TextEditingController _noteController = TextEditingController();

  // Selected disease (for Diseases category)
  Map<String, dynamic>? _selectedDisease;

  // Multi-item list (for Surgeries/Vaccinations/Medication)
  final List<Map<String, dynamic>> _categoryItems = [];

  // Step 2 fields (Diseases -> medication)
  final TextEditingController _drugNameController = TextEditingController();
  String _selectedDrugIngredients = '';
  final TextEditingController _numberOfDaysController = TextEditingController();
  final TextEditingController _everyHoursController = TextEditingController();
  final TextEditingController _dozeController = TextEditingController();
  final TextEditingController _drugNotesController = TextEditingController();

  String? _relationToFood;
  String? _administrationForm;
  String? _dozeType;
  DateTime? _drugStartDate;
  final List<String> _selectedTags = [];
  final List<Map<String, dynamic>> _addedDrugs = [];

  // Overlay state
  final LayerLink _diseaseLayerLink = LayerLink();
  final LayerLink _drugLayerLink = LayerLink();
  OverlayEntry? _diseaseOverlay;
  OverlayEntry? _drugOverlay;
  bool _isDiseaseOverlayVisible = false;
  bool _isDrugOverlayVisible = false;

  // Item addition search state
  final TextEditingController _itemSearchController = TextEditingController();
  final LayerLink _itemLayerLink = LayerLink();
  OverlayEntry? _itemOverlay;
  bool _isItemOverlayVisible = false;
  bool _isAddingItem = false;

  static const List<String> _categories = [
    'Diseases',
    'Surgeries',
    'Vaccinations',
    'Medication',
  ];

  static const List<String> _relationToFoodOptions = [
    'After dinner',
    'Before dinner',
    'After lunch',
    'Before lunch',
    'After breakfast',
    'Before breakfast',
    'With food',
    'Without food',
  ];

  static const List<String> _administrationFormOptions = [
    'Sublingual',
    'Oral',
    'Intramuscular injection',
    'Subcutaneous',
    'Eye drops',
    'Intravenous injection',
    'Inhalation',
    'For External Treatment',
    'Nasal administration',
    'Otic administration',
    'Vaginal',
    'Anal',
  ];

  static const List<String> _dozeTypeOptions = [
    'Spoon',
    'Tablet',
    'Capsule',
    'Drop',
    'Puff',
    'Injection',
    'Sachet',
    'Suppository',
    'Patch',
  ];

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AddMedicalHistoryController>();
    _homeController = Get.find<HomeController>();
    _noteController.text = _notePrefix;
    _noteController.addListener(_guardNotePrefix);
  }

  void _guardNotePrefix() {
    final text = _noteController.text;
    if (!text.startsWith(_notePrefix)) {
      _noteController.removeListener(_guardNotePrefix);
      _noteController.text = _notePrefix;
      _noteController.selection = TextSelection.collapsed(
        offset: _notePrefix.length,
      );
      _noteController.addListener(_guardNotePrefix);
    }
  }

  @override
  void dispose() {
    _removeAllOverlays();
    _noteController.removeListener(_guardNotePrefix);
    _diseaseSearchController.dispose();
    _noteController.dispose();
    _drugNameController.dispose();
    _numberOfDaysController.dispose();
    _everyHoursController.dispose();
    _dozeController.dispose();
    _drugNotesController.dispose();
    _itemSearchController.dispose();
    super.dispose();
  }

  void _removeAllOverlays() {
    _diseaseOverlay?.remove();
    _diseaseOverlay = null;
    _isDiseaseOverlayVisible = false;
    _drugOverlay?.remove();
    _drugOverlay = null;
    _isDrugOverlayVisible = false;
    _itemOverlay?.remove();
    _itemOverlay = null;
    _isItemOverlayVisible = false;
  }

  // ─── Validation ───

  bool get _isStep1ValidForDiseases =>
      _selectedDisease != null && _consultationDate != null;

  bool get _isStep1ValidForOtherCategories => _categoryItems.isNotEmpty;

  bool get _isStep2Valid => true; // Diseases step 2: drugs are optional

  // ─── Category change ───

  void _onCategoryChanged(String? value) {
    if (value == null) return;
    _removeAllOverlays();
    setState(() {
      _selectedCategory = value;
      _selectedDisease = null;
      _diseaseSearchController.clear();
      _categoryItems.clear();
      _isAddingItem = false;
      _itemSearchController.clear();
      _controller.clearLookupResults();
      _controller.clearDrugResults();
    });
  }

  // ─── Disease search overlay ───

  void _showDiseaseOverlay() {
    if (_isDiseaseOverlayVisible) return;
    _diseaseOverlay = _buildOverlayEntry(
      layerLink: _diseaseLayerLink,
      builder: () => Obx(() {
        final results = _controller.lookupResults;
        final isLoading = _controller.isSearchingLookup.value;
        return _buildOverlayContent(
          results: results,
          isLoading: isLoading,
          displayKey: 'name',
          onSelect: (item) {
            setState(() {
              _selectedDisease = item;
              _diseaseSearchController.text = item['name'] ?? '';
            });
            _controller.clearLookupResults();
            _hideDiseaseOverlay();
          },
        );
      }),
    );
    Overlay.of(context).insert(_diseaseOverlay!);
    _isDiseaseOverlayVisible = true;
  }

  void _hideDiseaseOverlay() {
    _diseaseOverlay?.remove();
    _diseaseOverlay = null;
    _isDiseaseOverlayVisible = false;
  }

  // ─── Drug search overlay ───

  void _showDrugOverlay() {
    if (_isDrugOverlayVisible) return;
    _drugOverlay = _buildOverlayEntry(
      layerLink: _drugLayerLink,
      builder: () => Obx(() {
        final results = _controller.drugResults;
        final isLoading = _controller.isSearchingDrugs.value;
        return _buildOverlayContent(
          results: results,
          isLoading: isLoading,
          displayKey: 'drug_name',
          onSelect: (item) {
            setState(() {
              _drugNameController.text = item['drug_name'] ?? '';
              _selectedDrugIngredients = item['ingredients'] ?? '';
            });
            _controller.clearDrugResults();
            _hideDrugOverlay();
          },
        );
      }),
    );
    Overlay.of(context).insert(_drugOverlay!);
    _isDrugOverlayVisible = true;
  }

  void _hideDrugOverlay() {
    _drugOverlay?.remove();
    _drugOverlay = null;
    _isDrugOverlayVisible = false;
  }

  // ─── Item search overlay (for Surgeries/Vaccinations/Medication) ───

  void _showItemOverlay() {
    if (_isItemOverlayVisible) return;
    _itemOverlay = _buildOverlayEntry(
      layerLink: _itemLayerLink,
      builder: () {
        final isMedication = _selectedCategory == 'Medication';
        return Obx(() {
          final results = isMedication
              ? _controller.drugResults
              : _controller.lookupResults;
          final isLoading = isMedication
              ? _controller.isSearchingDrugs.value
              : _controller.isSearchingLookup.value;
          return _buildOverlayContent(
            results: results,
            isLoading: isLoading,
            displayKey: isMedication ? 'drug_name' : 'name',
            onSelect: (item) async {
              _hideItemOverlay();
              _itemSearchController.clear();
              if (isMedication) {
                _controller.clearDrugResults();
              } else {
                _controller.clearLookupResults();
              }
              // Pick a date for this item
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: Theme.of(ctx).copyWith(
                    colorScheme:
                        const ColorScheme.light(primary: Color(0xFF1339FF)),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) {
                setState(() {
                  _categoryItems.add({
                    'name': isMedication
                        ? (item['drug_name'] ?? '')
                        : (item['name'] ?? ''),
                    'ingredients': item['ingredients'],
                    'date': picked.toIso8601String(),
                    'displayDate': DateFormat('dd/MM/yyyy').format(picked),
                  });
                  _isAddingItem = false;
                });
              }
            },
          );
        });
      },
    );
    Overlay.of(context).insert(_itemOverlay!);
    _isItemOverlayVisible = true;
  }

  void _hideItemOverlay() {
    _itemOverlay?.remove();
    _itemOverlay = null;
    _isItemOverlayVisible = false;
  }

  // ─── Shared overlay builder ───

  OverlayEntry _buildOverlayEntry({
    required LayerLink layerLink,
    required Widget Function() builder,
  }) {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 44),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: builder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlayContent({
    required List<Map<String, dynamic>> results,
    required bool isLoading,
    required String displayKey,
    required ValueChanged<Map<String, dynamic>> onSelect,
  }) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (results.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No results found',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: results.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
      itemBuilder: (_, i) {
        final item = results[i];
        return InkWell(
          onTap: () => onSelect(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              item[displayKey]?.toString() ?? '',
              style: const TextStyle(fontSize: 13, color: Color(0xFF2D2E2E)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }

  // ─── Submit ───

  Future<void> _submit() async {
    final patientId = _homeController.currentStudent.value?.id;
    if (patientId == null) {
      appSnackbar('Error', 'No student selected',
          backgroundColor: const Color(0xFFFFCDD2),
          colorText: const Color(0xFFC62828));
      return;
    }

    final note = _noteController.text.trim();

    if (_selectedCategory == 'Diseases') {
      final medications = _addedDrugs.isNotEmpty
          ? _addedDrugs
              .map((d) => <String, dynamic>{
                    'name': d['drug_name'] ?? '',
                    'ingredients': d['active_ingredient'] ?? '',
                  })
              .toList()
          : null;

      final success = await _controller.submitMedicalHistory(
        patientId: patientId,
        category: 'Diseases',
        date: _consultationDate,
        disease: _selectedDisease != null
            ? {'name': _selectedDisease!['name'] ?? ''}
            : null,
        medications: medications,
        note: note,
      );

      if (success) {
        if (mounted) Navigator.of(context).pop();
        appSnackbar('Success', 'Medical history added successfully',
            backgroundColor: const Color(0xFFC8E6C9),
            colorText: const Color(0xFF2E7D32));
        _homeController.refreshPatientRecords();
      } else {
        appSnackbar('Error', 'Failed to add medical history',
            backgroundColor: const Color(0xFFFFCDD2),
            colorText: const Color(0xFFC62828));
      }
    } else {
      // Surgeries / Vaccinations / Medication: submit each item separately
      int successCount = 0;
      int failCount = 0;

      for (final item in _categoryItems) {
        final itemData = <String, dynamic>{
          'name': item['name'] ?? '',
          if (item['ingredients'] != null) 'ingredients': item['ingredients'],
          'date': item['date'],
        };

        final success = await _controller.submitMedicalHistory(
          patientId: patientId,
          category: _selectedCategory,
          items: [itemData],
          note: note,
        );

        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (failCount == 0) {
        if (mounted) Navigator.of(context).pop();
        appSnackbar('Success',
            '$successCount ${_selectedCategory.toLowerCase()} added successfully',
            backgroundColor: const Color(0xFFC8E6C9),
            colorText: const Color(0xFF2E7D32));
        _homeController.refreshPatientRecords();
      } else {
        appSnackbar(
            'Error', '$failCount of ${_categoryItems.length} failed to add',
            backgroundColor: const Color(0xFFFFCDD2),
            colorText: const Color(0xFFC62828));
      }
    }
  }

  // ─── BUILD ───

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: _currentStep == 0 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 1
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStep1() {
    final isDiseases = _selectedCategory == 'Diseases';

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const Text(
            'Add new medical history',
            style: TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the medical history details',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
          ),
          const SizedBox(height: 24),
          const Text(
            'Medical history details',
            style: TextStyle(
              color: Color(0xFF595A5B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Category dropdown
          _buildDropdownField(
            'Category',
            true,
            _selectedCategory,
            _categories,
            _onCategoryChanged,
          ),
          const SizedBox(height: 16),

          if (isDiseases) ...[
            // Disease search field
            _buildSearchField(
              label: 'Disease',
              required: true,
              controller: _diseaseSearchController,
              layerLink: _diseaseLayerLink,
              onChanged: (query) {
                _selectedDisease = null;
                _controller.onLookupSearchChanged(query, 'Diseases');
                if (query.isNotEmpty) {
                  _showDiseaseOverlay();
                } else {
                  _hideDiseaseOverlay();
                }
              },
            ),
            const SizedBox(height: 16),

            // Date picker
            _buildDateField(
              'Consultation date',
              true,
              _consultationDate,
              (d) => setState(() => _consultationDate = d),
            ),
            const SizedBox(height: 16),

            // Notes
            _buildTextAreaField('Additional details', false, _noteController,
                'Additional details'),
          ] else ...[
            // Multi-item list for Surgeries/Vaccinations/Medication
            _buildCategoryItemsList(),
            const SizedBox(height: 16),

            // Notes
            _buildTextAreaField(
                'Note', false, _noteController, 'Add a note (optional)'),
          ],

          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFFE9E9E9)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Cancel',
                      style: TextStyle(
                          color: Color(0xFF595A5B),
                          fontSize: 16,
                          fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: isDiseases
                    ? _buildNextButton()
                    : _buildSubmitButton(
                        enabled: _isStep1ValidForOtherCategories),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    final enabled = _isStep1ValidForDiseases;
    return ElevatedButton(
      onPressed: enabled
          ? () {
              _removeAllOverlays();
              setState(() => _currentStep = 1);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1339FF),
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFF1339FF).withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white70,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: const Text('Next: add medication',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSubmitButton({required bool enabled}) {
    return Obx(() {
      final isSubmitting = _controller.isSubmitting.value;
      return ElevatedButton(
        onPressed: (enabled && !isSubmitting) ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1339FF),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              const Color(0xFF1339FF).withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              )
            : const Text('Add record',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      );
    });
  }

  // ─── Category items list (Surgeries/Vaccinations/Medication) ───

  Widget _buildCategoryItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_categoryItems.isNotEmpty)
          ..._categoryItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8E8E8)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF2D2E2E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item['ingredients'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['ingredients'],
                            style: const TextStyle(
                                color: Color(0xFF9E9E9E), fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (item['displayDate'] != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            item['displayDate'],
                            style: const TextStyle(
                                color: Color(0xFFA6A9AC), fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _categoryItems.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFEBEE),
                        shape: BoxShape.circle,
                      ),
                      child:
                          const Icon(Icons.close, color: Colors.red, size: 16),
                    ),
                  ),
                ],
              ),
            );
          }),

        // Add item row (with inline search)
        if (_isAddingItem) ...[
          _buildSearchField(
            label: 'Search $_selectedCategory',
            required: false,
            controller: _itemSearchController,
            layerLink: _itemLayerLink,
            onChanged: (query) {
              if (_selectedCategory == 'Medication') {
                _controller.onDrugSearchChanged(query);
              } else {
                _controller.onLookupSearchChanged(query, _selectedCategory);
              }
              if (query.isNotEmpty) {
                _showItemOverlay();
              } else {
                _hideItemOverlay();
              }
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                _hideItemOverlay();
                _itemSearchController.clear();
                _controller.clearLookupResults();
                _controller.clearDrugResults();
                setState(() => _isAddingItem = false);
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            ),
          ),
        ] else
          GestureDetector(
            onTap: () => setState(() => _isAddingItem = true),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE0E0E0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Color(0xFF1339FF), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'Add $_selectedCategory',
                    style: const TextStyle(
                      color: Color(0xFF1339FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEP 2: Medication (Diseases category only)
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const Text(
              'Add medication',
              style: TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Disease: ${_selectedDisease?['name'] ?? ''}',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add prescriptions and plan details here',
              style: TextStyle(color: Color(0xFF595A5B), fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Drug search field
            CompositedTransformTarget(
              link: _drugLayerLink,
              child: _buildTextField(
                'Drug name',
                false,
                _drugNameController,
                prefixIcon: Icons.search,
                onChanged: (query) {
                  _controller.onDrugSearchChanged(query);
                  if (query.isNotEmpty) {
                    _showDrugOverlay();
                  } else {
                    _hideDrugOverlay();
                  }
                },
              ),
            ),
            const SizedBox(height: 16),

            // Dose
            Row(
              children: [
                Expanded(
                  child: _buildNumberField('Dose', false, _dozeController),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    'Dose type',
                    false,
                    _dozeType,
                    _dozeTypeOptions,
                    (v) => setState(() => _dozeType = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Frequency
            const Text('Frequency',
                style: TextStyle(
                    color: Color(0xFF2D2E2E),
                    fontSize: 16,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    'Relation to food',
                    false,
                    _relationToFood,
                    _relationToFoodOptions,
                    (v) {
                      setState(() {
                        _relationToFood = v;
                        if (v != null && !_selectedTags.contains(v)) {
                          _selectedTags.add(v);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdownField(
                    'Administration',
                    false,
                    _administrationForm,
                    _administrationFormOptions,
                    (v) => setState(() => _administrationForm = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tags
            if (_selectedTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.end,
                  children: _selectedTags
                      .map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEDF1F5),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(tag,
                                    style: const TextStyle(
                                        color: Color(0xFF2D2E2E),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTags.remove(tag)),
                                  child: const Icon(Icons.close,
                                      size: 16, color: Color(0xFFED1F4F)),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),

            // Date, days, hours
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildDateField(
                    'Starting date',
                    false,
                    _drugStartDate,
                    (d) => setState(() => _drugStartDate = d),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                      'Number of days', false, _numberOfDaysController,
                      prefixIcon: Icons.calendar_today),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                      'Every (hours)', false, _everyHoursController,
                      prefixIcon: Icons.access_time),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Add drug button
            OutlinedButton(
              onPressed: _addDrug,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFFA6A9AC)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Color(0xFF747677)),
                  SizedBox(width: 8),
                  Text('Add Drug',
                      style: TextStyle(
                          color: Color(0xFF747677),
                          fontSize: 14,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Drug cards
            if (_addedDrugs.isNotEmpty)
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    List.generate(_addedDrugs.length, (i) => _buildDrugCard(i)),
              ),

            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _removeAllOverlays();
                      setState(() => _currentStep = 0);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE9E9E9)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Back',
                        style: TextStyle(
                            color: Color(0xFF595A5B),
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSubmitButton(enabled: _isStep2Valid),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Drug helpers ───

  void _addDrug() {
    if (_drugNameController.text.isEmpty) return;

    final days = int.tryParse(_numberOfDaysController.text) ?? 0;
    final endDate = (_drugStartDate != null && days > 0)
        ? _drugStartDate!.add(Duration(days: days))
        : null;

    _addedDrugs.add({
      'drug_name': _drugNameController.text,
      'active_ingredient': _selectedDrugIngredients,
      if (_dozeController.text.isNotEmpty) 'dose': _dozeController.text,
      if (_dozeType != null) 'dose_type': _dozeType,
      if (_selectedTags.isNotEmpty) 'relation_to_food': _selectedTags.toList(),
      if (_administrationForm != null)
        'administration_form': _administrationForm,
      if (_everyHoursController.text.isNotEmpty)
        'every_hours': _everyHoursController.text,
      if (_numberOfDaysController.text.isNotEmpty)
        'days': _numberOfDaysController.text,
      if (_drugStartDate != null)
        'start_date': DateFormat('yyyy-MM-dd').format(_drugStartDate!),
      if (endDate != null) 'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      if (_drugNotesController.text.isNotEmpty)
        'notes': _drugNotesController.text,
    });

    _drugNameController.clear();
    _dozeController.clear();
    _drugNotesController.clear();
    _numberOfDaysController.clear();
    _everyHoursController.clear();
    setState(() {
      _relationToFood = null;
      _administrationForm = null;
      _dozeType = null;
      _drugStartDate = null;
      _selectedDrugIngredients = '';
      _selectedTags.clear();
    });
  }

  Widget _buildDrugCard(int index) {
    final drug = _addedDrugs[index];
    final name = drug['drug_name'] as String? ?? '';
    final ingredient = drug['active_ingredient'] as String? ?? '';
    final form = drug['administration_form'] as String? ?? '';
    final dose = drug['dose']?.toString() ?? '';
    final foodRelation = drug['relation_to_food'];
    final timing = foodRelation is List
        ? foodRelation.join(', ')
        : foodRelation?.toString() ?? '';
    final days = drug['days']?.toString() ?? '';
    final hours = drug['every_hours']?.toString() ?? '';
    final startDate = drug['start_date']?.toString() ?? '';
    final endDate = drug['end_date']?.toString() ?? '';

    return Container(
      width: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              GestureDetector(
                onTap: () => setState(() => _addedDrugs.removeAt(index)),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFED1F4F),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              if (ingredient.isNotEmpty) _buildPillTag(ingredient),
              if (form.isNotEmpty) _buildPillTag(form),
            ],
          ),
          if (dose.isNotEmpty || timing.isNotEmpty || days.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (dose.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('x$dose',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                      if (timing.isNotEmpty)
                        Text(timing,
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF747677))),
                    ],
                  ),
                if (days.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$days days',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                      if (hours.isNotEmpty)
                        Text('Every $hours hours',
                            style: const TextStyle(
                                fontSize: 10, color: Color(0xFF747677))),
                    ],
                  ),
              ],
            ),
          ],
          if (startDate.isNotEmpty || endDate.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF1F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (startDate.isNotEmpty)
                    _buildDateInfo('Starting date', _formatDateStr(startDate)),
                  if (endDate.isNotEmpty)
                    _buildDateInfo('End date', _formatDateStr(endDate)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPillTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F5),
        borderRadius: BorderRadius.circular(64),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Color(0xFF595A5B),
              fontSize: 11,
              fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis),
    );
  }

  Widget _buildDateInfo(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Color(0xFF747677), fontSize: 10)),
        Text(date,
            style: const TextStyle(
                color: Color(0xFF1339FF),
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }

  String _formatDateStr(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // FIELD BUILDERS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildLabel(String label, bool required) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF595A5B),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        if (required)
          const Text('*',
              style: TextStyle(color: Color(0xFFED1F4F), fontSize: 14)),
      ],
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      color: const Color(0xFFFBFCFD),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: const Color(0xFFE9E9E9)),
    );
  }

  Widget _buildDropdownField(String label, bool required, String? value,
      List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: _fieldDecoration(),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label',
                  style:
                      const TextStyle(color: Color(0xFFA6A9AC), fontSize: 14)),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF1339FF)),
              onChanged: onChanged,
              items: options
                  .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o,
                          style: const TextStyle(
                              color: Color(0xFF2D2E2E), fontSize: 14))))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextAreaField(String label, bool required,
      TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 120,
          decoration: _fieldDecoration(),
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(color: Color(0xFF2D2E2E), fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hint,
              contentPadding: const EdgeInsets.all(14),
              hintStyle:
                  const TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField({
    required String label,
    required bool required,
    required TextEditingController controller,
    required LayerLink layerLink,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        CompositedTransformTarget(
          link: layerLink,
          child: Container(
            width: double.infinity,
            height: 46,
            decoration: _fieldDecoration(),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: Color(0xFF2D2E2E), fontSize: 14),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search...',
                hintStyle: TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
                prefixIcon:
                    Icon(Icons.search, color: Color(0xFFA6A9AC), size: 20),
                prefixIconConstraints: BoxConstraints(minWidth: 42),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, bool required, DateTime? date,
      ValueChanged<DateTime> onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme:
                      const ColorScheme.light(primary: Color(0xFF1339FF)),
                ),
                child: child!,
              ),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: _fieldDecoration(),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 20, color: Color(0xFFA6A9AC)),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Select date',
                  style: TextStyle(
                      color: date != null
                          ? const Color(0xFF2D2E2E)
                          : const Color(0xFFA6A9AC),
                      fontSize: 14),
                ),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
      String label, bool required, TextEditingController controller,
      {IconData? prefixIcon, ValueChanged<String>? onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 46,
          decoration: _fieldDecoration(),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(color: Color(0xFF2D2E2E), fontSize: 14),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search',
              hintStyle:
                  const TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFFA6A9AC), size: 20)
                  : null,
              prefixIconConstraints: const BoxConstraints(minWidth: 42),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
      String label, bool required, TextEditingController controller,
      {IconData? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        _buildSmallNumberField(controller, prefixIcon: prefixIcon),
      ],
    );
  }

  Widget _buildSmallNumberField(TextEditingController controller,
      {IconData? prefixIcon}) {
    return Container(
      width: double.infinity,
      height: 46,
      decoration: _fieldDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(color: Color(0xFF2D2E2E), fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          hintStyle: const TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: const Color(0xFFA6A9AC))
              : null,
          prefixIconConstraints: const BoxConstraints(minWidth: 42),
        ),
      ),
    );
  }
}
