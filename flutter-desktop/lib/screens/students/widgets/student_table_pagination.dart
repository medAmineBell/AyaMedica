import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/student_controller.dart';

class StudentTablePagination extends StatelessWidget {
  final StudentController controller;

  const StudentTablePagination({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Obx(() => Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PaginationButton(
                icon: Icons.arrow_back,
                label: 'Previous',
                onPressed: controller.currentPage.value > 0
                    ? controller.previousPage
                    : null,
              ),
              _PageNumbers(controller: controller),
              _PaginationButton(
                icon: Icons.arrow_forward,
                label: 'Next',
                onPressed: controller.currentPage.value < controller.totalPages - 1
                    ? controller.nextPage
                    : null,
              ),
            ],
          )),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _PaginationButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _PageNumbers extends StatelessWidget {
  final StudentController controller;

  const _PageNumbers({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < controller.totalPages && i < 10; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: _PageNumberButton(
              pageNumber: i + 1,
              isSelected: i == controller.currentPage.value,
              onTap: () => controller.goToPage(i),
            ),
          ),
        if (controller.totalPages > 10) ...[
          Text('...', style: TextStyle(color: Colors.grey.shade600)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: _PageNumberButton(
              pageNumber: controller.totalPages,
              isSelected: false,
              onTap: () => controller.goToPage(controller.totalPages - 1),
            ),
          ),
        ],
      ],
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  final int pageNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const _PageNumberButton({
    required this.pageNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            '$pageNumber',
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}