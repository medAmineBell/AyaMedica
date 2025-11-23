import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/branch_model.dart';
import 'package:flutter_getx_app/controllers/auth_controller.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/utils/medplum_service.dart';
import 'package:flutter_getx_app/utils/storage_service.dart';
import 'package:flutter_getx_app/models/user_profile.dart';
import 'package:flutter_getx_app/models/fhir_organization.dart';
import 'package:get/get.dart';

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
  
  // Raw organization data from FHIR API
  final rawOrganizations = <Map<String, dynamic>>[].obs;
  
  // Selected root organization
  final selectedRootOrganization = Rxn<BranchModel>();
  
  // Selected organization for branch display
  final selectedOrganization = Rxn<Map<String, dynamic>>();
  
  // Branch list (children of root organizations) - will be populated from server
  final branches = <BranchModel>[].obs;
  
  // Filtered branches (children of selected root organization)
  final filteredBranches = <BranchModel>[].obs;

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

  // Load branches from server
  Future<void> _loadBranches() async {
    try {
      isLoadingBranches.value = true;
      
      print('🏢 Loading organizations from server...');
      
      // Fetch organizations from MedplumService
      final result = await _medplumService.fetchOrganizations();
      
      if (result['success'] == true) {
        final organizations = result['organizations'] as List<FhirOrganization>;
        
        // Convert all organizations to BranchModel and create branches for each
        final allOrgs = <BranchModel>[];
        final allBranches = <BranchModel>[];
        final rawOrgData = <Map<String, dynamic>>[];
        
        for (final org in organizations) {
          final branchModel = BranchModel.fromFhirOrganization(org);
          allOrgs.add(branchModel);
          
          // Store raw organization data for UserCard
          rawOrgData.add(org.toJson());
          
          // Create branches for each organization (clinic/school)
          final branchesForOrg = _createBranchesForOrganization(branchModel);
          allBranches.addAll(branchesForOrg);
        }
        
        // Update observables
        rootOrganizations.value = allOrgs;
        rawOrganizations.value = rawOrgData;
        branches.value = allBranches;
        
        print('✅ Organizations loaded successfully:');
        print('   - Root organizations: ${allOrgs.length}');
        print('   - Branches: ${allBranches.length}');
        
        // Show success message
        Get.snackbar(
          'Success',
          'Loaded ${allOrgs.length} organizations and ${allBranches.length} branches',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        print('❌ Failed to load organizations: ${result['message']}');
        
        // Show error message
        Get.snackbar(
          'Error',
          'Failed to load organizations: ${result['message']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        
        // Keep empty lists on error
        rootOrganizations.value = [];
        branches.value = [];
      }
    } catch (e) {
      print('💥 Exception loading organizations: $e');
      
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to load organizations: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      
      // Keep empty lists on error
      rootOrganizations.value = [];
      branches.value = [];
    } finally {
      isLoadingBranches.value = false;
    }
  }

  // Create branches for each organization (1 school and 1 clinic)
  List<BranchModel> _createBranchesForOrganization(BranchModel organization) {
    final branches = <BranchModel>[];
    
    // Always create 1 school and 1 clinic for each organization
    branches.addAll([
      // School branch
      BranchModel(
        id: '${organization.id}_school',
        name: '${organization.name} School',
        role: 'School',
        icon: 'school',
        parentId: organization.id,
        address: organization.address,
        phone: organization.phone,
        email: organization.email,
        status: 'active',
      ),
      // Clinic branch
      BranchModel(
        id: '${organization.id}_clinic',
        name: '${organization.name} Clinic',
        role: 'Clinic',
        icon: 'clinic',
        parentId: organization.id,
        address: organization.address,
        phone: organization.phone,
        email: organization.email,
        status: 'active',
      ),
    ]);
    
    return branches;
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

  // Select a root organization
  void selectRootOrganization(BranchModel rootOrg) async {
    selectedRootOrganization.value = rootOrg;
    isLoading.value = true;
    
    try {
      print('🏢 Selecting organization: ${rootOrg.name} (${rootOrg.role})');
      
      // Prepare organization data
      final organizationData = {
        'id': rootOrg.id,
        'name': rootOrg.name,
        'role': rootOrg.role,
        'icon': rootOrg.icon,
        'address': rootOrg.address,
        'phone': rootOrg.phone,
        'email': rootOrg.email,
        'status': rootOrg.status,
        'selected_at': DateTime.now().toIso8601String(),
      };
      
      // Save selected organization data
      await _storageService.saveBranchSelectedStatus(true);
      await _storageService.saveSelectedBranchData(organizationData);
      
      // Update HomeController with selected organization data
      try {
        final homeController = Get.find<HomeController>();
        homeController.updateSelectedBranchData(organizationData);
        print('✅ Organization data updated in HomeController');
      } catch (e) {
        print('⚠️ HomeController not found, organization data will be loaded on home screen: $e');
      }
      
      isLoading.value = false;
      
      // Show success message
      Get.snackbar(
        'Success',
        'Organization ${rootOrg.name} selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      print('✅ Organization selected successfully: ${rootOrg.name}');
      
      // Navigate to home screen after a short delay
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed(Routes.HOME);
      
    } catch (e) {
      isLoading.value = false;
      print('❌ Error selecting organization: $e');
      Get.snackbar(
        'Error',
        'Failed to select organization: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Get branches for a specific organization
  List<BranchModel> getBranchesForOrganization(String organizationId) {
    return branches.where((branch) => branch.parentId == organizationId).toList();
  }
  
  // Get branches grouped by root organization
  Map<String, List<BranchModel>> getBranchesGroupedByRoot() {
    final Map<String, List<BranchModel>> groupedBranches = {};
    
    for (final branch in branches) {
      final parentId = branch.parentId ?? 'no_parent';
      if (!groupedBranches.containsKey(parentId)) {
        groupedBranches[parentId] = [];
      }
      groupedBranches[parentId]!.add(branch);
    }
    
    return groupedBranches;
  }

  // Select an organization to show its branches
  void selectOrganization(Map<String, dynamic> organization) {
    selectedOrganization.value = organization;
    print('🏢 Selected organization: ${organization['name']}');
  }
  
  // Methods
  void changeLanguage(String language) {
    selectedLanguage.value = language;
  }

  // Refresh branches from server
  Future<void> refreshBranches() async {
    await _loadBranches();
  }

  void selectBranch(BranchModel branch) async {
    isLoading.value = true;
    
    try {
      print('🏢 Selecting branch: ${branch.name} (${branch.role})');
      
      // Determine if it's a school or clinic
      final isSchool = branch.role.toLowerCase() == 'school';
      final isClinic = branch.role.toLowerCase() == 'clinic';
      
      // Get organization ID from parent
      final organizationId = branch.parentId ?? 'unknown';
      
      // Prepare branch data with organization info
      final branchData = {
        'id': branch.id,
        'name': branch.name,
        'role': branch.role,
        'icon': branch.icon,
        'address': branch.address,
        'phone': branch.phone,
        'email': branch.email,
        'status': branch.status,
        'parentId': branch.parentId,
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
        print('⚠️ HomeController not found, branch data will be loaded on home screen: $e');
      }
      
      isLoading.value = false;
      
      // Show success message
      Get.snackbar(
        'Success',
        'Organization ${branch.name} selected',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      
      print('✅ Branch selected successfully: ${branch.name}');
      
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
