import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:get/get.dart';

import 'tree_connector_painter.dart';

class BranchItem extends StatelessWidget {
  final BranchModel branch;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const BranchItem({
    Key? key,
    required this.branch,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTreeConnector(),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              margin: const EdgeInsets.only( top: 12, bottom: 12),
              decoration: ShapeDecoration(
                color: const Color(0xFFEDF1F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  _buildBranchIcon(),
                  const SizedBox(width: 12),
                  _buildBranchInfo(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTreeConnector() {
    return SizedBox(
      width: 24,
      height: 100,
      child: CustomPaint(
        painter: TreeConnectorPainter(
          isFirst: isFirst,
          isLast: isLast,
        ),
      ),
    );
  }

  Widget _buildBranchIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: ShapeDecoration(
        color: const Color(0xFFCDFF1F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: const Icon(
        Icons.local_hospital,
        size: 20,
        color: Color(0xFF1339FF),
      ),
    );
  }

  Widget _buildBranchInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            branch.name,
            style: const TextStyle(
              color: Color(0xFF2D2E2E),
              fontSize: 14,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w600,
              height: 1.43,
              letterSpacing: 0.28,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            branch.role,
            style: const TextStyle(
              color: Color(0xFF6F6F6F),
              fontSize: 12,
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w400,
              height: 1.33,
              letterSpacing: 0.36,
            ),
          ),
        ],
      ),
    );
  }
}
