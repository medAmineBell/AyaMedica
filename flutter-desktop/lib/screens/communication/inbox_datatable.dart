import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/communication_controller.dart';
import '../../models/message_model.dart';
import 'paginationtable.dart';

class InboxDatatable extends StatelessWidget {
  const InboxDatatable({Key? key}) : super(key: key);

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
          _buildHeaderRow(),
          ...allMessages
              .map((msg) => _InboxRow(msg: msg, controller: controller)),
          const CommunicationPaginationWidget(),
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
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('From', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Date & time', style: _headerStyle)),
          Expanded(flex: 3, child: Text('Subject', style: _headerStyle)),
          Expanded(flex: 2, child: Text('Sent by', style: _headerStyle)),
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

class _InboxRow extends StatefulWidget {
  final MessageModel msg;
  final CommunicationController controller;

  const _InboxRow({required this.msg, required this.controller});

  @override
  State<_InboxRow> createState() => _InboxRowState();
}

class _InboxRowState extends State<_InboxRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final controller = widget.controller;
    final isUnread = !msg.read;
    final isSentTab = controller.selectedType.value == 'sent';

    final studentName = (msg.patientName?.isNotEmpty == true)
        ? msg.patientName!
        : (msg.destinationLabel?.isNotEmpty == true
            ? msg.destinationLabel!
            : 'Student name here');

    final gradeClass = [msg.studentGrade, msg.studentClass]
        .where((s) => s != null && s.toString().isNotEmpty)
        .join(' - ');
    final gradeClassLabel = gradeClass.isNotEmpty
        ? gradeClass
        : (msg.branchName?.isNotEmpty == true
            ? msg.branchName!
            : 'Grade & Class');

    final dateStr = msg.createdAt != null
        ? DateFormat("MM/dd/yyyy 'at' hh:mm a").format(msg.createdAt!)
        : '';

    final sentBy = msg.senderName ?? msg.from;

    Color bgColor;
    if (isUnread) {
      bgColor = _isHovered
          ? const Color(0x2610B981)
          : const Color(0x1A10B981);
    } else {
      bgColor = _isHovered ? const Color(0xFFF9FAFB) : Colors.transparent;
    }

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
              bottom: BorderSide(color: Color(0xFFE5E7EB)),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    _StudentAvatar(photoUrl: msg.studentPhoto, name: studentName),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  studentName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                              ),
                              if (isUnread && !isSentTab) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'New',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            gradeClassLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  msg.subject,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  sentBy,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  tooltip: 'View',
                  onPressed: () => controller.selectMessage(msg),
                  icon: SvgPicture.asset(
                    'assets/svg/view.svg',
                    width: 18,
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                        Color(0xFF6B7280), BlendMode.srcIn),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  final String? photoUrl;
  final String name;

  const _StudentAvatar({required this.photoUrl, required this.name});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: 18,
      backgroundColor: const Color(0xFF2F6BFF),
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      onBackgroundImageError: hasPhoto ? (_, __) {} : null,
      child: hasPhoto
          ? null
          : const Icon(Icons.person, color: Colors.white, size: 18),
    );
  }
}
