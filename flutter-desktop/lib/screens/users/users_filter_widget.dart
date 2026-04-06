import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';

class UsersFiltersWidget extends StatelessWidget {
  const UsersFiltersWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // Search Text Field
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'search',
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
