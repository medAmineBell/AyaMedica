import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../controllers/assessment_controller.dart';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

class PlansView extends StatefulWidget {
  const PlansView({super.key});

  @override
  State<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends State<PlansView> {
  late final AssessmentController _controller;

  // Local form controllers
  final TextEditingController _activeIngredientController =
      TextEditingController();
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _numberOfDaysController = TextEditingController();
  final TextEditingController _everyHoursController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Dropdown values
  String? _relationToFood;
  String? _administrationForm;
  DateTime? _selectedDate;
  DateTime? _sickLeaveDate;

  final List<String> _relationToFoodOptions = [
    'After dinner',
    'Before dinner',
    'After lunch',
    'Before lunch',
    'After breakfast',
    'Before breakfast',
    'With food',
    'Without food',
  ];

  final List<String> _administrationFormOptions = [
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

  final List<String> _selectedTags = [];

  // Track which search field is active
  String _activeSearchField = '';

  @override
  void initState() {
    super.initState();
    _controller = Get.find<AssessmentController>();
  }

  @override
  void dispose() {
    _activeIngredientController.dispose();
    _drugNameController.dispose();
    _numberOfDaysController.dispose();
    _everyHoursController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: const Text(
                'Add plans',
                style: TextStyle(
                  color: Color(0xFF2D2E2E),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                  letterSpacing: 0.09,
                ),
              ),
            ),
            const Text(
              'Add prescriptions and plan details here',
              style: TextStyle(
                color: Color(0xFF747677),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _buildInputSection(),
            const SizedBox(height: 32),
            const Text(
              'Frequency',
              style: TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildFrequencySection(),
            const SizedBox(height: 24),
            _buildTagSection(),
            const SizedBox(height: 32),
            _buildDateSection(),
            const SizedBox(height: 32),
            _buildNotesField('Notes', 95, _notesController),
            const SizedBox(height: 16),
            _buildAddDrugButton(),
            const SizedBox(height: 32),
            // Drug cards from controller
            Obx(() => _controller.addedDrugs.isNotEmpty
                ? Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: List.generate(_controller.addedDrugs.length,
                        (index) => _buildDrugCard(index)),
                  )
                : const SizedBox.shrink()),
            const SizedBox(height: 32),
            const Text(
              'Sick leave & notes',
              style: TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildSickLeaveSection(),
            const SizedBox(height: 24),
            _buildNotesField(
                'Notes', 95, _controller.sickLeaveNotesController),
          ],
        ),
      ),
    );
  }

  // --- Drug Search Fields ---

  Widget _buildInputSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildDrugSearchField(
            'Active ingredient',
            false,
            _activeIngredientController,
            'ingredient',
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildDrugSearchField(
            'Drug name',
            false,
            _drugNameController,
            'drugName',
          ),
        ),
      ],
    );
  }

  Widget _buildDrugSearchField(
    String label,
    bool isRequired,
    TextEditingController textController,
    String fieldId,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF595A5B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            if (isRequired)
              const Text('*',
                  style: TextStyle(color: Color(0xFFED1F4F), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              setState(() => _activeSearchField = fieldId);
              _controller.onDrugSearchChanged(textController.text);
            } else {
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  setState(() {
                    if (_activeSearchField == fieldId) {
                      _activeSearchField = '';
                      _controller.drugResults.clear();
                    }
                  });
                }
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9E9E9)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0C101828),
                    blurRadius: 2,
                    offset: Offset(0, 1)),
              ],
            ),
            child: TextField(
              controller: textController,
              onChanged: (value) {
                setState(() => _activeSearchField = fieldId);
                _controller.onDrugSearchChanged(value);
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'search',
                hintStyle:
                    TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Color(0xFFA6A9AC)),
              ),
            ),
          ),
        ),
        // Dropdown results
        if (_activeSearchField == fieldId)
          Obx(() {
            if (_controller.isLoadingDrugs.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))),
              );
            }
            if (_controller.drugResults.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.only(top: 4),
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE9E9E9)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2)),
                ],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: _controller.drugResults.length,
                itemBuilder: (context, index) {
                  final drug = _controller.drugResults[index];
                  final drugName = drug['drug_name']?.toString() ?? '';
                  final ingredients = drug['ingredients']?.toString() ?? '';
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _drugNameController.text = drugName;
                        _activeIngredientController.text = ingredients;
                        _activeSearchField = '';
                        _controller.drugResults.clear();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(drugName,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          if (ingredients.isNotEmpty)
                            Text(ingredients,
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF6B7280)),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
      ],
    );
  }

  // --- Frequency ---

  Widget _buildFrequencySection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField(
              'Relation to food', false, _relationToFood, _relationToFoodOptions,
              (value) {
            setState(() {
              _relationToFood = value;
              if (value != null && !_selectedTags.contains(value)) {
                _selectedTags.add(value);
              }
            });
          }),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildDropdownField('Administration form', false,
              _administrationForm, _administrationFormOptions, (value) {
            setState(() => _administrationForm = value);
          }),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, bool isRequired, String? value,
      List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF595A5B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            if (isRequired)
              const Text('*',
                  style: TextStyle(color: Color(0xFFED1F4F), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9E9E9)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0C101828),
                  blurRadius: 2,
                  offset: Offset(0, 1)),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label',
                  style: const TextStyle(
                      color: Color(0xFFA6A9AC), fontSize: 14)),
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

  Widget _buildTagSection() {
    return Wrap(
      spacing: 16,
      children: _selectedTags.map((tag) => _buildTag(tag)).toList(),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F5),
        borderRadius: BorderRadius.circular(1000),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: const TextStyle(
                  color: Color(0xFF2D2E2E),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _selectedTags.remove(text)),
            child:
                const Icon(Icons.close, size: 16, color: Color(0xFF595A5B)),
          ),
        ],
      ),
    );
  }

  // --- Date Section ---

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: _buildDateField('Starting date', false, _selectedDate,
                (d) => setState(() => _selectedDate = d))),
        const SizedBox(width: 24),
        Expanded(
            child: _buildNumberField(
                'Number of day', false, _numberOfDaysController)),
        const SizedBox(width: 24),
        Expanded(
            child: _buildNumberField(
                'Every (hours)', false, _everyHoursController)),
      ],
    );
  }

  Widget _buildDateField(String label, bool isRequired, DateTime? date,
      ValueChanged<DateTime> onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF595A5B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            if (isRequired)
              const Text('*',
                  style: TextStyle(color: Color(0xFFED1F4F), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onPicked(picked);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9E9E9)),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x0C101828),
                    blurRadius: 2,
                    offset: Offset(0, 1)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 20, color: Color(0xFFA6A9AC)),
                    const SizedBox(width: 8),
                    Text(
                      date != null
                          ? DateFormat('dd/MM/yyyy').format(date)
                          : 'Select date',
                      style: const TextStyle(
                          color: Color(0xFF2D2E2E), fontSize: 14),
                    ),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(
      String label, bool isRequired, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: Color(0xFF595A5B),
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
            if (isRequired)
              const Text('*',
                  style: TextStyle(color: Color(0xFFED1F4F), fontSize: 14)),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9E9E9)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0C101828),
                  blurRadius: 2,
                  offset: Offset(0, 1)),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14),
              hintStyle: TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(
      String hint, double height, TextEditingController controller) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9E9E9)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0C101828),
              blurRadius: 2,
              offset: Offset(0, 1)),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          contentPadding: const EdgeInsets.all(14),
          hintStyle: const TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
        ),
        maxLines: null,
      ),
    );
  }

  // --- Add Drug ---

  Widget _buildAddDrugButton() {
    return OutlinedButton(
      onPressed: _addDrug,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFFA6A9AC)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    );
  }

  void _addDrug() {
    if (_drugNameController.text.isEmpty ||
        _activeIngredientController.text.isEmpty) {
      appSnackbar('Error', 'Please fill in required fields',
          backgroundColor: Colors.red.shade100);
      return;
    }

    final days = int.tryParse(_numberOfDaysController.text) ?? 0;
    final startDate = _selectedDate ?? DateTime.now();
    final endDate = startDate.add(Duration(days: days));

    final drug = <String, dynamic>{
      'drug_name': _drugNameController.text,
      'drug_active_ingredient': _activeIngredientController.text,
      'drug_relation_to_food': _selectedTags.toList(),
      'drug_administration_form': _administrationForm ?? 'Oral',
      'drug_hours': _everyHoursController.text,
      'drug_days': _numberOfDaysController.text,
      'drug_start_date': DateFormat('yyyy-MM-dd').format(startDate),
      'drug_end_date': DateFormat('yyyy-MM-dd').format(endDate),
      'drug_note': _notesController.text,
    };

    _controller.addDrug(drug);

    // Clear form
    _drugNameController.clear();
    _activeIngredientController.clear();
    _notesController.clear();

    appSnackbar('Success', 'Drug added successfully!',
        backgroundColor: Colors.green.shade100);
  }

  Widget _buildDrugCard(int index) {
    final drug = _controller.addedDrugs[index];
    final name = drug['drug_name'] as String? ?? '{Drug name}';
    final ingredient = drug['drug_active_ingredient'] as String? ?? '';
    final form = drug['drug_administration_form'] as String? ?? 'Oral';
    final foodRelation = drug['drug_relation_to_food'];
    final timing =
        foodRelation is List ? foodRelation.join(', ') : foodRelation?.toString() ?? '';
    final days = drug['drug_days']?.toString() ?? '';
    final hours = drug['drug_hours']?.toString() ?? '';
    final startDate = drug['drug_start_date']?.toString() ?? '';
    final endDate = drug['drug_end_date']?.toString() ?? '';

    return Container(
      width: 265,
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
                        color: Color(0xFF2D2E2E),
                        fontSize: 16,
                        fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => _controller.removeDrug(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPillTag(ingredient.isNotEmpty ? ingredient : 'Active ingredient'),
              const SizedBox(width: 8),
              _buildPillTag(form),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('x2',
                      style: TextStyle(
                          color: Color(0xFF595A5B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  Text(timing,
                      style: const TextStyle(
                          color: Color(0xFF747677), fontSize: 10)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$days days',
                      style: const TextStyle(
                          color: Color(0xFF595A5B),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  Text('Every $hours hours',
                      style: const TextStyle(
                          color: Color(0xFF747677), fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDateInfo('Starting date', _formatDisplayDate(startDate)),
                _buildDateInfo('End date', _formatDisplayDate(endDate)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillTag(String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF1F5),
          borderRadius: BorderRadius.circular(64),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Color(0xFF595A5B),
                fontSize: 12,
                fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
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

  String _formatDisplayDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  // --- Sick Leave ---

  Widget _buildSickLeaveSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Days input
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Requires sick leave for (number of days)',
              style: TextStyle(
                  color: Color(0xFF595A5B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 280,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBFCFD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE9E9E9)),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0C101828),
                        blurRadius: 2,
                        offset: Offset(0, 1)),
                  ],
                ),
                child: TextField(
                  controller: _controller.sickLeaveDaysController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        color: Color(0xFFA6A9AC), fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Start date
        SizedBox(
          width: 280,
          child: _buildDateField(
            'Start date',
            false,
            _sickLeaveDate,
            (d) {
              setState(() => _sickLeaveDate = d);
              _controller.sickLeaveStartDate = d;
            },
          ),
        ),
      ],
    );
  }
}
