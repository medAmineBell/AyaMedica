import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'status_badge.dart';

class GuardianSection extends StatelessWidget {
  final Student student;

  const GuardianSection({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // First Guardian
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'First Guardian',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    student.firstGuardianName ?? '-',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if ((student.firstGuardianRelation ?? '').isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildRelationChip(student.firstGuardianRelation!),
                  ],
                  const SizedBox(width: 8),
                  _buildStatusBadge(student.firstGuardianStatus),
                ],
              )
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Divider
        Container(
          height: 40,
          width: 1,
          color: const Color(0xFFE5E7EB),
        ),

        const SizedBox(width: 16),

        // Second Guardian
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Second Guardian',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Text(
                    student.secondGuardianName ?? '-',
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if ((student.secondGuardianRelation ?? '').isNotEmpty) ...[
                    const SizedBox(width: 6),
                    _buildRelationChip(student.secondGuardianRelation!),
                  ],
                  if (student.secondGuardianName != null) ...[
                    const SizedBox(width: 8),
                    _buildStatusBadge(student.secondGuardianStatus),
                  ],
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelationChip(String relation) {
    final label = relation
        .split('_')
        .map((w) => w.isEmpty
            ? w
            : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    if (status == 'active') {
      return const StatusBadge(
        label: 'Active',
        bgColor: Color(0xFFDCFCE7),
        dotColor: Color(0xFF16A34A),
      );
    } else if (status == 'inactive') {
      return const StatusBadge(
        label: 'Inactive',
        bgColor: Color(0xFFFEE2E2),
        dotColor: Color(0xFFDC2626),
      );
    }
    return const StatusBadge(
      label: 'Undefined',
      bgColor: Color(0xFFD1D5DB),
      dotColor: Color(0xFF6B7280),
    );
  }
}
