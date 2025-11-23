import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/branch_model.dart';

enum BranchState { loading, success, error, empty }

class BranchManagementController extends GetxController {
  final RxList<BranchModel> branches = <BranchModel>[].obs;
  final Rx<BranchState> state = BranchState.loading.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final Rx<BranchModel> selectedBranch =
      BranchModel(name: '', role: '', icon: '').obs;
  @override
  void onInit() {
    super.onInit();
    fetchBranches();
  }

  Future<void> deactivateBranch(String branchId) async {
    try {
      isLoading.value = true;

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Find branch and update status to 'inactive'
      final index = branches.indexWhere((b) => b.id == branchId);
      if (index != -1) {
        final updated = branches[index].copyWith(status: 'inactive');
        branches[index] = updated;
      }

      Get.snackbar(
        'Success',
        'Branch deactivated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFFC107), // amber
        colorText: Colors.black,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to deactivate branch: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activateBranch(String branchId) async {
    try {
      isLoading.value = true;

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // Find branch and update status to 'active'
      final index = branches.indexWhere((b) => b.id == branchId);
      if (index != -1) {
        final updated = branches[index].copyWith(status: 'active');
        branches[index] = updated;
      }

      Get.snackbar(
        'Success',
        'Branch activated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50), // green
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to activate branch: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBranches() async {
    try {
      state.value = BranchState.loading;
      isLoading.value = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock data - replace with actual API call
      final mockBranches = [
        BranchModel(
          id: '1',
          name: 'Al Riyadh Campus',
          role: 'Branch Admin',
          icon: 'clinic',
          address: '123 King Fahd Road, Riyadh',
          phone: '+966-11-123-4567',
          email: 'riyadh@school.edu.sa',
          principalName: 'Ahmed Al-Sayed',
          studentCount: 1250,
          teacherCount: 85,
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
        ),
        BranchModel(
          id: '2',
          name: 'Jeddah Campus',
          role: 'Branch Admin',
          icon: 'clinic',
          address: '456 Corniche Road, Jeddah',
          phone: '+966-12-987-6543',
          email: 'jeddah@school.edu.sa',
          principalName: 'Fatima Al-Zahra',
          studentCount: 980,
          teacherCount: 65,
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
        ),
        BranchModel(
          id: '3',
          name: 'Dammam Campus',
          role: 'Branch Admin',
          icon: 'clinic',
          address: '789 King Abdullah Road, Dammam',
          phone: '+966-13-555-1234',
          email: 'dammam@school.edu.sa',
          principalName: 'Omar Al-Rashid',
          studentCount: 750,
          teacherCount: 45,
          status: 'active',
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
        ),
      ];

      branches.value = mockBranches;

      if (branches.isEmpty) {
        state.value = BranchState.empty;
      } else {
        state.value = BranchState.success;
      }
    } catch (e) {
      state.value = BranchState.error;
      errorMessage.value = 'Failed to load branches: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBranch(BranchModel branch) async {
    try {
      isLoading.value = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Add new branch to the list
      branches.add(branch);

      Get.snackbar(
        'Success',
        'Branch added successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add branch: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateBranch(BranchModel branch) async {
    try {
      isLoading.value = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Find and update the branch
      final index = branches.indexWhere((b) => b.id == branch.id);
      if (index != -1) {
        branches[index] = branch;
      }

      Get.snackbar(
        'Success',
        'Branch updated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update branch: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteBranch(String branchId) async {
    try {
      isLoading.value = true;

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Remove branch from the list
      branches.removeWhere((branch) => branch.id == branchId);

      Get.snackbar(
        'Success',
        'Branch deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF4CAF50),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete branch: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFF44336),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void refreshBranches() {
    fetchBranches();
  }

  void clearError() {
    errorMessage.value = '';
    state.value = BranchState.loading;
  }
}
