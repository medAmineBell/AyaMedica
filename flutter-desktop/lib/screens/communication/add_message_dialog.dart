import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/create_message_controller.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/custom_dropdown.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

const Color _kActiveBlue = Color(0xFF1339FF);
const Color _kLimeAvatar = Color(0xFFCDFF1F);
const Color _kInactivePill = Color(0xFFF3F2F2);
const Color _kInactiveAvatar = Color(0xFFDCE0E4);
const Color _kFieldBorder = Color(0xFFE5E7EB);
const Color _kSubtle = Color(0xFF9CA3AF);
const Color _kText = Color(0xFF374151);
const Color _kDangerRed = Color(0xFFEF4444);

class AddMessageDialog extends StatefulWidget {
  const AddMessageDialog({super.key});

  @override
  State<AddMessageDialog> createState() => _AddMessageDialogState();
}

class _AddMessageDialogState extends State<AddMessageDialog> {
  late final CreateMessageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(CreateMessageController(), permanent: false);
  }

  @override
  void dispose() {
    Get.delete<CreateMessageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 820),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildAudiencePills(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (controller.selectedMode.value ==
                              MessageAudience.gradeClass) ...[
                            const _SectionLabel('Select Grades and classes'),
                            const SizedBox(height: 12),
                            _buildGradeClassRow(),
                            const SizedBox(height: 20),
                          ],
                          if (controller.selectedMode.value ==
                              MessageAudience.selected) ...[
                            const _SectionLabel('Select student(s)'),
                            const SizedBox(height: 12),
                            _buildGradeClassRow(),
                            const SizedBox(height: 16),
                            _buildStudentsField(context),
                            const SizedBox(height: 12),
                            _buildStudentChips(),
                            const SizedBox(height: 20),
                          ],
                          const _SectionLabel('Message content'),
                          const SizedBox(height: 12),
                          _buildSubjectField(),
                          const SizedBox(height: 12),
                          _buildBodyField(),
                          const SizedBox(height: 12),
                          _buildUploadBox(),
                          const SizedBox(height: 12),
                          _buildAttachmentsList(),
                        ],
                      )),
                ),
              ),
              const SizedBox(height: 16),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create new message',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Create new broadcast or a specific message',
                style: TextStyle(fontSize: 13, color: _kSubtle),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close, size: 18, color: _kText),
          ),
        ),
      ],
    );
  }

  // ─── Audience pills ──────────────────────────────────────────────────
  Widget _buildAudiencePills() {
    return Obx(() => Row(
          children: [
            Expanded(
              child: _AudiencePill(
                label: 'For All students',
                iconAsset: 'assets/svg/users-group.svg',
                fallbackIcon: Icons.groups_rounded,
                isActive:
                    controller.selectedMode.value == MessageAudience.all,
                onTap: () => controller.setMode(MessageAudience.all),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AudiencePill(
                label: 'For a grade or class',
                iconAsset: 'assets/svg/teacher.svg',
                fallbackIcon: Icons.school_rounded,
                isActive: controller.selectedMode.value ==
                    MessageAudience.gradeClass,
                onTap: () => controller.setMode(MessageAudience.gradeClass),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _AudiencePill(
                label: 'For selected student(s)',
                iconAsset: 'assets/svg/user-avatar.svg',
                fallbackIcon: Icons.person_rounded,
                isActive: controller.selectedMode.value ==
                    MessageAudience.selected,
                onTap: () => controller.setMode(MessageAudience.selected),
              ),
            ),
          ],
        ));
  }

  // ─── Grade + Class row ───────────────────────────────────────────────
  Widget _buildGradeClassRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildLabeledField(
            label: 'Grade(s)',
            required: true,
            child: Obx(() => CustomDropdown<String>(
                  hint: 'Grade',
                  value: controller.selectedGrade.value,
                  items: DropdownHelper.createStringItems(
                      controller.grades.toList()),
                  onChanged: (v) => controller.setGrade(v),
                )),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildLabeledField(
            label: 'Class(s)',
            required: true,
            child: Obx(() => CustomDropdown<String>(
                  hint: 'Class name',
                  value: controller.selectedClass.value,
                  items: DropdownHelper.createStringItems(
                      controller.classes.toList()),
                  onChanged: (v) => controller.setClass(v),
                  enabled: controller.selectedGrade.value != null,
                )),
          ),
        ),
      ],
    );
  }

  // ─── Students selector ───────────────────────────────────────────────
  Widget _buildStudentsField(BuildContext context) {
    return _buildLabeledField(
      label: 'Students (Multi selection)',
      required: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openStudentPicker(context),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kFieldBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() {
                  final count = controller.selectedStudents.length;
                  final label = count == 0
                      ? 'All students'
                      : '$count selected';
                  return Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: _kSubtle),
                  );
                }),
              ),
              const Icon(Icons.keyboard_arrow_down,
                  color: _kActiveBlue, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentChips() {
    return Obx(() {
      final selected = controller.selectedStudents;
      if (selected.isEmpty) return const SizedBox.shrink();
      const displayLimit = 4;
      final toShow = selected.length > displayLimit
          ? selected.take(displayLimit).toList()
          : selected.toList();
      final remaining = selected.length - toShow.length;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ...toShow.map((s) => _StudentChip(
                student: s,
                onRemove: () => controller.removeStudent(s),
              )),
          if (remaining > 0) _OverflowChip(count: remaining),
        ],
      );
    });
  }

  Future<void> _openStudentPicker(BuildContext context) async {
    final result = await showDialog<List<Student>>(
      context: context,
      builder: (_) => _StudentPickerDialog(
        initialSelected: controller.selectedStudents.toList(),
      ),
    );
    if (result != null) controller.replaceSelectedStudents(result);
  }

  // ─── Text fields ─────────────────────────────────────────────────────
  Widget _buildSubjectField() {
    return _buildLabeledField(
      label: 'Subject',
      required: true,
      child: TextField(
        controller: controller.subjectController,
        decoration: _inputDecoration('Message subject'),
      ),
    );
  }

  Widget _buildBodyField() {
    return TextField(
      controller: controller.bodyController,
      maxLines: 4,
      decoration: _inputDecoration('Message body'),
    );
  }

  // ─── Upload box ──────────────────────────────────────────────────────
  Widget _buildUploadBox() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: controller.pickAttachments,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _kFieldBorder,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.create_new_folder_outlined,
                  size: 28, color: _kText),
              SizedBox(height: 6),
              Text(
                'Upload file',
                style: TextStyle(
                  color: _kText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Attachments list ────────────────────────────────────────────────
  Widget _buildAttachmentsList() {
    return Obx(() => Column(
          children: [
            for (int i = 0; i < controller.attachments.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              _AttachmentRow(
                file: controller.attachments[i],
                onRemove: () => controller.removeAttachment(i),
              ),
            ],
          ],
        ));
  }

  // ─── Footer ──────────────────────────────────────────────────────────
  Widget _buildFooter(BuildContext context) {
    return Obx(() => Row(
          children: [
            Expanded(
              child: PrimaryButton(
                text: 'Cancel',
                variant: ButtonVariant.outline,
                backgroundColor: Colors.white,
                textColor: _kText,
                onPressed: controller.isSending.value
                    ? null
                    : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PrimaryButton(
                text: controller.isSending.value ? 'Sending...' : 'Send',
                variant: ButtonVariant.primary,
                backgroundColor: _kActiveBlue,
                onPressed: controller.isSending.value
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        final ok = await controller.send();
                        if (!mounted) return;
                        if (ok) navigator.pop();
                      },
              ),
            ),
          ],
        ));
  }

  // ─── Helpers ─────────────────────────────────────────────────────────
  Widget _buildLabeledField({
    required String label,
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              color: _kText,
              fontWeight: FontWeight.w500,
            ),
            children: required
                ? const [
                    TextSpan(
                      text: '*',
                      style: TextStyle(color: _kDangerRed),
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _kSubtle, fontSize: 15),
      filled: true,
      fillColor: const Color(0xFFFBFCFD),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kFieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kFieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kActiveBlue),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _kText,
        ),
      ),
    );
  }
}

class _AudiencePill extends StatelessWidget {
  final String label;
  final String iconAsset;
  final IconData fallbackIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _AudiencePill({
    required this.label,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isActive ? _kActiveBlue : _kInactivePill,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isActive ? _kLimeAvatar : _kInactiveAvatar,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: _buildIcon(),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? Colors.white : const Color(0xFF111827),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SvgPicture.asset(
      iconAsset,
      width: 18,
      height: 18,
      colorFilter: const ColorFilter.mode(
        Color(0xFF1F2937),
        BlendMode.srcIn,
      ),
      placeholderBuilder: (_) =>
          Icon(fallbackIcon, size: 18, color: const Color(0xFF1F2937)),
    );
  }
}

class _StudentChip extends StatelessWidget {
  final Student student;
  final VoidCallback onRemove;
  const _StudentChip({required this.student, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _kFieldBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: student.avatarColor,
            child: Text(
              student.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _kText,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFFF43F5E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 10, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _OverflowChip extends StatelessWidget {
  final int count;
  const _OverflowChip({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: _kActiveBlue,
        shape: BoxShape.circle,
      ),
      child: Text(
        '+$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AttachmentRow extends StatelessWidget {
  final PlatformFile file;
  final VoidCallback onRemove;

  const _AttachmentRow({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final sizeKb = file.bytes != null
        ? (file.bytes!.lengthInBytes / 1024).toStringAsFixed(1)
        : '0';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kFieldBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.folder_rounded,
                size: 18, color: _kText),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$sizeKb KB',
                  style: const TextStyle(fontSize: 11, color: _kSubtle),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFF43F5E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Student picker dialog ───────────────────────────────────────────
class _StudentPickerDialog extends StatefulWidget {
  final List<Student> initialSelected;

  const _StudentPickerDialog({
    required this.initialSelected,
  });

  @override
  State<_StudentPickerDialog> createState() => _StudentPickerDialogState();
}

class _StudentPickerDialogState extends State<_StudentPickerDialog> {
  final CreateMessageController controller =
      Get.find<CreateMessageController>();
  late List<Student> _selected;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = List<Student>.from(widget.initialSelected);
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Student> _currentFiltered() {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return controller.students.toList();
    return controller.students
        .where((s) => s.name.toLowerCase().contains(q))
        .toList();
  }

  void _toggle(Student s) {
    setState(() {
      if (_selected.any((x) => x.id == s.id)) {
        _selected.removeWhere((x) => x.id == s.id);
      } else {
        _selected.add(s);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        width: 500,
        height: 600,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Students',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _kFieldBorder),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  TextButton(
                    onPressed: () => setState(() =>
                        _selected = List<Student>.from(_currentFiltered())),
                    child: const Text('Select All'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => setState(() => _selected.clear()),
                    child: const Text('Clear All'),
                  ),
                  const Spacer(),
                  Text(
                    '${_selected.length} selected',
                    style: const TextStyle(color: _kSubtle, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingStudents.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final filtered = _currentFiltered();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'No students found',
                        style: TextStyle(color: _kSubtle),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final s = filtered[i];
                      final isSelected =
                          _selected.any((x) => x.id == s.id);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: s.avatarColor,
                          child: Text(
                            s.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        title: Text(s.name),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (_) => _toggle(s),
                          activeColor: _kActiveBlue,
                        ),
                        onTap: () => _toggle(s),
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(_selected),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kActiveBlue,
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
