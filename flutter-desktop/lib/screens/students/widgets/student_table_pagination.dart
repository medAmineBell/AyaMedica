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
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Results info
            Text(
              'Showing ${controller.students.length} of ${controller.totalStudents.value} results',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),

            // Pagination controls
            Row(
              children: [
                // Previous button
                IconButton(
                  onPressed: controller.currentPage.value > 1
                      ? controller.previousPage
                      : null,
                  icon: const Icon(Icons.chevron_left),
                  color: controller.currentPage.value > 1
                      ? Colors.blue.shade600
                      : Colors.grey.shade400,
                ),

                // Page numbers
                ...List.generate(
                  controller.totalPages.value,
                  (index) {
                    final pageNumber = index + 1;
                    final isCurrentPage =
                        controller.currentPage.value == pageNumber;

                    // Show max 5 page numbers
                    if (controller.totalPages.value > 5) {
                      if (pageNumber == 1 ||
                          pageNumber == controller.totalPages.value ||
                          (pageNumber >= controller.currentPage.value - 1 &&
                              pageNumber <= controller.currentPage.value + 1)) {
                        return _buildPageButton(pageNumber, isCurrentPage);
                      } else if (pageNumber ==
                              controller.currentPage.value - 2 ||
                          pageNumber == controller.currentPage.value + 2) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('...',
                              style: TextStyle(color: Colors.grey.shade600)),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    return _buildPageButton(pageNumber, isCurrentPage);
                  },
                ),

                // Next button
                IconButton(
                  onPressed:
                      controller.currentPage.value < controller.totalPages.value
                          ? controller.nextPage
                          : null,
                  icon: const Icon(Icons.chevron_right),
                  color:
                      controller.currentPage.value < controller.totalPages.value
                          ? Colors.blue.shade600
                          : Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPageButton(int pageNumber, bool isCurrentPage) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () => controller.goToPage(pageNumber),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrentPage ? Colors.blue.shade600 : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color:
                  isCurrentPage ? Colors.blue.shade600 : Colors.grey.shade300,
            ),
          ),
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: isCurrentPage ? FontWeight.w600 : FontWeight.w400,
              color: isCurrentPage ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }
}
