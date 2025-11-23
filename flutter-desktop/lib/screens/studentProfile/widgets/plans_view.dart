import 'package:flutter/material.dart';

class PlansView extends StatefulWidget {
  const PlansView({super.key});

  @override
  State<PlansView> createState() => _PlansViewState();
}

class _PlansViewState extends State<PlansView> {
  // Controllers for text fields
  final TextEditingController _activeIngredientController = TextEditingController();
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _numberOfDaysController = TextEditingController();
  final TextEditingController _everyHoursController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _sickLeaveNotesController = TextEditingController();
  final TextEditingController _sickLeaveDaysController = TextEditingController();

  // Dropdown values
  String? _relationToFood;
  String? _administrationForm;
  
  // Date picker
  DateTime? _selectedDate;
  
  // Dropdown options
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
    'Oral',
    'Injection',
    'Topical',
    'Inhalation',
    'Sublingual',
    'Rectal',
    'Transdermal',
  ];

  // Tags for frequency
  List<String> _selectedTags = ['After dinner', 'After Lunch'];

  @override
  void initState() {
    super.initState();
    // Set default values
    _relationToFood = 'After dinner';
    _administrationForm = 'Oral';
    _selectedDate = DateTime.now();
    _numberOfDaysController.text = '8';
    _everyHoursController.text = '4';
    _sickLeaveDaysController.text = '8';
  }

  @override
  void dispose() {
    _activeIngredientController.dispose();
    _drugNameController.dispose();
    _numberOfDaysController.dispose();
    _everyHoursController.dispose();
    _notesController.dispose();
    _sickLeaveNotesController.dispose();
    _sickLeaveDaysController.dispose();
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
            // Header Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Add plans',
                    style: TextStyle(
                      color: Color(0xFF2D2E2E),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.56,
                      letterSpacing: 0.09,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _summarizeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1339FF),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, 
                        vertical: 8
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Summarize profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.summarize, size: 20, color: Colors.white),
                      ],
                    ),
                  ),
                ],
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

            // Input Fields Section
            _buildInputSection(),
            
            const SizedBox(height: 32),

            // Frequency Section
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
            _buildDrugCard(),
            
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
            _buildNotesField('Notes', 95, _sickLeaveNotesController),
          ],
        ),
      ),
    );
  }

  void _summarizeProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile summarized!')),
    );
  }

  // Helper Widgets
  Widget _buildInputRow(String label, bool isRequired, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF595A5B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFED1F4F),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          // padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE9E9E9)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C101828),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'search',
              hintStyle: TextStyle(
                color: Color(0xFFA6A9AC),
                fontSize: 14,
              ),
              prefixIcon: Icon(Icons.search, color: Color(0xFFA6A9AC)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputSection() {
    return Row(
      children: [
        Expanded(
          child: _buildInputRow('Active ingredient', true, _activeIngredientController),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInputRow('Drug name', true, _drugNameController),
        ),
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField('Relation to food', true, _relationToFood, _relationToFoodOptions, (value) {
            setState(() {
              _relationToFood = value;
            });
          }),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildDropdownField('Administration form', true, _administrationForm, _administrationFormOptions, (value) {
            setState(() {
              _administrationForm = value;
            });
          }),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, bool isRequired, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF595A5B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFED1F4F),
                fontSize: 14,
              ),
            ),
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
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              onChanged: onChanged,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Color(0xFF2D2E2E),
                      fontSize: 14,
                    ),
                  ),
                );
              }).toList(),
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
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedTags.remove(text);
              });
            },
            child: const Icon(Icons.close, size: 16, color: Color(0xFF595A5B)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildDateField('Starting date', true),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildNumberField('Number of day', true, _numberOfDaysController),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildNumberField('Every (hours)', true, _everyHoursController),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, bool isRequired) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF595A5B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFED1F4F),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(const Duration(days: 365)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9E9E9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C101828),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: Color(0xFFA6A9AC)),
                    const SizedBox(width: 8),
                    Text(
                      _selectedDate != null 
                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                        : '23/07/2025',
                      style: const TextStyle(
                        color: Color(0xFF2D2E2E),
                        fontSize: 14,
                      ),
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

  Widget _buildNumberField(String label, bool isRequired, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF595A5B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isRequired)
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFED1F4F),
                fontSize: 14,
              ),
            ),
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
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: Color(0xFFA6A9AC),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField(String hint, double height, TextEditingController controller) {
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
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFFA6A9AC),
            fontSize: 14,
          ),
        ),
        maxLines: null,
      ),
    );
  }

  Widget _buildAddDrugButton() {
    return OutlinedButton(
      onPressed: _addDrug,
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: const BorderSide(color: Color(0xFFA6A9AC)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: Color(0xFF747677)),
          SizedBox(width: 8),
          Text(
            'Add Drug',
            style: TextStyle(
              color: Color(0xFF747677),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _addDrug() {
    if (_drugNameController.text.isNotEmpty && _activeIngredientController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Drug added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in required fields')),
      );
    }
  }

  Widget _buildDrugCard() {
    return Container(
      width: 265,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _drugNameController.text.isNotEmpty ? _drugNameController.text : '{Drug name}',
                style: const TextStyle(
                  color: Color(0xFF2D2E2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Drug card removed')),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildPillTag(_activeIngredientController.text.isNotEmpty ? _activeIngredientController.text : 'Active ingredient'),
              const SizedBox(width: 8),
              _buildPillTag(_administrationForm ?? 'Oral'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'x2',
                    style: TextStyle(
                      color: Color(0xFF595A5B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _relationToFood ?? 'After Dinner',
                    style: const TextStyle(
                      color: Color(0xFF747677),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_numberOfDaysController.text.isNotEmpty ? _numberOfDaysController.text : '4'} days',
                    style: const TextStyle(
                      color: Color(0xFF595A5B),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Every ${_everyHoursController.text.isNotEmpty ? _everyHoursController.text : '24'} hours',
                    style: const TextStyle(
                      color: Color(0xFF747677),
                      fontSize: 10,
                    ),
                  ),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Starting date',
                      style: TextStyle(
                        color: Color(0xFF747677),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _selectedDate != null 
                        ? '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'
                        : '27/07/2025',
                      style: const TextStyle(
                        color: Color(0xFF1339FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'End date',
                      style: TextStyle(
                        color: Color(0xFF747677),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      _selectedDate != null && _numberOfDaysController.text.isNotEmpty
                        ? (() {
                            final endDate = _selectedDate!.add(Duration(days: int.tryParse(_numberOfDaysController.text) ?? 4));
                            return '${endDate.day.toString().padLeft(2, '0')}/${endDate.month.toString().padLeft(2, '0')}/${endDate.year}';
                          })()
                        : '31/07/2025',
                      style: const TextStyle(
                        color: Color(0xFF1339FF),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF595A5B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSickLeaveSection() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Requires sick leave for (number of days)',
            style: TextStyle(
              color: Color(0xFF595A5B),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 280,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFBFCFD),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9E9E9)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0C101828),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: TextField(
              controller: _sickLeaveDaysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Color(0xFFA6A9AC),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}