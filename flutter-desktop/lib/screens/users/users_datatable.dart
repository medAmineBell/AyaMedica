import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';
import '../../models/user_model.dart';
import 'widgets/add_edit_user_dialog.dart';
import 'widgets/delete_user_dialog.dart';

class UsersDatatable extends StatelessWidget {
  const UsersDatatable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();

    return Obx(() {
      final users = controller.filteredUsers;
      if (users.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        children: [
          _buildHeaderRow(),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (ctx, index) =>
                  _buildDataRow(ctx, users[index], controller),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeaderRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2F5),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerCell('User name & role')),
          Expanded(flex: 2, child: _headerCell('Type')),
          Expanded(flex: 2, child: _headerCell('Branch(s)')),
          Expanded(flex: 2, child: _headerCell('Role')),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                const Text(
                  'Status',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.help_outline,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
          Expanded(flex: 2, child: _headerCell('Actions')),
        ],
      ),
    );
  }

  Widget _buildDataRow(BuildContext context, UserModel user, UsersController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          // User name & role
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _colorFromName(user.name),
                  backgroundImage:
                      user.photo != null ? NetworkImage(user.photo!) : null,
                  child: user.photo == null
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name.substring(0, 2).toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF374151),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.aid != null && user.aid!.isNotEmpty)
                        Text(
                          user.aid!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Type
          Expanded(
            flex: 2,
            child: Text(
              user.type,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
          // Branch(s)
          Expanded(
            flex: 2,
            child: Text(
              user.branchNames.isNotEmpty ? user.branchNames : '-',
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Role badges
          Expanded(
            flex: 2,
            child: user.roles.isEmpty
                ? const Text('-',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)))
                : Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: user.roles.map((r) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r.role,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF059669),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.active
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: user.active
                          ? const Color(0xFF059669)
                          : const Color(0xFFD97706),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Delete
                IconButton(
                  tooltip: 'Delete',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => DeleteUserDialog(user: user),
                  ),
                  icon: const Icon(Icons.delete_outline,
                      size: 18, color: Color(0xFFEF4444)),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                // Edit
                IconButton(
                  tooltip: 'Edit',
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AddEditUserDialog(user: user),
                  ),
                  icon: const Icon(Icons.edit_outlined,
                      size: 18, color: Color(0xFF6B7280)),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
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
