import 'package:flutter/material.dart';

class MedicationCategoryCard extends StatelessWidget {
  final String drugName;
  final String activeIngredient;
  final String route;
  final String dosage;
  final String timing;
  final String duration;
  final String frequency;
  final String startDate;
  final String endDate;

  const MedicationCategoryCard({
    Key? key,
    required this.drugName,
    required this.activeIngredient,
    required this.route,
    required this.dosage,
    required this.timing,
    required this.duration,
    required this.frequency,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA), // Light grey background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB), // Dark border
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drug name
          Text(
            drugName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151), // Dark grey
            ),
          ),
          const SizedBox(height: 12),

          // Tags row
          Row(
            children: [
              _buildPillTag(activeIngredient),
              const SizedBox(width: 8),
              _buildPillTag(route),
            ],
          ),
          const SizedBox(height: 16),

          // Dosage and Duration row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dosage section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dosage,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timing,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280), // Light grey
                    ),
                  ),
                ],
              ),

              // Duration section
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    frequency,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280), // Light grey
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6), // Slightly darker grey
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Start date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Starting date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // Light grey
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      startDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6), // Blue
                      ),
                    ),
                  ],
                ),

                // End date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'End date',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280), // Light grey
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      endDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6), // Blue
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Light grey background
        borderRadius: BorderRadius.circular(20), // Pill shape
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF374151), // Dark grey
        ),
      ),
    );
  }
}
