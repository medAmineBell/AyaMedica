import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:get/get.dart';

class CommunicationPaginationWidget extends StatelessWidget {
  const CommunicationPaginationWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunicationController>();

    return Obx(() {
      final totalItems = controller.filteredMessages.length;
      final totalPages = controller.totalPages;
      final currentPage = controller.currentPage.value;

      if (totalPages <= 1) return SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            ElevatedButton.icon(
              onPressed: currentPage > 1 ? controller.previousPage : null,
              icon: Icon(Icons.arrow_back, size: 16),
              label: Text('Previous'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor:
                    currentPage > 1 ? Color(0xFF374151) : Color(0xFF6B7280),
                elevation: 0,
                side: BorderSide(color: Color(0xFFE5E7EB)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),

            // Page numbers
            _buildPageNumbers(
              currentPage,
              totalPages,
              controller,
            ),

            // Next button
            ElevatedButton.icon(
              onPressed: currentPage < totalPages ? controller.nextPage : null,
              icon: Text('Next'),
              label: Icon(Icons.arrow_forward, size: 16),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: currentPage < totalPages
                    ? Color(0xFF374151)
                    : Color(0xFF6B7280),
                elevation: 0,
                side: BorderSide(color: Color(0xFFE5E7EB)),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPageNumbers(
      int currentPage, int totalPages, CommunicationController controller) {
    List<Widget> pageWidgets = [];

    // first page
    pageWidgets.add(_buildPageButton(
      1,
      currentPage == 1,
      controller,
    ));

    // show ellipsis or range...
    int startPage = 2;
    int endPage = totalPages - 1;

    if (totalPages <= 7) {
      // show all
      for (int i = startPage; i <= endPage; i++) {
        pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
      }
    } else {
      if (currentPage <= 4) {
        // 2..5
        for (int i = 2; i <= 5; i++) {
          pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
        }
        pageWidgets
            .add(Text('...', style: TextStyle(color: Color(0xFF6B7280))));
      } else if (currentPage >= totalPages - 3) {
        pageWidgets
            .add(Text('...', style: TextStyle(color: Color(0xFF6B7280))));
        for (int i = totalPages - 4; i < totalPages; i++) {
          pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
        }
      } else {
        pageWidgets
            .add(Text('...', style: TextStyle(color: Color(0xFF6B7280))));
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
          pageWidgets.add(_buildPageButton(i, currentPage == i, controller));
        }
        pageWidgets
            .add(Text('...', style: TextStyle(color: Color(0xFF6B7280))));
      }
    }

    // last page
    if (totalPages > 1) {
      pageWidgets.add(_buildPageButton(
        totalPages,
        currentPage == totalPages,
        controller,
      ));
    }

    return Row(children: pageWidgets);
  }

  Widget _buildPageButton(
      int page, bool isActive, CommunicationController controller) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 2),
      child: ElevatedButton(
        onPressed: () => controller.goToPage(page),
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Color(0xFFDBEAFE) : Colors.white,
          foregroundColor: isActive ? Color(0xFF1339FF) : Color(0xFF6B7280),
          elevation: 0,
          minimumSize: Size(32, 32),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: isActive ? Color(0xFF1339FF) : Color(0xFFE5E7EB),
            ),
          ),
        ),
        child: Text('$page'),
      ),
    );
  }
}
