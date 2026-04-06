import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/studentProfile/widgets/medical_record_dialog.dart';

class MedicalCard extends StatelessWidget {
  const MedicalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth < 400 ? double.infinity : 316,
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: const Color(0xFFFBFCFD),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            shadows: [
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
              // Title
              Text(
                'Hypertension',
                style: TextStyle(
                  color: const Color(0xFF2D2E2E),
                  fontSize: 16,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  letterSpacing: 0.16,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Patient has a history of hypertension and hyperlipidemia. Previous surgeries include an appendectomy in 2015. No known allergies to medications. Family history reveals cardiovascular disease in both parents.',
                style: TextStyle(
                  color: const Color(0xFF2D2E2E),
                  fontSize: 14,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w400,
                  height: 1.43,
                ),
              ),
              const SizedBox(height: 16),

              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag('Asperine'),
                  _buildTag('Algesic 1000'),
                  InkWell(
                    onTap: () {
                      // Handle view all action
                       showDialog(
    context: context,
    builder: (context) => const MedicalRecordDialog(),
  );
                    },
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: const Color(0xFF1397FF),
                        fontSize: 12,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w500,
                        height: 1.33,
                        letterSpacing: 0.36,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // History Entries
              Column(
                children: [
                  _buildHistoryItem(
                    context,
                    avatarColor: const Color(0xFFD8FAE4),
                    name: 'User full name',
                    date: '17/06/2025 | 04:37 AM',
                  ),
                  const SizedBox(height: 8),
                  _buildHistoryItem(
                    context,
                    avatarColor: const Color(0xFFCDF7FF),
                    name: 'Dr name goes here',
                    date: '17/06/2025 | 04:37 AM',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: const Color(0xFFEDF1F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: const Color(0xFF595A5B),
          fontSize: 12,
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w700,
          height: 1.33,
          letterSpacing: 0.36,
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context,
      {required Color avatarColor, required String name, required String date}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8),
    
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar + Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: ShapeDecoration(
                  color: avatarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1000),
                  ),
                ),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.person, size: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                name,
                style: TextStyle(
                  color: const Color(0xFF595A5B),
                  fontSize: 12,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  height: 1.33,
                  letterSpacing: 0.36,
                ),
              ),
            ],
          ),

          // Date
          Text(
            date,
            style: TextStyle(
              color: const Color(0xFF1339FF),
              fontSize: 10,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
