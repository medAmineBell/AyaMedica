import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import 'branch_management_controller.dart';

class UsersController extends GetxController {
  var users = <UserModel>[].obs;

  var selectedRole = ''.obs;
  var selectedPosition = ''.obs;

  final roles = ['Doctor - Extended', 'Admin', 'Viewer'];
  final positions = ['Position 1', 'Position 2'];

  var selectedUser = Rxn<UserModel>();
  final emailController = TextEditingController();

  // Multi-campus support
  var selectedCampusIds = <String>[].obs;
  var campusAssignments = <String, CampusAssignment>{}.obs;

  // Get branches from BranchManagementController
  List<DropdownMenuEntry<String>> get listCompus {
    final branchController = Get.find<BranchManagementController>();
    return branchController.branches
        .where((branchItem) => branchItem.status == 'active')
        .map((branchItem) => DropdownMenuEntry(
              value: branchItem.id,
              label: branchItem.name,
            ))
        .toList();
  }

  // Permissions map (module -> permission -> bool)
  final permissions = <String, Map<String, bool>>{
    'School dashboard': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
    'Students Overview Dashboard': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
    'Students profile and details': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Students medical details and records': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Checkup - all types': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Hygiene checkup': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Follow-up appointments': {
      'View': true,
      'Update': true,
      'Create': true,
      'Delete': true
    },
    'Vaccination': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
    'Walk in': {
      'View': true,
      'Update': false,
      'Create': false,
      'Delete': false
    },
  }.obs;

  @override
  void onInit() {
    super.onInit();
    users.value = [
      UserModel(
        email: "jane@mail.com",
        avatarUrl: "",
        governorate: "Sousse",
        id: "2",
        name: 'Jane Smith',
        type: 'User',
        city: 'Sousse',
        role: 'Viewer',
        status: 'Inactive',
      ),
    ];
  }

  void selectUser(UserModel user) {
    selectedUser.value = user;
    emailController.text = user.email;
    selectedRole.value = user.role;
    selectedPosition.value = '';

    // Load existing campus assignments
    selectedCampusIds.clear();
    campusAssignments.clear();

    for (final assignment in user.campusAssignments) {
      selectedCampusIds.add(assignment.campusId);
      campusAssignments[assignment.campusId] = assignment;
    }
  }

  void clearSelection() {
    selectedUser.value = null;
    emailController.clear();
    selectedRole.value = '';
    selectedPosition.value = '';
    selectedCampusIds.clear();
    campusAssignments.clear();
  }

  void onRoleSelected(String? role) {
    if (role != null) selectedRole.value = role;
  }

  void onPositionSelected(String? pos) {
    if (pos != null) selectedPosition.value = pos;
  }

  void togglePermission(String module, String perm, bool value) {
    final mod = permissions[module];
    if (mod != null) {
      mod[perm] = value;
      // Reassign to trigger observers
      permissions[module] = Map<String, bool>.from(mod);
    }
  }

  void saveAssignedRole() {
    final user = selectedUser.value;
    if (user != null && selectedCampusIds.isNotEmpty) {
      // Update user with campus assignments
      final updatedAssignments = campusAssignments.values.toList();
      final updatedUser = user.copyWith(campusAssignments: updatedAssignments);

      // Update the user in the list
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = updatedUser;
      }

      Get.snackbar('Success', 'Campus assignments saved successfully');
    } else {
      Get.snackbar('Error', 'Please select at least one campus');
    }
  }

  void deleteUser(UserModel user) {
    users.remove(user);
    if (selectedUser.value?.id == user.id) clearSelection();
  }

  // Multi-campus management methods
  void toggleCampusSelection(String campusId) {
    if (selectedCampusIds.contains(campusId)) {
      selectedCampusIds.remove(campusId);
      campusAssignments.remove(campusId);
    } else {
      selectedCampusIds.add(campusId);
      final campusName =
          listCompus.firstWhere((c) => c.value == campusId).label;
      campusAssignments[campusId] = CampusAssignment(
        campusId: campusId,
        campusName: campusName,
        role: '',
        position: '',
        permissions: Map<String, Map<String, bool>>.from(permissions),
      );
    }
  }

  void updateCampusRole(String campusId, String role) {
    final assignment = campusAssignments[campusId];
    if (assignment != null) {
      campusAssignments[campusId] = assignment.copyWith(role: role);
    }
  }

  void updateCampusPosition(String campusId, String position) {
    final assignment = campusAssignments[campusId];
    if (assignment != null) {
      campusAssignments[campusId] = assignment.copyWith(position: position);
    }
  }

  void updateCampusPermission(
      String campusId, String module, String permission, bool value) {
    final assignment = campusAssignments[campusId];
    if (assignment != null) {
      final updatedPermissions =
          Map<String, Map<String, bool>>.from(assignment.permissions);
      if (updatedPermissions[module] != null) {
        updatedPermissions[module] =
            Map<String, bool>.from(updatedPermissions[module]!);
        updatedPermissions[module]![permission] = value;
      }
      campusAssignments[campusId] =
          assignment.copyWith(permissions: updatedPermissions);
    }
  }

  CampusAssignment? getCampusAssignment(String campusId) {
    return campusAssignments[campusId];
  }

  bool isCampusSelected(String campusId) {
    return selectedCampusIds.contains(campusId);
  }
}
