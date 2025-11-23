import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';
import '../../models/user_model.dart';

class UsersDatatable extends StatelessWidget {
  const UsersDatatable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() {
      final users = controller.users;
      if (users.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: const Center(
            child: Text(
              'No users found',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ),
        );
      }

      return Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(2),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2),
          5: FlexColumnWidth(2),
        },
        children: [
          _buildHeaderRow(),
          ...users.map((u) => _buildDataRow(u, controller)).toList(),
        ],
      );
    });
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 240, 242, 245),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _headerCell('User name & role'),
        _headerCellRich('Type'),
        _headerCell('City & Governorate'),
        _headerCell('Role'),
        _headerCell('Status'),
        _headerCell('Actions'),
      ],
    );
  }

  TableRow _buildDataRow(UserModel user, UsersController controller) {
    final isSelected = controller.selectedUser.value?.id == user.id;
    final rowBg = isSelected ? const Color(0xFFEFF6FF) : Colors.transparent;

    return TableRow(
      decoration: BoxDecoration(
        color: rowBg,
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _dataCell(
          controller: controller,
          user: user,
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _colorFromName(user.name),
                child: Text(
                  user.name.isNotEmpty
                      ? user.name.substring(0, 2).toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
        ),
        _dataCell(
          controller: controller,
          user: user,
          child: Text(
            user.type,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        _dataCell(
          controller: controller,
          user: user,
          child: Text(
            '${user.city} ${user.governorate}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        _dataCell(
          controller: controller,
          user: user,
          child: Text(
            user.role,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        _dataCell(
          controller: controller,
          user: user,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.status == "Active"
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: user.status == "Active"
                    ? const Color(0xFF059669)
                    : const Color(0xFFD97706),
              ),
            ),
          ),
        ),
        _dataCell(
          controller: controller,
          user: user,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Edit',
                onPressed: () => controller.selectUser(user),
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () => controller.deleteUser(user),
                icon: const Icon(Icons.delete_outline,
                    size: 18, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _headerCellRich(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.help_outline, size: 14, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _dataCell({
    required UsersController controller,
    required UserModel user,
    required Widget child,
  }) {
    return InkWell(
      onTap: () => controller.selectUser(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: child,
      ),
    );
  }

  Color _colorFromName(String name) {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFF1339FF),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
    ];
    return colors[hash.abs() % colors.length];
  }
}
