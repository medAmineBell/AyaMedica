import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/oneroster_import_controller.dart';
import 'package:flutter_getx_app/shared/widgets/primary_button.dart';
import 'package:get/get.dart';

class OneRosterImportScreen extends StatelessWidget {
  const OneRosterImportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OneRosterImportController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(),
                      const SizedBox(height: 24),
                      _OrganizationField(controller: controller),
                      const SizedBox(height: 20),
                      _FilePickerSection(controller: controller),
                      const SizedBox(height: 16),
                      _DryRunToggle(controller: controller),
                      const SizedBox(height: 24),
                      _ActionButtons(controller: controller),
                      const SizedBox(height: 16),
                      _ResultPanel(controller: controller),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Import OneRoster bundle',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Demo: upload a OneRoster v1.1 JSON bundle to seed branches, classes, and students for the owner organization. Skip to go straight to branch selection.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}

class _OrganizationField extends StatelessWidget {
  final OneRosterImportController controller;
  const _OrganizationField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingOrg.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 12),
              Text('Loading owner organization…'),
            ],
          ),
        );
      }
      if (controller.orgLoadError.value != null) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.orgLoadError.value!,
                style: TextStyle(color: Colors.red.shade800),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: controller.fetchParentOrganization,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ),
        );
      }
      final name = controller.parentOrgName.value ?? '—';
      final id = controller.parentOrgId.value ?? '';
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target organization',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            SelectableText(
              id,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FilePickerSection extends StatelessWidget {
  final OneRosterImportController controller;
  const _FilePickerSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final file = controller.pickedFile.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: file == null ? Colors.grey.shade300 : Colors.green.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              file == null ? Icons.upload_file_outlined : Icons.description,
              size: 32,
              color: file == null ? Colors.grey : Colors.green.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: file == null
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No file selected',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Pick a OneRoster .json bundle (max 10MB)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          file.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatSize(file.size),
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 12),
            if (file != null)
              IconButton(
                tooltip: 'Remove file',
                onPressed: controller.clearFile,
                icon: const Icon(Icons.close),
              ),
            TextButton.icon(
              onPressed: controller.pickFile,
              icon: const Icon(Icons.folder_open, size: 18),
              label: Text(file == null ? 'Pick file' : 'Replace'),
            ),
          ],
        ),
      );
    });
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class _DryRunToggle extends StatelessWidget {
  final OneRosterImportController controller;
  const _DryRunToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: SwitchListTile(
          value: controller.dryRun.value,
          onChanged: controller.isSubmitting.value
              ? null
              : (v) => controller.dryRun.value = v,
          title: const Text(
            'Dry-run (validate only)',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            controller.dryRun.value
                ? 'No data will be written. Returns the per-row plan.'
                : 'Will write branches, classes, students to the backend.',
            style: TextStyle(
              fontSize: 12,
              color: controller.dryRun.value
                  ? Colors.grey.shade700
                  : Colors.orange.shade800,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }
}

class _ActionButtons extends StatelessWidget {
  final OneRosterImportController controller;
  const _ActionButtons({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canSubmit = controller.pickedFile.value != null &&
          !controller.isSubmitting.value &&
          controller.parentOrgId.value != null;

      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: controller.isSubmitting.value
                  ? 'Importing…'
                  : (controller.dryRun.value ? 'Run dry-run' : 'Import'),
              variant: ButtonVariant.primary,
              onPressed: canSubmit ? controller.submit : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              text: 'Skip to branch selection',
              variant: ButtonVariant.outline,
              onPressed: controller.isSubmitting.value ? null : controller.skip,
            ),
          ),
        ],
      );
    });
  }
}

class _ResultPanel extends StatelessWidget {
  final OneRosterImportController controller;
  const _ResultPanel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final error = controller.lastErrorMessage.value;
      if (error != null) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            border: Border.all(color: Colors.red.shade200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(color: Colors.red.shade900),
                ),
              ),
            ],
          ),
        );
      }

      final result = controller.lastResult.value;
      if (result == null) return const SizedBox.shrink();

      final summary = result['summary'] as Map<String, dynamic>? ?? const {};
      final results = (result['results'] as List?) ?? const [];
      final dryRun = result['dryRun'] == true;
      final message = result['message']?.toString() ?? '';
      final total = (summary['total'] as num?)?.toInt() ?? 0;
      final successful = (summary['successful'] as num?)?.toInt() ?? 0;
      final failed = (summary['failed'] as num?)?.toInt() ?? 0;
      final byPhase =
          summary['byPhase'] as Map<String, dynamic>? ?? const {};

      return Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: failed == 0 ? Colors.green.shade50 : Colors.orange.shade50,
          border: Border.all(
            color: failed == 0
                ? Colors.green.shade200
                : Colors.orange.shade200,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  failed == 0
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_outlined,
                  color: failed == 0
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$successful / $total succeeded · failed: $failed${dryRun ? ' · dry-run' : ''}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 13),
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: byPhase.entries.map((entry) {
                final phase = entry.key;
                final stats = entry.value as Map<String, dynamic>? ?? const {};
                final pTotal = (stats['total'] as num?)?.toInt() ?? 0;
                final pOk = (stats['successful'] as num?)?.toInt() ?? 0;
                final pFail = (stats['failed'] as num?)?.toInt() ?? 0;
                final ok = pFail == 0;
                return Chip(
                  backgroundColor:
                      ok ? Colors.green.shade100 : Colors.red.shade100,
                  label: Text(
                    '${_phaseLabel(phase)} $pOk/$pTotal${pFail > 0 ? ' · $pFail failed' : ''}',
                    style: TextStyle(
                      color: ok ? Colors.green.shade900 : Colors.red.shade900,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            if (results.isNotEmpty) ...[
              const SizedBox(height: 12),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: EdgeInsets.zero,
                  title: Text(
                    'Row details (${results.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: results.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (_, i) {
                          final row = results[i] as Map<String, dynamic>;
                          final ok = row['success'] == true;
                          final phase = row['phase']?.toString() ?? '';
                          final sourcedId = row['sourcedId']?.toString() ?? '';
                          final name = row['name']?.toString() ?? '';
                          final action = row['action']?.toString() ?? '';
                          final error = row['error']?.toString();
                          return ListTile(
                            dense: true,
                            visualDensity: VisualDensity.compact,
                            leading: Icon(
                              ok ? Icons.check : Icons.close,
                              color: ok
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              size: 18,
                            ),
                            title: Text(
                              '${_phaseLabel(phase)} · $name',
                              style: const TextStyle(fontSize: 13),
                            ),
                            subtitle: Text(
                              ok
                                  ? '$sourcedId · $action'
                                  : '$sourcedId · ${error ?? 'error'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: ok
                                    ? Colors.grey.shade700
                                    : Colors.red.shade800,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            PrimaryButton(
              text: 'Continue to branch selection',
              variant: ButtonVariant.success,
              onPressed: controller.continueToBranchSelection,
            ),
          ],
        ),
      );
    });
  }

  String _phaseLabel(String phase) {
    switch (phase) {
      case 'branch':
        return 'Branch';
      case 'class':
        return 'Class';
      case 'student':
        return 'Student';
      case 'extra-enrollment':
        return 'Extra enrollment';
      default:
        return phase;
    }
  }
}
