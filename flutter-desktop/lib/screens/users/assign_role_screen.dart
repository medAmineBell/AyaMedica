import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';

class AssignRoleInline extends StatelessWidget {
  const AssignRoleInline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TopForm(),
        SizedBox(height: 20),
        _MainSplit(),
      ],
    );
  }
}

class _MainSplit extends StatelessWidget {
  const _MainSplit({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _Sidebar(),
        SizedBox(width: 20),
        Expanded(child: _PermissionsCard()),
      ],
    );
  }
}

/* -------------------- Sidebar -------------------- */

class _Sidebar extends StatefulWidget {
  const _Sidebar({Key? key}) : super(key: key);

  @override
  State<_Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<_Sidebar> {
  int selected = 0;

  final items = const [
    _SideItemData('Management module', 'assets/svg/user-avatar.svg'),
    _SideItemData('Clinic and medical module', 'assets/svg/user-avatar.svg'),
    _SideItemData('Mobile App management', 'assets/svg/user-avatar.svg'),
    _SideItemData('Subscription & plans', 'assets/svg/user-avatar.svg'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: List.generate(items.length, (i) {
          final itm = items[i];
          final active = i == selected;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => selected = i),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: active ? const Color(0xFFEFF5FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    itm.iconPath,
                    width: 20,
                    height: 20,
                    color: const Color(0xFF1F62E8),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      itm.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: const Color(0xFF1F2A37),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: active
                        ? const Color(0xFF1F62E8)
                        : const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SideItemData {
  final String title;
  final String iconPath;
  const _SideItemData(this.title, this.iconPath);
}

/* -------------------- Top Form -------------------- */

class _TopForm extends GetView<UsersController> {
  const _TopForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
    );
    return Obx(() {
      return Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: controller.emailController,
              decoration: InputDecoration(
                labelText: 'Email or AID',
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide:
                      const BorderSide(color: Color(0xFF1F62E8), width: 1.4),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: controller.selectedRole.value.isEmpty
                  ? null
                  : controller.selectedRole.value,
              decoration: _ddDecoration('Assign Role'),
              items: controller.roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: controller.onRoleSelected,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: controller.selectedPosition.value.isEmpty
                  ? null
                  : controller.selectedPosition.value,
              decoration: _ddDecoration('Assign Position'),
              items: controller.positions
                  .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                  .toList(),
              onChanged: controller.onPositionSelected,
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1F62E8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: controller.saveAssignedRole,
            child: const Text('Save',
                style: TextStyle(fontWeight: FontWeight.w600)),
          )
        ],
      );
    });
  }

  InputDecoration _ddDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1F62E8), width: 1.4),
      ),
    );
  }
}

/* -------------------- Permissions Card -------------------- */

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
      child: const _PermissionsSection(),
    );
  }
}

class _PermissionsSection extends StatelessWidget {
  const _PermissionsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const _PermissionsTable();
  }
}

/* -------------------- Permissions Table (Custom) -------------------- */

class _PermissionsTable extends GetView<UsersController> {
  const _PermissionsTable({Key? key}) : super(key: key);

  static const permColumns = ['View', 'Update', 'Create', 'Delete'];

  // Define grouped modules (group header -> list of module keys in controller.permissions)
  Map<String, List<String>> _grouped(UsersController c) {
    // You can adapt order and grouping to match screenshot
    return {
      'Dashboard management': [
        'School dashboard',
        'Students Overview Dashboard',
        'users feedback analysis',
      ],
      'Students management': [
        'Students profile and details',
        'Students medical details and records',
      ],
      'Appointments management': [
        'Checkup - all types',
        'Checkup - Special type “Hygiene checkup”',
        'Follow-up appointments',
        'Vaccination',
        'Walk in',
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Show campus-specific permissions if campuses are selected
      if (controller.selectedCampusIds.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: controller.selectedCampusIds.map((campusId) {
            final campusName = controller.listCompus
                .firstWhere((c) => c.value == campusId)
                .label;
            final assignment = controller.getCampusAssignment(campusId);
            if (assignment == null) return const SizedBox.shrink();

            return _CampusPermissionsSection(
              campusId: campusId,
              campusName: campusName,
              permissions: assignment.permissions,
            );
          }).toList(),
        );
      }

      // Fallback to original permissions display
      final permsMap = controller.permissions;
      final groups = _grouped(controller);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _tableHeader(),
          const SizedBox(height: 4),
          ...groups.entries.map((g) {
            return Column(
              children: [
                _groupHeader(g.key),
                ...g.value.map((module) {
                  // If module not in map (maybe special label), skip gracefully
                  final perms = permsMap[module];
                  if (perms == null) {
                    return _missingRow(module);
                  }
                  return _permissionRow(module, perms, null);
                }).toList(),
              ],
            );
          }),
        ],
      );
    });
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: Text(
              'Modules & features',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111928),
              ),
            ),
          ),
          ...permColumns.map((c) {
            return Expanded(
              flex: 1,
              child: Text(
                c,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _groupHeader(String title) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFE5E7EB),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.folder_open,
                size: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionRow(
      String module, Map<String, bool> perms, String? campusId) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              module,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...permColumns.map((p) {
            final value = perms[p] ?? false;
            return Expanded(
              flex: 1,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: value,
                    onChanged: (v) {
                      if (campusId != null) {
                        controller.updateCampusPermission(
                            campusId, module, p, v ?? false);
                      } else {
                        controller.togglePermission(module, p, v ?? false);
                      }
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _missingRow(String module) {
    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '$module (not defined)',
        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }
}

/* -------------------- Campus Permissions Section -------------------- */

class _CampusPermissionsSection extends GetView<UsersController> {
  final String campusId;
  final String campusName;
  final Map<String, Map<String, bool>> permissions;

  const _CampusPermissionsSection({
    required this.campusId,
    required this.campusName,
    required this.permissions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groups = _grouped(controller);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campus header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
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
                  '$campusName Permissions',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          // Permissions table
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tableHeader(),
                const SizedBox(height: 4),
                ...groups.entries.map((g) {
                  return Column(
                    children: [
                      _groupHeader(g.key),
                      ...g.value.map((module) {
                        final perms = permissions[module];
                        if (perms == null) {
                          return _missingRow(module);
                        }
                        return _permissionRow(module, perms, campusId);
                      }).toList(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<String>> _grouped(UsersController c) {
    return {
      'Dashboard management': [
        'School dashboard',
        'Students Overview Dashboard',
        'users feedback analysis',
      ],
      'Students management': [
        'Students profile and details',
        'Students medical details and records',
      ],
      'Appointments management': [
        'Checkup - all types',
        'Checkup - Special type "Hygiene checkup"',
        'Follow-up appointments',
        'Vaccination',
        'Walk in',
      ],
    };
  }

  Widget _tableHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Expanded(
            flex: 5,
            child: Text(
              'Modules & features',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111928),
              ),
            ),
          ),
          ...['View', 'Update', 'Create', 'Delete'].map((c) {
            return Expanded(
              flex: 1,
              child: Text(
                c,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _groupHeader(String title) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFE5E7EB),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.folder_open,
                size: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionRow(
      String module, Map<String, bool> perms, String campusId) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              module,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ...['View', 'Update', 'Create', 'Delete'].map((p) {
            final value = perms[p] ?? false;
            return Expanded(
              flex: 1,
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: Checkbox(
                    value: value,
                    onChanged: (v) {
                      controller.updateCampusPermission(
                          campusId, module, p, v ?? false);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity:
                        const VisualDensity(horizontal: -4, vertical: -4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _missingRow(String module) {
    return Container(
      height: 44,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        '$module (not defined)',
        style: const TextStyle(color: Colors.redAccent, fontSize: 12),
      ),
    );
  }
}

/* -------------------- Save Button (already in top form) -------------------- */
// (Removed separate save button since Save is in top bar now)
