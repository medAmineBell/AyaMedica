import 'package:flutter/material.dart';

import 'vitals_card.dart';

class AssessmentView extends StatelessWidget {
   AssessmentView({super.key});
    final vitals = [
      {'title': 'Heart Rate', 'value': '90 bpm'},
      {'title': 'Blood Pressure', 'value': '120/80 mmHg'},
      {'title': 'Temperature', 'value': '36.8 °C'},
      {'title': 'Respiratory Rate', 'value': '18 breaths/min'},
      {'title': 'Blood Glucose', 'value': '100 mg/dL'},
      {'title': 'Oxygen Saturation', 'value': '98%'},
      {'title': 'Height & Weight', 'value': '170 cm / 65 kg'},
    ];
Icon _getIconForVital(String title) {
  switch (title) {
    case 'Heart Rate':
      return const Icon(Icons.favorite, color:  Color(0xFF1339FF), size: 24);
    case 'Blood Pressure':
      return const Icon(Icons.bloodtype, color:  Color(0xFF1339FF), size: 24);
    case 'Temperature':
      return const Icon(Icons.thermostat, color:  Color(0xFF1339FF), size: 24);
    case 'Respiratory Rate':
      return const Icon(Icons.air, color:  Color(0xFF1339FF), size: 24);
    case 'Blood Glucose':
      return const Icon(Icons.medication, color:  Color(0xFF1339FF), size: 24);
    case 'Oxygen Saturation':
      return const Icon(Icons.bubble_chart, color:  Color(0xFF1339FF), size: 24);
    case 'Height & Weight':
      return const Icon(Icons.height, color:  Color(0xFF1339FF), size: 24);
    default:
      return const Icon(Icons.health_and_safety, size: 24, color: Colors.grey);
  }
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child:
       Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Assessments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
SizedBox(
  height: 120,
  child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: vitals.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final vital = vitals[index];
            return VitalsCard(
              title: vital['title']!,
              value: vital['value']!,
leadingIcon: _getIconForVital(vital['title']!),
            );},),
),
          const SizedBox(height: 24),
          _buildSectionLabel("Chief complaint", required: true),
          const SizedBox(height: 8),
          _buildSearchField(),

          const SizedBox(height: 8),
          _buildTag("Skin infection"),

          const SizedBox(height: 24),
          const Text("Examination", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          _buildMultilineField("Examination details"),

          const SizedBox(height: 24),
          const Text("Assessment", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Suspected disease(s)", required: true),
                  _buildSearchField(),
                  const SizedBox(height: 8),
                  _buildTag("Allergic Conjunctivitis"),
                ],
              )),
              const SizedBox(width: 24),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Recommendations(s)", required: true),
                  _buildSearchField(),
                  const SizedBox(height: 8),
                  _buildTag("Dermatology"),
                ],
              )),
            ],
          ),

          const SizedBox(height: 40),
   Row(
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Cancel"),
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1339FF),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text("Add assessment"),
      ),
    ),
  ],
),
     ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        children: required
            ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

Widget _buildSearchField() {
  return TextField(
    style: const TextStyle(fontSize: 14),
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
      hintText: "search",
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
      ),
    ),
  );
}
Widget _buildMultilineField(String hint) {
  return TextField(
    maxLines: 4,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
      ),
    ),
  );
}


Widget _buildTag(String label) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    margin: const EdgeInsets.only(right: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF111827), // dark gray/black
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFEC4899), // pink
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close,
            size: 14,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );
}
}
