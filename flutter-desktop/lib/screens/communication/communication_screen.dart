import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/communication_controller.dart';
import 'package:flutter_getx_app/screens/communication/add_message_dialog.dart';
import 'package:flutter_getx_app/screens/communication/communication_datatable.dart';
import 'package:flutter_getx_app/screens/communication/comunication_filter_widget.dart';
import 'package:flutter_getx_app/screens/communication/emptydata.dart';
import 'package:flutter_getx_app/screens/communication/message_detail_page.dart';
import 'package:flutter_getx_app/screens/users/assign_role_screen.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../controllers/users_controller.dart';
import '../../shared/widgets/breadcrumb_widget.dart';

class CommunicationScreen extends GetView<CommunicationController> {
  const CommunicationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              const SizedBox(height: 16),

              // BOUND the table/detail area with Expanded
              Expanded(
                child: Obx(() {
                  if (controller.messages.isEmpty) {
                    return CommunicationEmpty();
                  }
                  final selected = controller.selectedMessage.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: selected == null
                        ? const _UserTableBlock()
                        : MessageDetailPage(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Communication',
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
                BreadcrumbItem(label: 'Communication'),
              ],
            ),
          ],
        ),
        PrimaryButton(
          text: 'New message',
          icon: Icons.add,
          variant: ButtonVariant.primary,
          backgroundColor: const Color(0xFF1339FF),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddMessageDialog(),
            );
          },
        )
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
        'No messages found',
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
        CommunicationFiltersWidget(
          key: ValueKey('communication-filters'),
        ),
        CommunicationDatatable(),
      ],
    );
  }
}

// class _AssignRoleBlock extends StatelessWidget {
//   final dynamic user; // replace dynamic with your UserModel type
//   const _AssignRoleBlock({required this.user, Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<UsersController>();
//     return Column(
//       key: ValueKey('assign-${user.id}'),
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             SvgPicture.asset("assets/svg/arrow-square-left.svg",
//                 width: 32, height: 32),
//             TextButton(
//               onPressed: controller.clearSelection,
//               child: const Text(
//                 'Back to list',
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 16),
//         Text(
//           'Assign Role to ${user.name}',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         const SizedBox(height: 16),
//         const AssignRoleInline(),
//       ],
//     );
//   }
// }
