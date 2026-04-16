import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddMedicalHistoryDialog extends StatefulWidget {
  const AddMedicalHistoryDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AddMedicalHistoryDialog(),
    );
  }

  @override
  State<AddMedicalHistoryDialog> createState() =>
      _AddMedicalHistoryDialogState();
}

class _AddMedicalHistoryDialogState extends State<AddMedicalHistoryDialog> {
  int _currentStep = 0; // 0 = medical history details, 1 = medication/plans

  // Step 1 fields
  String _selectedCategory = 'Chronic diseases';
  String _selectedChronicCategory = 'Essential (Primary) Hypertension';
  DateTime? _consultationDate;
  final TextEditingController _additionalDetailsController =
      TextEditingController();

  // Step 2 fields
  final TextEditingController _activeIngredientController =
      TextEditingController();
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _numberOfDaysController = TextEditingController();
  final TextEditingController _everyHoursController = TextEditingController();
  final TextEditingController _dozeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _sickLeaveDaysController =
      TextEditingController();
  final TextEditingController _sickLeaveNotesController =
      TextEditingController();

  String? _relationToFood;
  String? _administrationForm;
  String? _dozeType;
  DateTime? _drugStartDate;
  DateTime? _sickLeaveDate;
  final List<String> _selectedTags = [];
  final List<Map<String, dynamic>> _addedDrugs = [];

  static const List<String> _categories = [
    'Chronic diseases',
    'Allergies',
    'Surgeries',
    'Injuries',
    'Other',
  ];

  static const List<String> _chronicCategories = [
    'Essential (Primary) Hypertension',
    'Type 1 Diabetes Mellitus',
    'Type 2 Diabetes Mellitus',
    'Asthma',
    'Epilepsy',
    'Sickle Cell Disease',
    'Thalassemia',
    'Congenital Heart Disease',
    'Celiac Disease',
    'Other',
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
  void dispose() {
    _additionalDetailsController.dispose();
    _activeIngredientController.dispose();
    _drugNameController.dispose();
    _numberOfDaysController.dispose();
    _everyHoursController.dispose();
    _dozeController.dispose();
    _notesController.dispose();
    _sickLeaveDaysController.dispose();
    _sickLeaveNotesController.dispose();
    super.dispose();
  }

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

  // ─── STEP 1: Medical history details ───

  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.all(32),
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
            'Add new medical history',
            style: TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the medical history details and upload the required document',
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
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  'Category',
                  true,
                  _selectedCategory,
                  _categories,
                  (v) => setState(() => _selectedCategory = v!),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  'Chronic disease category',
                  true,
                  _selectedChronicCategory,
                  _chronicCategories,
                  (v) => setState(() => _selectedChronicCategory = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDateField(
            'Consultation date',
            true,
            _consultationDate,
            (d) => setState(() => _consultationDate = d),
          ),
          const SizedBox(height: 16),
          _buildLabel('Additional details', false),
          const SizedBox(height: 6),
          Container(
            height: 120,
            decoration: _fieldDecoration(),
            child: TextField(
              controller: _additionalDetailsController,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Additional details',
                contentPadding: EdgeInsets.all(14),
                hintStyle: TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),
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
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentStep = 1),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1339FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Next: add medication history',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── STEP 2: Medication / Plans ───

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
              'Request new record',
              style: TextStyle(
                color: Color(0xFF2D2E2E),
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Requires approval from the patient app',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'Add prescriptions and plan details here',
              style: TextStyle(color: Color(0xFF595A5B), fontSize: 14),
            ),
            const SizedBox(height: 24),

            // Drug search fields
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                      'Active ingredient', true, _activeIngredientController,
                      prefixIcon: Icons.search),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                      'Drug name', true, _drugNameController,
                      prefixIcon: Icons.search),
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
                    true,
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
                    true,
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
                                  onTap: () => setState(
                                      () => _selectedTags.remove(tag)),
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
                    true,
                    _drugStartDate,
                    (d) => setState(() => _drugStartDate = d),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                      'Number of day', true, _numberOfDaysController,
                      prefixIcon: Icons.calendar_today),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberField(
                      'Every (hours)', true, _everyHoursController,
                      prefixIcon: Icons.access_time),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Notes
            Container(
              height: 95,
              decoration: _fieldDecoration(),
              child: TextField(
                controller: _notesController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Notes',
                  contentPadding: EdgeInsets.all(14),
                  hintStyle:
                      TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
                ),
              ),
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
                children: List.generate(
                    _addedDrugs.length, (i) => _buildDrugCard(i)),
              ),

            const SizedBox(height: 24),

            // Sick leave
            Row(
              children: [
                const Text('Requires sick leave for (number of days)',
                    style: TextStyle(
                        color: Color(0xFF595A5B),
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
                const SizedBox(width: 16),
                SizedBox(
                  width: 200,
                  child: _buildSmallNumberField(_sickLeaveDaysController,
                      prefixIcon: Icons.calendar_today),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sick leave notes
            Container(
              height: 95,
              decoration: _fieldDecoration(),
              child: TextField(
                controller: _sickLeaveNotesController,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Notes',
                  contentPadding: EdgeInsets.all(14),
                  hintStyle:
                      TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => _currentStep = 0),
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
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: wire to API later
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1339FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Add record',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Shared helpers ───

  void _addDrug() {
    if (_drugNameController.text.isEmpty) return;

    final days = int.tryParse(_numberOfDaysController.text) ?? 0;
    final endDate = (_drugStartDate != null && days > 0)
        ? _drugStartDate!.add(Duration(days: days))
        : null;

    _addedDrugs.add({
      'drug_name': _drugNameController.text,
      'active_ingredient': _activeIngredientController.text,
      if (_dozeController.text.isNotEmpty) 'dose': _dozeController.text,
      if (_dozeType != null) 'dose_type': _dozeType,
      if (_selectedTags.isNotEmpty) 'relation_to_food': _selectedTags.toList(),
      if (_administrationForm != null) 'administration_form': _administrationForm,
      if (_everyHoursController.text.isNotEmpty)
        'every_hours': _everyHoursController.text,
      if (_numberOfDaysController.text.isNotEmpty)
        'days': _numberOfDaysController.text,
      if (_drugStartDate != null)
        'start_date': DateFormat('yyyy-MM-dd').format(_drugStartDate!),
      if (endDate != null)
        'end_date': DateFormat('yyyy-MM-dd').format(endDate),
      if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
    });

    _drugNameController.clear();
    _activeIngredientController.clear();
    _dozeController.clear();
    _notesController.clear();
    setState(() {});
  }

  Widget _buildDrugCard(int index) {
    final drug = _addedDrugs[index];
    final name = drug['drug_name'] as String? ?? '';
    final ingredient = drug['active_ingredient'] as String? ?? '';
    final form = drug['administration_form'] as String? ?? '';
    final dose = drug['dose']?.toString() ?? '';
    final doseType = drug['dose_type']?.toString() ?? '';
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
                    _buildDateInfo('Starting date', _formatDate(startDate)),
                  if (endDate.isNotEmpty)
                    _buildDateInfo('End date', _formatDate(endDate)),
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

  String _formatDate(String dateStr) {
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  // ─── Field builders ───

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        Container(
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

  Widget _buildDateField(String label, bool required, DateTime? date,
      ValueChanged<DateTime> onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
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
      {IconData? prefixIcon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, required),
        const SizedBox(height: 6),
        Container(
          decoration: _fieldDecoration(),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'search',
              hintStyle:
                  const TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFFA6A9AC))
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
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
      crossAxisAlignment: CrossAxisAlignment.start,
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
      decoration: _fieldDecoration(),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14),
          hintStyle: const TextStyle(color: Color(0xFFA6A9AC), fontSize: 14),
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 18, color: const Color(0xFFA6A9AC))
              : null,
        ),
      ),
    );
  }
}
