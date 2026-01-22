import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/utils/medplum_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/models/user_profile.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../routes/app_pages.dart';

class BranchSelectionController extends GetxController {
  // Services
  final MedplumService _medplumService = Get.find<MedplumService>();
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
    _loadUserData();
    _loadBranches();
  }

  // Load user data from MedplumService
  Future<void> _loadUserData() async {
    try {
      isLoadingUser.value = true;

      // Get user profile from MedplumService
      final userProfile = await _medplumService.getCurrentUserProfile();

      if (userProfile != null) {
        // Extract user information from profile
        final userName = _getUserName(userProfile);
        final userEmail = userProfile.user.email;
        final initials = _getInitials(userName);

        // Update user model
        user.value = UserModel(
          name: userName,
          aid: userEmail, // Using email as identifier for now
          initials: initials,
        );

        print('✅ User data loaded: $userName ($userEmail)');
      } else {
        // Fallback to default values if no profile available
        user.value = UserModel(
          name: 'User',
          aid: 'No profile available',
          initials: 'U',
        );
        print('⚠️ No user profile available, using default values');
      }
    } catch (e) {
      print('❌ Error loading user data: $e');
      // Fallback to default values on error
      user.value = UserModel(
        name: 'User',
        aid: 'Error loading profile',
        initials: 'U',
      );
    } finally {
      isLoadingUser.value = false;
    }
  }

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
            'https://ayamedica-backend.ayamedica.online/api/organizations'),
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

          // Show success message
          Get.snackbar(
            'Success',
            'Loaded ${rawOrgData.length} organizations',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
        } else {
          print('❌ API returned success: false');

          Get.snackbar(
            'Error',
            'Failed to load organizations',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          rawOrganizations.value = [];
          branchesByOrg.value = {};
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');

        Get.snackbar(
          'Error',
          'Failed to load organizations: HTTP ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        rawOrganizations.value = [];
        branchesByOrg.value = {};
      }
    } catch (e) {
      print('💥 Exception loading organizations: $e');

      Get.snackbar(
        'Error',
        'Failed to load organizations: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
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

  /// Toggle organization expansion state
  void toggleOrganization(String organizationId) {
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

      // Get organization ID from the expanded organization
      final organizationId = expandedOrganizationId.value ?? 'unknown';

      // Prepare branch data with organization info
      final branchData = {
        'id': branch['id'],
        'name': branch['name'],
        'role': branch['accountType'],
        'icon': isSchool ? 'school' : 'clinic',
        'address': branch['address'],
        'phone': branch['phone'],
        'email': null, // API doesn't have email
        'status': branch['status'],
        'parentId': organizationId,
        'organizationId': organizationId,
        'isSchool': isSchool,
        'isClinic': isClinic,
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

      // Update HomeController with selected branch data
      try {
        final homeController = Get.find<HomeController>();
        homeController.updateSelectedBranchData(branchData);
        print('✅ Branch data updated in HomeController');
      } catch (e) {
        print(
            '⚠️ HomeController not found, branch data will be loaded on home screen: $e');
      }

      isLoading.value = false;

      // Show success message
      Get.snackbar(
        'Success',
        'Organization ${branch['name']} selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      print('✅ Branch selected successfully: ${branch['name']}');

      // Navigate to home screen after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      isLoading.value = false;
      print('❌ Error selecting branch: $e');
      Get.snackbar(
        'Error',
        'Failed to select organization: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void addNewOrganization() {
    Get.snackbar('Info', 'Add new organization feature coming soon');
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
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
