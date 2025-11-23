import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/users/assign_role_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';
import '../../shared/widgets/breadcrumb_widget.dart';
import 'users_datatable.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 247, 247),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 16),
                Obx(() {
                  if (controller.users.isEmpty) {
                    return const _EmptyUsersPlaceholder();
                  }

                  final selected = controller.selectedUser.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: selected == null
                        ? const _UserTableBlock()
                        : _AssignRoleBlock(user: selected),
                  );
                }),
              ],
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Users',
          style: TextStyle(
            color: Color(0xFF2D2E2E),
            fontSize: 20,
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w700,
            height: 1.40,
          ),
        ),
        BreadcrumbWidget(
          items: [
            BreadcrumbItem(label: 'Ayamedica portal'),
            BreadcrumbItem(label: 'Ressources'),
            BreadcrumbItem(label: 'Users'),
          ],
        ),
      ],
    );
  }
}

class _EmptyUsersPlaceholder extends StatelessWidget {
  const _EmptyUsersPlaceholder({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE2E4E8)),
        borderRadius: BorderRadius.circular(6),
        color: const Color(0xFFF8FAFC),
      ),
      child: const Text(
        'No users found',
        style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
      ),
    );
  }
}

class _UserTableBlock extends StatelessWidget {
  const _UserTableBlock({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('table'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        UsersDatatable(),
      ],
    );
  }
}

class _AssignRoleBlock extends StatelessWidget {
  final dynamic user; // replace dynamic with your UserModel type

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
        SizedBox(height: 16),
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
                // Clear existing selections and select new one
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
