import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/userAppItem.dart';
import 'package:flutter_getx_app/shared/widgets/dynamic_table_widget.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../controllers/mobile_app_user_controller.dart';

class StatusColor {
  final Color bg;
  final Color text;
  const StatusColor(this.bg, this.text);
}

class DeliveryColor {
  final Color bg;
  final Color text;
  const DeliveryColor(this.bg, this.text);
}

class MobileAppUserAppScreen extends StatelessWidget {
  const MobileAppUserAppScreen({super.key});

  Widget _guardianWithStatus(Guardian g) {
    final isEmpty = g.name.trim() == '--' || g.name.isEmpty;
    return isEmpty
        ? const Text('-- --')
        : Row(
            children: [
              Text(
                g.name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: g.status == 'Unverified' ? Colors.grey : Colors.black,
                ),
              ),
              const SizedBox(width: 6),
              TableCellHelpers.badgeCell(
                g.status,
                backgroundColor: _statusColor(g.status).bg,
                textColor: _statusColor(g.status).text,
              ),
            ],
          );
  }

  StatusColor _statusColor(String status) {
    switch (status) {
      case 'Active':
        return StatusColor(Color(0xFFE6FAEB), Color(0xFF1BA94C));
      case 'Inactive':
        return StatusColor(Color(0xFFFFE6EB), Color(0xFFEB2F2F));
      case 'Offline':
        return StatusColor(Color(0xFFFFE6EB), Color(0xFFEB2F2F));
      case 'Unverified':
        return StatusColor(Color(0xFFE6E7EA), Color(0xFF747677));
      default:
        return StatusColor(Color(0xFFE6E7EA), Color(0xFF747677));
    }
  }

  DeliveryColor _deliveryColor(String status) {
    switch (status) {
      case 'Sent':
        return DeliveryColor(Color(0xFFE8F3FF), Color(0xFF1463FF));
      case 'Delivered':
        return DeliveryColor(Color(0xFFE6FAEB), Color(0xFF1BA94C));
      case 'Failed':
        return DeliveryColor(Color(0xFFFFE6EB), Color(0xFFEB2F2F));
      default:
        return DeliveryColor(Color(0xFFE6E7EA), Color(0xFF747677));
    }
  }
void _showEmailReminderDialog(BuildContext context, MobileAppUserController controller) {
  if (controller.users.isEmpty) {
    Get.snackbar('No Users', 'There are no users to send reminders to.',
        snackPosition: SnackPosition.BOTTOM);
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send Email Reminder',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to send an email reminder to all pending parents?',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF747677),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Obx(() => DynamicTableWidget<UserAppItem>(
                      items: controller.users.toList(),
                      columns: [
 TableColumnConfig<UserAppItem>(
    header: 'Student full name',
    columnWidth: const FlexColumnWidth(3),
    cellBuilder: (item, index) => Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF007AFF),
          child: Text(
            item.initials,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(item.classGroup, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    ),
  ),

  // First Guardian
  TableColumnConfig<UserAppItem>(
    header: 'First Guardian',
    columnWidth: const FlexColumnWidth(2),
    cellBuilder: (item, index) => _guardianWithStatus(item.firstGuardian),
  ),

  // First Guardian Phone
  TableColumnConfig<UserAppItem>(
    header: 'First Guardian phone number',
    cellBuilder: (item, index) => Text(item.firstGuardian.phone),
  ),

  // First Guardian Email
  TableColumnConfig<UserAppItem>(
    header: 'First Guardian email',
    cellBuilder: (item, index) => Text(item.firstGuardian.email),
  ),

  // Second Guardian
  TableColumnConfig<UserAppItem>(
    header: 'Second Guardian',
    columnWidth: const FlexColumnWidth(2),
    cellBuilder: (item, index) => _guardianWithStatus(item.secondGuardian),
  ),

  // Second Guardian Phone
  TableColumnConfig<UserAppItem>(
    header: 'Second Guardian phone number',
    cellBuilder: (item, index) => Text(item.secondGuardian.phone),
  ),

  // Second Guardian Email
  TableColumnConfig<UserAppItem>(
    header: 'Second Guardian email',
    cellBuilder: (item, index) => Text(item.secondGuardian.email),
  ),

  // Second Guardian Delivery Status
  TableColumnConfig<UserAppItem>(
    header: 'Delivery Status',
    cellBuilder: (item, index) => TableCellHelpers.badgeCell(
      item.secondGuardian.deliveryStatus,
      backgroundColor: _deliveryColor(item.secondGuardian.deliveryStatus).bg,
      textColor: _deliveryColor(item.secondGuardian.deliveryStatus).text,
    ),
  ), ],
                    )),
              ),
              const SizedBox(height: 32),

              // 🔹 Email preview box
              Container(
                width: double.infinity,
                height: 267,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0xFFFBFCFD),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE9E9E9),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  shadows: [
                    BoxShadow(
                      color: const Color(0x0C101828),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        'Email subject: Join ayamedica today',
                        style: TextStyle(
                          color: Color(0xFFA6A9AC),
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          height: 1.43,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'Dear {user name}\n\nWe hope this email finds you well,\nWe would like to invite you to activate your ayamedica account through ',
                            style: TextStyle(
                              color: Color(0xFFA6A9AC),
                              fontSize: 16,
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          TextSpan(
                            text: 'this link, \n',
                            style: TextStyle(
                              color: Color(0xFF1339FF),
                              fontSize: 16,
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                          TextSpan(
                            text: 'Thank you, \n\nAyamedica team',
                            style: TextStyle(
                              color: Color(0xFFA6A9AC),
                              fontSize: 16,
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w400,
                              height: 1.50,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 🔹 Footer with full-width Send button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Color(0xFF747677)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // controller.sendEmailReminders();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1339FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

@override
  Widget build(BuildContext context) {
    final controller = Get.put(MobileAppUserController());
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search + Buttons Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'search',
                      prefixIcon: const Icon(Icons.search),
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF1339FF)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 40,
                  width: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Color(0xffA6A9AC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: SvgPicture.asset('assets/svg/download.svg',
                        color: Colors.grey),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 44,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  clipBehavior: Clip.antiAlias,
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 1,
                        color: Color(0xFFA6A9AC),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.tune,
                          size: 20, color: Color(0xFF747677)),
                      const SizedBox(width: 8),
                      const Text(
                        'Filters',
                        style: TextStyle(
                          color: Color(0xFF747677),
                          fontSize: 14,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w500,
                          height: 1.43,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 44,
                  child: ElevatedButton.icon(
onPressed: () => _showEmailReminderDialog(context, controller),
                    icon: const Icon(Icons.notifications,
                        size: 24, color: Color(0xFFCDF7FF)),
                    label: const Text(
                      'Send email reminder',
                      style: TextStyle(
                        color: Color(0xFFCDF7FF),
                        fontSize: 14,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.28,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1339FF),
                      foregroundColor: const Color(0xFFCDF7FF),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w500,
                        height: 1.43,
                        letterSpacing: 0.28,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 1,
                      shadowColor: const Color(0x0C101828),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 24),

            // Dynamic table
            Expanded(
              child: Obx(() =>
                  DynamicTableWidget<UserAppItem>(
                    items: controller.users.toList(),
                    columns: [
                    TableColumnConfig<UserAppItem>(
    header: 'Student full name',
    columnWidth: const FlexColumnWidth(3),
    cellBuilder: (item, index) => Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF007AFF),
          child: Text(
            item.initials,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(item.classGroup, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    ),
  ),

  // First Guardian
  TableColumnConfig<UserAppItem>(
    header: 'First Guardian',
    columnWidth: const FlexColumnWidth(2),
    cellBuilder: (item, index) => _guardianWithStatus(item.firstGuardian),
  ),

  // First Guardian Phone
  TableColumnConfig<UserAppItem>(
    header: 'First Guardian phone number',
    cellBuilder: (item, index) => Text(item.firstGuardian.phone),
  ),

  // First Guardian Email
  TableColumnConfig<UserAppItem>(
    header: 'First Guardian email',
    cellBuilder: (item, index) => Text(item.firstGuardian.email),
  ),

  // Second Guardian
  TableColumnConfig<UserAppItem>(
    header: 'Second Guardian',
    columnWidth: const FlexColumnWidth(2),
    cellBuilder: (item, index) => _guardianWithStatus(item.secondGuardian),
  ),

  // Second Guardian Phone
  TableColumnConfig<UserAppItem>(
    header: 'Second Guardian phone number',
    cellBuilder: (item, index) => Text(item.secondGuardian.phone),
  ),

  // Second Guardian Email
  TableColumnConfig<UserAppItem>(
    header: 'Second Guardian email',
    cellBuilder: (item, index) => Text(item.secondGuardian.email),
  ),

  // Second Guardian Delivery Status
  TableColumnConfig<UserAppItem>(
    header: 'Delivery Status',
    cellBuilder: (item, index) => TableCellHelpers.badgeCell(
      item.secondGuardian.deliveryStatus,
      backgroundColor: _deliveryColor(item.secondGuardian.deliveryStatus).bg,
      textColor: _deliveryColor(item.secondGuardian.deliveryStatus).text,
    ),
  ),
                    ],
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}