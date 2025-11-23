import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/appointment_scheduling_controller.dart';

class AppointmentPaginationWidget extends StatelessWidget {
  const AppointmentPaginationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AppointmentSchedulingController>();
    
    return Obx(() {
      final totalItems = controller.allAppointmentStudents.length;
      final totalPages = (totalItems / controller.itemsPerPage).ceil();
      final currentPage = controller.currentPage.value;
      
      // Don't show pagination if there's only one page or no items
      if (totalPages <= 1) {
        return const SizedBox.shrink();
      }
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous Button
            ElevatedButton.icon(
              onPressed: currentPage > 1 
                  ? () => controller.goToPreviousPage()
                  : null,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: currentPage > 1 
                    ? const Color(0xFF374151)
                    : const Color(0xFF6B7280),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
            
            // Page Numbers
            _buildPageNumbers(currentPage, totalPages, controller),
            
            // Next Button
            ElevatedButton.icon(
              onPressed: currentPage < totalPages 
                  ? () => controller.goToNextPage()
                  : null,
              icon: const Text('Next'),
              label: const Icon(Icons.arrow_forward, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: currentPage < totalPages 
                    ? const Color(0xFF374151)
                    : const Color(0xFF6B7280),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPageNumbers(int currentPage, int totalPages, AppointmentSchedulingController controller) {
    List<Widget> pageWidgets = [];
    
    // Always show first page
    if (totalPages > 0) {
      pageWidgets.add(_buildPageButton(1, currentPage == 1, controller));
    }
    
    // Calculate start and end for middle pages
    int startPage = 2;
    int endPage = totalPages - 1;
    
    if (totalPages > 7) {
      // Show ellipsis logic for many pages
      if (currentPage <= 4) {
        // Show pages 2, 3, 4, 5, ..., last
        endPage = 5;
        if (endPage < totalPages - 1) {
          for (int i = startPage; i <= endPage; i++) {
            pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
          }
          pageWidgets.add(const Text('...', style: TextStyle(color: Color(0xFF6B7280))));
        }
      } else if (currentPage >= totalPages - 3) {
        // Show 1, ..., last-4, last-3, last-2, last-1
        pageWidgets.add(const Text('...', style: TextStyle(color: Color(0xFF6B7280))));
        startPage = totalPages - 4;
        for (int i = startPage; i <= endPage; i++) {
          pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
        }
      } else {
        // Show 1, ..., current-1, current, current+1, ..., last
        pageWidgets.add(const Text('...', style: TextStyle(color: Color(0xFF6B7280))));
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
          pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
        }
        pageWidgets.add(const Text('...', style: TextStyle(color: Color(0xFF6B7280))));
      }
    } else {
      // Show all pages if total pages <= 7
      for (int i = startPage; i <= endPage; i++) {
        pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
      }
    }
    
    // Always show last page (if more than 1 page)
    if (totalPages > 1) {
      pageWidgets.add(_buildPageButton(totalPages, currentPage == totalPages, controller));
    }
    
    return Row(
      children: pageWidgets,
    );
  }

  Widget _buildPageButton(int page, bool isActive, AppointmentSchedulingController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        onPressed: () => controller.goToPage(page),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? const Color(0xFFDBEAFE) : Colors.white,
          foregroundColor: isActive ? const Color(0xFF1339FF) : const Color(0xFF6B7280),
          elevation: 0,
          minimumSize: const Size(32, 32),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isActive ? const Color(0xFF1339FF) : const Color(0xFFE5E7EB),
            ),
          ),
        ),
        child: Text('$page'),
      ),
    );
  }
}