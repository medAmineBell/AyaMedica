import 'package:flutter/material.dart';

class AddPlanScreen extends StatefulWidget {
  const AddPlanScreen({super.key});

  @override
  State<AddPlanScreen> createState() => _AddPlanScreenState();
}

class _AddPlanScreenState extends State<AddPlanScreen> {
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _drugController = TextEditingController();
  final TextEditingController _daysController = TextEditingController(text: '8');
  final TextEditingController _hoursController = TextEditingController(text: '4');
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _sickLeaveController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSubtitle(),
            const SizedBox(height: 32),
            _buildDrugInputSection(),
            const SizedBox(height: 32),
            _buildFrequencySection(),
            const SizedBox(height: 24),
            _buildFoodRelationChips(),
            const SizedBox(height: 32),
            _buildDateTimeSection(),
            const SizedBox(height: 32),
            _buildNotesField(),
            const SizedBox(height: 24),
            _buildAddDrugButton(),
            const SizedBox(height: 32),
            _buildDrugCard(),
            const SizedBox(height: 32),
            _buildSickLeaveSection(),
            const SizedBox(height: 32),
            _buildSickLeaveNotes(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Add plans',
          style: TextStyle(
            color: const Color(0xFF2D2E2E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            backgroundColor: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
          child: Row(
            children: [
              Text(
                'Summarize profile',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  height: 1.43,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.summarize, color: Colors.white),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Add prescriptions and plan details here',
      style: TextStyle(
        color: const Color(0xFF747677),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    bool showAsterisk = true,
    Widget? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFF595A5B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
            if (showAsterisk)
              Text(
                '*',
                style: TextStyle(
                  color: const Color(0xFFED1F4F),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: const Color(0xFFA6A9AC),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            filled: true,
            fillColor: const Color(0xFFFBFCFD),
            prefixIcon: prefixIcon,
            suffixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
           
          ),)
        ),
      ],
    );
  }

  Widget _buildDrugInputSection() {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            label: 'Active ingredient',
            hint: 'Search',
            prefixIcon: const Icon(Icons.medication),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInputField(
            label: 'Drug name',
            hint: 'Search',
            prefixIcon: const Icon(Icons.medication_liquid),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: TextStyle(
            color: const Color(0xFF2D2E2E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInputField(
                label: 'Relation to food',
                hint: 'After dinner',
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildInputField(
                label: 'Administration form',
                hint: 'Oral',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodRelationChips() {
    return Wrap(
      spacing: 16,
      children: [
        _buildChip('After dinner'),
        _buildChip('After lunch'),
        _buildChip('Before breakfast'),
      ],
    );
  }

  Widget _buildChip(String label) {
    return InputChip(
      label: Text(label),
      backgroundColor: const Color(0xFFEDF1F5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1000),
      ),
      onPressed: () {},
      labelStyle: TextStyle(
        color: const Color(0xFF2D2E2E),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      deleteIcon: const Icon(Icons.close, size: 20),
      onDeleted: () {},
    );
  }

  Widget _buildDateTimeSection() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildInputField(
            label: 'Starting date',
            hint: '23/07/2025',
            prefixIcon: const Icon(Icons.calendar_today),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInputField(
            label: 'Number of days',
            hint: '8',
            prefixIcon: const Icon(Icons.calendar_view_day),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInputField(
            label: 'Every (hours)',
            hint: '4',
            prefixIcon: const Icon(Icons.access_time),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Notes',
        hintStyle: TextStyle(
          color: const Color(0xFFA6A9AC),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFFBFCFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
            )      ),
    );
  }

  Widget _buildAddDrugButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF747677),
        side: const BorderSide(color: Color(0xFFA6A9AC)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add),
          const SizedBox(width: 8),
          Text(
            'Add Drug',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
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
                'Aspirin',
                style: TextStyle(
                  color: const Color(0xFF2D2E2E),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _buildDrugTag('Active ingredient'),
              _buildDrugTag('Oral'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDosageInfo('x2', 'After Dinner'),
              _buildDosageInfo('4 days', 'Every 24 hours'),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDateInfo('Starting date', '27/07/2025'),
                _buildDateInfo('End date', '31/07/2025'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF1F5),
        borderRadius: BorderRadius.circular(64),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF595A5B),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          height: 1.33,
        ),
      ),
    );
  }

  Widget _buildDosageInfo(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFF595A5B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF747677),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildDateInfo(String title, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: const Color(0xFF747677),
            fontSize: 10,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          date,
          style: TextStyle(
            color: const Color(0xFF1339FF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSickLeaveSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sick leave & notes',
          style: TextStyle(
            color: const Color(0xFF2D2E2E),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.56,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Requires sick leave for (number of days)',
              style: TextStyle(
                color: const Color(0xFF595A5B),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _sickLeaveController,
                decoration: InputDecoration(
                  hintText: '8',
                  filled: true,
                  fillColor: const Color(0xFFFBFCFD),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSickLeaveNotes() {
    return TextField(
      controller: _notesController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Notes',
        hintStyle: TextStyle(
          color: const Color(0xFFA6A9AC),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: const Color(0xFFFBFCFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9)),
      ),
    ));
  }
}