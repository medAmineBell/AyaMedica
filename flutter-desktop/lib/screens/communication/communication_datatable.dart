import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/communication_controller.dart';
import '../../models/message_model.dart';
import 'paginationtable.dart'; // imports CommunicationPaginationWidget

class CommunicationDatatable extends StatelessWidget {
  const CommunicationDatatable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunicationController>();

    return Obx(() {
      final allMessages = controller.filteredMessages;
      if (allMessages.isEmpty) {
        return Container(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No messages found',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ),
        );
      }

      // Pagination slice
      final page = controller.currentPage.value;
      final perPage = controller.itemsPerPage;
      final start = (page - 1) * perPage;
      final paginated = allMessages.skip(start).take(perPage).toList();

      return Column(
        children: [
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(2),
            },
            children: [
              _buildHeaderRow(),
              ...paginated
                  .map((msg) => _buildDataRow(msg, controller))
                  .toList(),
            ],
          ),

          // pagination controls
          CommunicationPaginationWidget(),
        ],
      );
    });
  }

  TableRow _buildHeaderRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2F5),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _headerCell('From'),
        _headerCell('Date & Time'),
        _headerCell('Subject'),
        _headerCell('Sent by'),
        _headerCell('Actions'),
      ],
    );
  }

  TableRow _buildDataRow(MessageModel msg, CommunicationController controller) {
    final isSelected = controller.selectedMessage.value?.id == msg.id;
    final bgColor = isSelected
        ? const Color.fromARGB(63, 119, 255, 144)
        : Colors.transparent;

    final hasStudent = msg.studentIds.isNotEmpty;
    final name = hasStudent ? msg.studentIds.first.name : '—';
    final avatarLabel =
        (name.length >= 2 ? name.substring(0, 2) : name).toUpperCase();

    return TableRow(
      decoration: BoxDecoration(
        color: bgColor,
        border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      children: [
        _dataCell(
          onTap: () => controller.selectMessage(msg),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    hasStudent ? _colorFromName(name) : Colors.grey,
                child: Text(
                  avatarLabel,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF374151)),
                ),
              ),
            ],
          ),
        ),
        _dataCell(
          onTap: () => controller.selectMessage(msg),
          child: Text(
            '${msg.dateTime!.month}/${msg.dateTime!.day}/${msg.dateTime!.year} '
            'at ${msg.dateTime!.hour.toString().padLeft(2, '0')}:'
            '${msg.dateTime!.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        _dataCell(
          onTap: () => controller.selectMessage(msg),
          child: Text(
            msg.subject,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        _dataCell(
          onTap: () => controller.selectMessage(msg),
          child: Text(
            msg.from,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
        ),
        _dataCell(
          onTap: () => controller.selectMessage(msg),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'View',
                onPressed: () => controller.selectMessage(msg),
                icon: const Icon(Icons.visibility_outlined,
                    size: 18, color: Color(0xFF6B7280)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // IconButton(
              //   tooltip: 'Delete',
              //   onPressed: () {
              //     // your delete logic here
              //   },
              //   icon: const Icon(Icons.delete_outline,
              //       size: 18, color: Colors.red),
              //   padding: EdgeInsets.zero,
              //   constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _headerCell(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280)),
        ),
      );

  Widget _dataCell({
    required VoidCallback onTap,
    required Widget child,
  }) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: child,
        ),
      );

  Color _colorFromName(String name) {
    final hash = name.hashCode;
    final colors = [
      const Color(0xFF1339FF),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
      const Color(0xFFF59E0B),
      const Color(0xFF06B6D4),
    ];
    return colors[hash.abs() % colors.length];
  }
}
