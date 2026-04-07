import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:get/get.dart';

class StudentTablePagination extends StatelessWidget {
  final StudentController controller;

  const StudentTablePagination({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentPage = controller.currentPage.value;
      final totalPages = controller.totalPages.value;

      if (totalPages <= 1) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            _buildNavButton(
              icon: Icons.arrow_back,
              label: 'Previous',
              isLeading: true,
              enabled: currentPage > 1,
              onTap: controller.previousPage,
            ),

            // Page numbers
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildPageNumbers(currentPage, totalPages),
            ),

            // Next button
            _buildNavButton(
              icon: Icons.arrow_forward,
              label: 'Next',
              isLeading: false,
              enabled: currentPage < totalPages,
              onTap: controller.nextPage,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required bool isLeading,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = enabled ? Colors.grey.shade800 : Colors.grey.shade400;

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLeading) ...[
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            if (!isLeading) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: color),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(int currentPage, int totalPages) {
    final pages = <Widget>[];
    final pageNumbers = _getVisiblePages(currentPage, totalPages);

    for (int i = 0; i < pageNumbers.length; i++) {
      final page = pageNumbers[i];

      if (page == -1) {
        // Ellipsis
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        );
      } else {
        final isActive = page == currentPage;
        pages.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: InkWell(
              onTap: () => controller.goToPage(page),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color:
                      isActive ? const Color(0xFF1339FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    page.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return pages;
  }

  /// Returns list of page numbers to show. -1 represents ellipsis.
  /// Pattern: 1 2 3 ... 8 9 10
  List<int> _getVisiblePages(int currentPage, int totalPages) {
    if (totalPages <= 7) {
      return List.generate(totalPages, (i) => i + 1);
    }

    final pages = <int>[];

    // Always show first 3 pages
    if (currentPage <= 4) {
      for (int i = 1; i <= 5; i++) {
        pages.add(i);
      }
      pages.add(-1); // ellipsis
      pages.add(totalPages - 1);
      pages.add(totalPages);
    }
    // Always show last 3 pages
    else if (currentPage >= totalPages - 3) {
      pages.add(1);
      pages.add(2);
      pages.add(-1); // ellipsis
      for (int i = totalPages - 4; i <= totalPages; i++) {
        pages.add(i);
      }
    }
    // Show pages around current
    else {
      pages.add(1);
      pages.add(2);
      pages.add(3);
      pages.add(-1); // ellipsis
      pages.add(currentPage - 1);
      pages.add(currentPage);
      pages.add(currentPage + 1);
      pages.add(-1); // ellipsis
      pages.add(totalPages - 1);
      pages.add(totalPages);
    }

    return pages;
  }
}
