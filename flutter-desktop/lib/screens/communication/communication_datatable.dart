import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/communication_controller.dart';
import '../../models/message_model.dart';
import 'paginationtable.dart';

class CommunicationDatatable extends StatelessWidget {
  const CommunicationDatatable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunicationController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final allMessages = controller.filteredMessages;
      if (allMessages.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: const Center(
            child: Text(
              'No messages found',
              style: TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
            ),
          ),
        );
      }

      return Column(
        children: [
          // Header row
          _buildHeaderRow(),
          // Data rows
          ...allMessages.map((msg) => _DataRow(msg: msg, controller: controller)),
          CommunicationPaginationWidget(),
        ],
      );
    });
  }

  Widget _buildHeaderRow() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F2F5),
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('From', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Date & time', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Source', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Speciality', style: _headerStyle)),
          Expanded(flex: 1, child: Text('Actions', style: _headerStyle)),
        ],
      ),
    );
  }

  static const _headerStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF6B7280),
  );
}

class _DataRow extends StatefulWidget {
  final MessageModel msg;
  final CommunicationController controller;

  const _DataRow({required this.msg, required this.controller});

  @override
  State<_DataRow> createState() => _DataRowState();
}

class _DataRowState extends State<_DataRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final controller = widget.controller;
    final isSelected = controller.selectedMessage.value?.id == msg.id;

    final name = msg.patientName ?? msg.from;
    final avatarLabel =
        (name.length >= 2 ? name.substring(0, 2) : name).toUpperCase();

    // Format date
    String dateStr = '';
    if (msg.dateTime != null) {
      final d = msg.dateTime!;
      final hour = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
      final amPm = d.hour >= 12 ? 'PM' : 'AM';
      dateStr =
          '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year} '
          'at ${hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} $amPm';
    }

    final sourceName = msg.senderName ?? '';

    final bgColor = isSelected
        ? const Color.fromARGB(63, 119, 255, 144)
        : _isHovered
            ? const Color(0xFFF9FAFB)
            : Colors.transparent;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => controller.selectMessage(msg),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            border: const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // From
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _colorFromName(name),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151)),
                          ),
                          if (msg.studentGrade != null || msg.studentClass != null)
                            Text(
                              [msg.studentGrade, msg.studentClass]
                                  .where((s) => s != null && s.isNotEmpty)
                                  .join(' | '),
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF6B7280)),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Date & time
              Expanded(
                flex: 2,
                child: Text(
                  dateStr,
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ),
              // Source
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_android,
                      size: 16,
                      color: Color(0xFF6B7280),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        sourceName,
                        style: const TextStyle(
                            fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                    ),
                  ],
                ),
              ),
              // Speciality
              Expanded(
                flex: 2,
                child: Text(
                  msg.category ?? '',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ),
              // Actions
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.visibility_outlined,
                  size: 18,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
