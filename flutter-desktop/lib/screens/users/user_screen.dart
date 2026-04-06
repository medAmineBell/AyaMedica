import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/users/assign_role_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';
import 'users_datatable.dart';
import 'users_filter_widget.dart';
import 'widgets/add_edit_user_dialog.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final selected = controller.selectedUser.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: selected == null
                        ? const _UsersTableCard()
                        : SingleChildScrollView(
                            child: _AssignRoleBlock(user: selected),
                          ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Users',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 24,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.40,
          ),
        ),
        const Spacer(),
        // Add new user button
        ElevatedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const AddEditUserDialog(),
            );
          },
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text(
            'Add new user',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1339FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

class _UsersTableCard extends StatelessWidget {
  const _UsersTableCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    return Container(
      key: const ValueKey('table'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          const UsersFiltersWidget(),
          Expanded(
            child: Obx(() {
              if (controller.state.value == UsersState.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredUsers.isEmpty) {
                return const Center(
                  child: Text(
                    'No users found',
                    style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  ),
                );
              }
              return const UsersDatatable();
            }),
          ),
        ],
      ),
    );
  }
}

class _AssignRoleBlock extends StatelessWidget {
  final dynamic user;

  const _AssignRoleBlock({required this.user, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UsersController>();
    return Column(
      key: ValueKey('assign-${user.id}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SvgPicture.asset("assets/svg/arrow-square-left.svg",
                width: 32, height: 32),
            TextButton(
              onPressed: controller.clearSelection,
              child: const Text(
                'Back to list',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Assign Role to ${user.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            const _MultiCampusSelector(),
          ],
        ),
        const SizedBox(height: 16),
        const AssignRoleInline(),
      ],
    );
  }
}

class _MultiCampusSelector extends GetView<UsersController> {
  const _MultiCampusSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Campus:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: controller.selectedCampusIds.isNotEmpty
                ? controller.selectedCampusIds.first
                : null,
            decoration: _ddDecoration('Choose Campus'),
            items: controller.listCompus
                .map((campus) => DropdownMenuItem(
                      value: campus.value,
                      child: Text(campus.label),
                    ))
                .toList(),
            onChanged: (campusId) {
              if (campusId != null) {
                controller.selectedCampusIds.clear();
                controller.campusAssignments.clear();
                controller.toggleCampusSelection(campusId);
              }
            },
          ),
          if (controller.selectedCampusIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Campus Assignment:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            ...controller.selectedCampusIds.map((campusId) {
              final campusName = controller.listCompus
                  .firstWhere((c) => c.value == campusId)
                  .label;
              return _CampusAssignmentCard(
                campusId: campusId,
                campusName: campusName,
              );
            }).toList(),
          ],
        ],
      );
    });
  }

  InputDecoration _ddDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1F62E8), width: 1.4),
      ),
    );
  }
}

class _CampusAssignmentCard extends GetView<UsersController> {
  final String campusId;
  final String campusName;

  const _CampusAssignmentCard({
    required this.campusId,
    required this.campusName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final assignment = controller.getCampusAssignment(campusId);
      if (assignment == null) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F62E8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  campusName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: assignment.role.isEmpty ? null : assignment.role,
                    decoration: _ddDecoration('Role'),
                    items: controller.roles
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (role) {
                      if (role != null) {
                        controller.updateCampusRole(campusId, role);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: assignment.position.isEmpty
                        ? null
                        : assignment.position,
                    decoration: _ddDecoration('Position'),
                    items: controller.positions
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                    onChanged: (position) {
                      if (position != null) {
                        controller.updateCampusPosition(campusId, position);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  InputDecoration _ddDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1F62E8), width: 1.4),
      ),
    );
  }
}
