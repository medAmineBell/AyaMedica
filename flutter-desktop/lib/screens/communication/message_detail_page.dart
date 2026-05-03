import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../controllers/communication_controller.dart';
import '../../models/message_model.dart';
import '../appointmentScheduling/widgets/create_appointment_dialog.dart';

class MessageDetailPage extends StatelessWidget {
  const MessageDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CommunicationController>();

    return Obx(() {
      final msg = controller.selectedMessage.value;
      if (msg == null) return const SizedBox.shrink();

      final isSent = controller.selectedType.value == 'sent';

      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(controller, isSent: isSent),
              const SizedBox(height: 24),
              _buildSenderCard(msg),
              const SizedBox(height: 16),
              _buildMetaRow(msg, isSent: isSent),
              const SizedBox(height: 24),
              Text(
                msg.subject.isEmpty ? 'Message' : msg.subject,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                msg.messageBody,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: Color(0xFF374151),
                ),
              ),
              if (msg.messageAttachments.isNotEmpty) ...[
                const SizedBox(height: 32),
                const Text(
                  'Attachments',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: msg.messageAttachments
                      .asMap()
                      .entries
                      .map((e) => _buildAttachmentCard(e.key, e.value))
                      .toList(),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTopBar(CommunicationController controller,
      {required bool isSent}) {
    return Row(
      children: [
        InkWell(
          onTap: () => controller.selectedMessage.value = null,
          child: Row(
            children: [
              const Icon(Icons.arrow_back, color: Color(0xFF111827)),
              const SizedBox(width: 8),
              Text(
                isSent ? 'Back to sent' : 'Back to inbox',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (!isSent)
          ElevatedButton.icon(
            onPressed: () => _openCreateAppointment(controller),
            icon: const Icon(
              Icons.add,
              size: 18,
              color: Colors.white,
            ),
            label: const Text('Create appointment'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1339FF),
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
      ],
    );
  }

  void _openCreateAppointment(CommunicationController controller) {
    final msg = controller.selectedMessage.value;
    final aid = msg?.studentAid;
    showDialog(
      context: Get.context!,
      builder: (_) => CreateAppointmentDialog(prefillAid: aid),
    );
  }

  Widget _buildSenderCard(MessageModel msg) {
    final studentName = (msg.patientName?.isNotEmpty == true)
        ? msg.patientName!
        : (msg.destinationLabel?.isNotEmpty == true
            ? msg.destinationLabel!
            : (msg.senderName?.isNotEmpty == true
                ? msg.senderName!
                : (msg.from.isNotEmpty ? msg.from : '—')));
    final initials = _initials(studentName);
    final timeLabel = _formatHeaderTime(msg.createdAt);

    final gradeClass = [msg.studentGrade, msg.studentClass]
        .where((s) => s != null && s.toString().isNotEmpty)
        .join(' - ');
    final gradeClassLabel = gradeClass.isNotEmpty
        ? gradeClass
        : (msg.branchName?.isNotEmpty == true ? msg.branchName! : '—');

    final hasPhoto = msg.studentPhoto != null && msg.studentPhoto!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xFFE3B341),
          backgroundImage: hasPhoto ? NetworkImage(msg.studentPhoto!) : null,
          onBackgroundImageError: hasPhoto ? (_, __) {} : null,
          child: hasPhoto
              ? null
              : Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                gradeClassLabel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        Text(
          timeLabel,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(MessageModel msg, {required bool isSent}) {
    final sender = msg.senderName ?? msg.from;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            isSent ? 'From' : 'Sent by',
            style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(width: 8),
          Text(
            sender,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          if (!isSent) ...[
            const SizedBox(width: 32),
            const Text(
              'First guardian',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachmentCard(int index, MessageAttachment attachment) {
    final fullUrl = _resolveAttachmentUrl(attachment.url);
    final isImage = attachment.isImage;
    final ext = (attachment.filename ?? attachment.url).split('.').last;
    final fileType =
        isImage ? '${ext.toUpperCase()} file' : '${ext.toUpperCase()} file';
    final title =
        attachment.filename?.isNotEmpty == true
            ? attachment.filename!
            : 'File ${index + 1}';

    return InkWell(
      onTap: () =>
          _showAttachmentDialog(Get.context!, fullUrl, isImage, title),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      fileType,
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF6B7280)),
                    ),
                  ),
                ],
              ),
            ),
            if (isImage)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(7),
                  bottomRight: Radius.circular(7),
                ),
                child: Image.network(
                  fullUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120,
                    color: const Color(0xFFE5E7EB),
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentDialog(
      BuildContext context, String url, bool isImage, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  border:
                      Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: isImage
                    ? InteractiveViewer(
                        child: Image.network(
                          url,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.broken_image_outlined,
                                      size: 48, color: Color(0xFF9CA3AF)),
                                  SizedBox(height: 8),
                                  Text('Failed to load image',
                                      style: TextStyle(
                                          color: Color(0xFF6B7280))),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.picture_as_pdf,
                                  size: 64, color: Color(0xFFEF4444)),
                              const SizedBox(height: 16),
                              const Text('File Preview',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              SelectableText(url,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _resolveAttachmentUrl(String raw) {
    if (raw.isEmpty) return raw;
    if (raw.startsWith('http')) return raw;
    if (raw.startsWith('gcs:')) {
      return '${AppConfig.newBackendUrl}/api/files/gcs/${raw.substring(4)}';
    }
    return '${AppConfig.newBackendUrl}${raw.startsWith('/') ? '' : '/'}$raw';
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '—';
    if (parts.length == 1) {
      final p = parts.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  static String _formatHeaderTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    if (isToday) {
      return "Today at ${DateFormat('hh:mm a').format(dt)}";
    }
    return DateFormat("MMM d, yyyy 'at' hh:mm a").format(dt);
  }
}
