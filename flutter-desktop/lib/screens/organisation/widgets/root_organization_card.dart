// import 'package:flutter/material.dart';
// import 'package:flutter_getx_app/controllers/branch_selection_controller.dart';
// import 'package:flutter_getx_app/models/branch_model.dart';
// import 'package:get/get.dart';

// class RootOrganizationCard extends StatelessWidget {
//   final BranchSelectionController controller = Get.find();

//   RootOrganizationCard({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.isLoadingBranches.value) {
//         return _buildLoadingCard();
//       }
      
//       if (controller.rootOrganizations.isEmpty) {
//         return _buildEmptyCard();
//       }
      
//       return _buildRootOrganizationsList();
//     });
//   }

//   Widget _buildLoadingCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: ShapeDecoration(
//         color: const Color(0xFF1339FF),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(32),
//         ),
//       ),
//       child: Row(
//         children: Get.locale?.languageCode == 'ar' ? [
//           _buildLogoutButton(),
//           const SizedBox(width: 12),
//           Expanded(child: _buildLoadingContent()),
//           const SizedBox(width: 12),
//           _buildLoadingAvatar(),
//         ] : [
//           _buildLoadingAvatar(),
//           const SizedBox(width: 12),
//           Expanded(child: _buildLoadingContent()),
//           const SizedBox(width: 12),
//           _buildLogoutButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptyCard() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: ShapeDecoration(
//         color: const Color(0xFF1339FF),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(32),
//         ),
//       ),
//       child: Row(
//         children: Get.locale?.languageCode == 'ar' ? [
//           _buildLogoutButton(),
//           const SizedBox(width: 12),
//           Expanded(child: _buildEmptyContent()),
//           const SizedBox(width: 12),
//           _buildEmptyAvatar(),
//         ] : [
//           _buildEmptyAvatar(),
//           const SizedBox(width: 12),
//           Expanded(child: _buildEmptyContent()),
//           const SizedBox(width: 12),
//           _buildLogoutButton(),
//         ],
//       ),
//     );
//   }

//   Widget _buildRootOrganizationsList() {
//     return Column(
//       children: controller.rootOrganizations.map((org) {
//         final isSelected = controller.selectedRootOrganization.value?.id == org.id;
        
//         return GestureDetector(
//           onTap: () => controller.selectRootOrganization(org),
//           child: Container(
//             width: double.infinity,
//             margin: const EdgeInsets.only(bottom: 8),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: ShapeDecoration(
//               color: isSelected ? const Color(0xFF0A2ECC) : const Color(0xFF1339FF),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(32),
//                 side: isSelected 
//                     ? const BorderSide(color: Color(0xFFCDFF1F), width: 2)
//                     : BorderSide.none,
//               ),
//             ),
//             child: Row(
//               children: Get.locale?.languageCode == 'ar' ? [
//                 _buildLogoutButton(),
//                 const SizedBox(width: 12),
//                 Expanded(child: _buildOrganizationInfo(org, isSelected)),
//                 const SizedBox(width: 12),
//                 _buildOrganizationAvatar(org, isSelected),
//               ] : [
//                 _buildOrganizationAvatar(org, isSelected),
//                 const SizedBox(width: 12),
//                 Expanded(child: _buildOrganizationInfo(org, isSelected)),
//                 const SizedBox(width: 12),
//                 _buildLogoutButton(),
//               ],
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }

//   Widget _buildLoadingAvatar() {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: const ShapeDecoration(
//         color: Color(0xFFCDFF1F),
//         shape: OvalBorder(),
//       ),
//       child: const Center(
//         child: SizedBox(
//           width: 16,
//           height: 16,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1339FF)),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyAvatar() {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: const ShapeDecoration(
//         color: Color(0xFFCDFF1F),
//         shape: OvalBorder(),
//       ),
//       child: const Center(
//         child: Icon(
//           Icons.business,
//           color: Color(0xFF1339FF),
//           size: 20,
//         ),
//       ),
//     );
//   }

//   Widget _buildOrganizationAvatar(BranchModel org, bool isSelected) {
//     return Container(
//       width: 40,
//       height: 40,
//       decoration: ShapeDecoration(
//         color: isSelected ? const Color(0xFFCDFF1F) : const Color(0xFFCDFF1F),
//         shape: const OvalBorder(),
//       ),
//       child: Center(
//         child: Text(
//           org.name.isNotEmpty ? org.name[0].toUpperCase() : 'O',
//           style: TextStyle(
//             color: isSelected ? const Color(0xFF0A2ECC) : const Color(0xFF1339FF),
//             fontSize: 16,
//             fontFamily: 'IBM Plex Sans Arabic',
//             fontWeight: FontWeight.w700,
//             height: 1.43,
//             letterSpacing: 0.28,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           height: 16,
//           width: 120,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.3),
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           height: 13,
//           width: 80,
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.2),
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildEmptyContent() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'No Organizations',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 16,
//             fontFamily: 'IBM Plex Sans Arabic',
//             fontWeight: FontWeight.w600,
//             height: 1.43,
//             letterSpacing: 0.28,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           'No root organizations available',
//           style: const TextStyle(
//             color: Color(0xFFE4E9ED),
//             fontSize: 13,
//             fontFamily: 'IBM Plex Sans Arabic',
//             fontWeight: FontWeight.w400,
//             height: 1.33,
//             letterSpacing: 0.36,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildOrganizationInfo(BranchModel org, bool isSelected) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           org.name,
//           style: TextStyle(
//             color: isSelected ? const Color(0xFFCDFF1F) : Colors.white,
//             fontSize: 16,
//             fontFamily: 'IBM Plex Sans Arabic',
//             fontWeight: FontWeight.w600,
//             height: 1.43,
//             letterSpacing: 0.28,
//           ),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           org.role,
//           style: TextStyle(
//             color: isSelected ? const Color(0xFFE4E9ED) : const Color(0xFFE4E9ED),
//             fontSize: 13,
//             fontFamily: 'IBM Plex Sans Arabic',
//             fontWeight: FontWeight.w400,
//             height: 1.33,
//             letterSpacing: 0.36,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLogoutButton() {
//     return Tooltip(
//       message: 'logout'.tr,
//       child: GestureDetector(
//         onTap: () => _showLogoutDialog(),
//         child: Container(
//           width: 32,
//           height: 32,
//           decoration: const ShapeDecoration(
//             color: Color(0x1AFFFFFF), // 10% white opacity
//             shape: OvalBorder(),
//           ),
//           child: const Icon(
//             Icons.logout,
//             color: Colors.white,
//             size: 16,
//           ),
//         ),
//       ),
//     );
//   }

//   void _showLogoutDialog() {
//     Get.dialog(
//       AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         title: Row(
//           children: [
//             Container(
//               width: 40,
//               height: 40,
//               decoration: const BoxDecoration(
//                 color: Color(0xFFFFE6E6),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.logout,
//                 color: Colors.red,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               'logout_confirmation_title'.tr,
//               style: const TextStyle(
//                 fontFamily: 'IBM Plex Sans Arabic',
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//               ),
//             ),
//           ],
//         ),
//         content: Text(
//           'logout_confirmation_message'.tr,
//           style: const TextStyle(
//             fontFamily: 'IBM Plex Sans Arabic',
//             fontWeight: FontWeight.w400,
//             fontSize: 14,
//             height: 1.4,
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//             ),
//             child: Text(
//               'cancel'.tr,
//               style: const TextStyle(
//                 fontFamily: 'IBM Plex Sans Arabic',
//                 color: Colors.grey,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               controller.logout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(6),
//               ),
//             ),
//             child: Text(
//               'logout'.tr,
//               style: const TextStyle(
//                 fontFamily: 'IBM Plex Sans Arabic',
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
