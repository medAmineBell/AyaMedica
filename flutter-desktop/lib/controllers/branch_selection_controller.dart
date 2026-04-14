import 'package:flutter/material.dart';
import 'package:flutter_getx_app/config/app_config.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/models/user_profile.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_getx_app/utils/app_snackbar.dart';

import '../routes/app_pages.dart';

class BranchSelectionController extends GetxController {
  // Services
  final StorageService _storageService = Get.find<StorageService>();

  // Observable properties
  final selectedLanguage = 'English'.obs;
  final isLoading = false.obs;
  final isLoadingUser = true.obs;
  final isLoadingBranches = true.obs;

  // User data - will be populated from MedplumService
  final user = UserModel(
    name: 'Loading...',
    aid: 'Loading...',
    initials: 'L',
  ).obs;

  // Root organizations (edu type) - will be populated from server
  final rootOrganizations = <BranchModel>[].obs;

  // Raw organization data from API
  final rawOrganizations = <Map<String, dynamic>>[].obs;

  // Branches grouped by organization ID
  final branchesByOrg = <String, List<Map<String, dynamic>>>{}.obs;

  // Selected organization for branch display
  final selectedOrganization = Rxn<Map<String, dynamic>>();

  // Track which organization is currently expanded
  final expandedOrganizationId = Rxn<String>(); // Rxn allows null values

  @override
  void onInit() {
    super.onInit();
    //_loadUserData();
    _loadBranches();
  }

  // Load user data from MedplumService
  // Future<void> _loadUserData() async {
  //   try {
  //     isLoadingUser.value = true;

  //     // Get user profile from MedplumService
  //     final userProfile = await _medplumService.getCurrentUserProfile();

  //     if (userProfile != null) {
  //       // Extract user information from profile
  //       final userName = _getUserName(userProfile);
  //       final userEmail = userProfile.user.email;
  //       final initials = _getInitials(userName);

  //       // Update user model
  //       user.value = UserModel(
  //         name: userName,
  //         aid: userEmail, // Using email as identifier for now
  //         initials: initials,
  //       );

  //       print('✅ User data loaded: $userName ($userEmail)');
  //     } else {
  //       // Fallback to default values if no profile available
  //       user.value = UserModel(
  //         name: 'User',
  //         aid: 'No profile available',
  //         initials: 'U',
  //       );
  //       print('⚠️ No user profile available, using default values');
  //     }
  //   } catch (e) {
  //     print('❌ Error loading user data: $e');
  //     // Fallback to default values on error
  //     user.value = UserModel(
  //       name: 'User',
  //       aid: 'Error loading profile',
  //       initials: 'U',
  //     );
  //   } finally {
  //     isLoadingUser.value = false;
  //   }
  // }

  // Load organizations and branches from server
  Future<void> _loadBranches() async {
    try {
      isLoadingBranches.value = true;

      print('🏢 Loading organizations from server...');

      // Get access token from storage
      final accessToken = await _storageService.getAccessToken();

      // Call the new API
      final response = await http.get(
        Uri.parse(
            '${AppConfig.newBackendUrl}/api/organizations'),
        headers: {
          'Content-Type': 'application/json',
          if (accessToken != null) 'Authorization': 'Bearer $accessToken',
        },
      );

      print('📡 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true) {
          final organizations = jsonData['data'] as List<dynamic>;

          // Process organizations and their branches
          final rawOrgData = <Map<String, dynamic>>[];
          final branchesMap = <String, List<Map<String, dynamic>>>{};
          final seenOrgIds = <String>{}; // Track seen organization IDs

          for (final org in organizations) {
            final orgMap = org as Map<String, dynamic>;
            final orgId = orgMap['id'] as String;

            // Skip if we've already processed this organization
            if (seenOrgIds.contains(orgId)) {
              print('⚠️ Skipping duplicate organization: $orgId');
              continue;
            }

            seenOrgIds.add(orgId);
            rawOrgData.add(orgMap);

            // Extract branches for this organization
            final branches = orgMap['branches'] as List<dynamic>? ?? [];
            branchesMap[orgId] =
                branches.map((b) => b as Map<String, dynamic>).toList();
          }

          // Update observables
          rawOrganizations.value = rawOrgData;
          branchesByOrg.value = branchesMap;

          print('✅ Organizations loaded successfully:');
          print('   - Organizations: ${rawOrgData.length}');
          print(
              '   - Unique organizations after deduplication: ${seenOrgIds.length}');
          print(
              '   - Total branches: ${branchesMap.values.expand((b) => b).length}');

          // Count total selectable items (branches + orgs with no branches)
          final orgsWithNoBranches = rawOrgData
              .where((o) =>
                  (branchesMap[o['id']]?.isEmpty ?? true))
              .toList();
          final totalBranches =
              branchesMap.values.expand((b) => b).length;
          final totalSelectable =
              totalBranches + orgsWithNoBranches.length;

          // Save multi-branch flag for UserProfileWidget navigation
          await _storageService.saveHasMultipleBranches(totalSelectable > 1);

          // Auto-select if only 1 selectable item
          if (totalSelectable == 1) {
            isLoadingBranches.value = false;
            if (orgsWithNoBranches.length == 1) {
              // The org itself is the branch
              selectBranch(orgsWithNoBranches.first);
            } else {
              final firstEntry = branchesMap.entries
                  .firstWhere((e) => e.value.isNotEmpty);
              expandedOrganizationId.value = firstEntry.key;
              selectBranch(firstEntry.value.first);
            }
            return;
          }

          // Show success message
          appSnackbar(
            'Success',
            'Loaded ${rawOrgData.length} organizations',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          print('❌ API returned success: false');

          appSnackbar(
            'Error',
            'Failed to load organizations',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          rawOrganizations.value = [];
          branchesByOrg.value = {};
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');

        appSnackbar(
          'Error',
          'Failed to load organizations: HTTP ${response.statusCode}',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        rawOrganizations.value = [];
        branchesByOrg.value = {};
      }
    } catch (e) {
      print('💥 Exception loading organizations: $e');

      appSnackbar(
        'Error',
        'Failed to load organizations: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      rawOrganizations.value = [];
      branchesByOrg.value = {};
    } finally {
      isLoadingBranches.value = false;
    }
  }

  // Extract user name from profile
  String _getUserName(UserProfile profile) {
    if (profile.profile.name.isNotEmpty) {
      final name = profile.profile.name.first;
      final givenNames = name.given.join(' ');
      final familyName = name.family;
      return '$givenNames $familyName'.trim();
    }
    return profile.user.email;
  }

  // Generate initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return 'U';

    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  // Get branches for a specific organization
  List<Map<String, dynamic>> getBranchesForOrganization(String organizationId) {
    return branchesByOrg[organizationId] ?? [];
  }

  // Select an organization to show its branches
  void selectOrganization(Map<String, dynamic> organization) {
    selectedOrganization.value = organization;
    print('🏢 Selected organization: ${organization['name']}');
  }

  /// Toggle organization expansion state, or select directly if no branches
  void toggleOrganization(String organizationId) {
    // If this org has no branches, treat the org itself as the branch
    final branches = getBranchesForOrganization(organizationId);
    if (branches.isEmpty) {
      final org = rawOrganizations.firstWhereOrNull(
        (o) => o['id'] == organizationId,
      );
      if (org != null) {
        print('🏢 Organization has no branches, selecting org directly');
        selectBranch(org);
        return;
      }
    }

    if (expandedOrganizationId.value == organizationId) {
      // If clicking the same organization, collapse it
      expandedOrganizationId.value = null;
      print('🔽 Collapsed organization: $organizationId');
    } else {
      // Otherwise, expand the clicked organization
      expandedOrganizationId.value = organizationId;
      print('🔼 Expanded organization: $organizationId');
    }
  }

  /// Check if an organization is currently expanded
  bool isOrganizationExpanded(String organizationId) {
    return expandedOrganizationId.value == organizationId;
  }

  // Methods
  void changeLanguage(String language) {
    selectedLanguage.value = language;
  }

  // Refresh branches from server
  Future<void> refreshBranches() async {
    await _loadBranches();
  }

  void selectBranch(Map<String, dynamic> branch) async {
    isLoading.value = true;

    try {
      print(
          '🏢 Selecting branch: ${branch['name']} (${branch['accountType']})');

      // Determine if it's a school or clinic based on accountType
      final accountType = branch['accountType'] as String? ?? '';
      final isSchool = accountType.toLowerCase() == 'school';
      final isClinic = accountType.toLowerCase() == 'clinic';

      // Get organization ID — use branch's own id as fallback (when org itself is the branch)
      final organizationId = expandedOrganizationId.value ?? branch['id'] as String? ?? 'unknown';

      // Find the organization name from rawOrganizations
      final org = rawOrganizations.firstWhereOrNull(
        (o) => o['id'] == organizationId,
      );
      final organizationName = org?['name'] ?? branch['name'] ?? '';

      // Prepare branch data with organization info
      final branchData = {
        'id': branch['id'],
        'name': branch['name'],
        'role': branch['accountType'],
        'icon': isSchool ? 'school' : 'clinic',
        'address': branch['address'],
        'phone': branch['phone'],
        'email': null,
        'status': branch['status'],
        'parentId': organizationId,
        'organizationId': organizationId,
        'organizationName': organizationName,
        'isSchool': isSchool,
        'isClinic': isClinic,
        'grades': branch['grades'] is List ? branch['grades'] : [],
        'educationType': branch['educationType'],
        'country': branch['country'],
        'website': branch['website'],
        'isHeadquarters': branch['isHeadquarters'],
        'isAdministrative': branch['isAdministrative'],
        'totalStudents': branch['totalStudents'],
        'totalUsers': branch['totalUsers'],
        'medplumProject': branch['medplumProject'],
        'selected_at': DateTime.now().toIso8601String(),
      };

      // Save selected branch data
      await _storageService.saveBranchSelectedStatus(true);
      await _storageService.saveSelectedBranchData(branchData);

      // Save organization ID separately for easy access
      await _storageService.saveOrganizationId(organizationId);

      // Save organization type flags
      await _storageService.saveIsSchool(isSchool);
      await _storageService.saveIsClinic(isClinic);

      print('💾 Saved to storage:');
      print('   - Organization ID: $organizationId');
      print('   - Is School: $isSchool');
      print('   - Is Clinic: $isClinic');

      isLoading.value = false;

      print('✅ Branch selected successfully: ${branch['name']}');

      // Close any open snackbars to prevent overlay barriers on the new screen
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }

      // If switching branches from HOME (HOME is the previous route),
      // refresh the existing controller and pop back to avoid GetX's
      // route-name-based controller disposal bug with offAllNamed.
      if (Get.previousRoute == Routes.HOME &&
          Get.isRegistered<HomeController>()) {
        try {
          Get.find<HomeController>().resetForBranchSwitch();
        } catch (_) {}
        Get.until((route) => route.settings.name == Routes.HOME);
      } else {
        // First-time login flow: no HOME in stack yet
        Get.offAllNamed(Routes.HOME);
      }
    } catch (e) {
      isLoading.value = false;
      print('❌ Error selecting branch: $e');
      appSnackbar(
        'Error',
        'Failed to select organization: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addNewOrganization() {
    appSnackbar('Info', 'Add new organization feature coming soon');
    Get.toNamed(Routes.CREATE_ORGANIZATION);
  }

  // Logout method
  Future<void> logout() async {
    try {
      // Clear selected branch data
      await _storageService.clearSelectedBranchData();

      // Get the auth controller and call logout
      final AuthController authController = Get.find<AuthController>();
      await authController.logout();
    } catch (e) {
      appSnackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
