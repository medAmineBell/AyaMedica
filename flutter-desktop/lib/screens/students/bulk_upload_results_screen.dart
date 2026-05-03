import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/controllers/student_controller.dart';
import 'package:flutter_getx_app/models/bulk_upload_models.dart';
import 'package:flutter_getx_app/screens/students/widgets/upload_students_dialog.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:get/get.dart';

class BulkUploadResultsScreen extends StatefulWidget {
  const BulkUploadResultsScreen({Key? key}) : super(key: key);

  @override
  State<BulkUploadResultsScreen> createState() =>
      _BulkUploadResultsScreenState();
}

class _BulkUploadResultsScreenState extends State<BulkUploadResultsScreen> {
  static const int _pageSize = 10;

  final RxInt _currentPage = 1.obs;

  @override
  void dispose() {
    _currentPage.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentController = Get.find<StudentController>();
    final homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            studentController: studentController,
            homeController: homeController,
          ),
          const SizedBox(height: 16),
          const Text(
            'New students records',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload new students records',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          _StatsSummary(controller: studentController),
          const SizedBox(height: 16),
          _DefectedBanner(controller: studentController),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      final rows = studentController.defectiveRecords.toList();
                      if (rows.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No defected records to display.',
                              style: TextStyle(color: Color(0xFF64748B)),
                            ),
                          ),
                        );
                      }

                      final totalPages = (rows.length / _pageSize).ceil();
                      if (_currentPage.value > totalPages) {
                        _currentPage.value = totalPages;
                      }
                      if (_currentPage.value < 1) {
                        _currentPage.value = 1;
                      }

                      final start = (_currentPage.value - 1) * _pageSize;
                      final end = (start + _pageSize).clamp(0, rows.length);
                      final pageRows = rows.sublist(start, end);

                      return _ResultsTable(rows: pageRows);
                    }),
                  ),
                  Obx(() {
                    final total = studentController.defectiveRecords.length;
                    if (total == 0) return const SizedBox.shrink();
                    final totalPages = (total / _pageSize).ceil();
                    return _Pagination(
                      currentPage: _currentPage.value,
                      totalPages: totalPages,
                      onPrev: () {
                        if (_currentPage.value > 1) {
                          _currentPage.value--;
                        }
                      },
                      onNext: () {
                        if (_currentPage.value < totalPages) {
                          _currentPage.value++;
                        }
                      },
                      onSelect: (p) => _currentPage.value = p,
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final StudentController studentController;
  final HomeController homeController;

  const _Header({
    required this.studentController,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 16),
          onPressed: () => homeController.navigateToStudentsList(),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: BreadcrumbWidget(
            items: [
              BreadcrumbItem(
                label: 'Add and manage students list',
                onTap: () => homeController.navigateToStudentsList(),
              ),
              BreadcrumbItem(
                label: 'Upload students list',
                onTap: () => homeController.navigateToStudentsList(),
              ),
              const BreadcrumbItem(label: 'Defected Data'),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () {
            studentController.clearDefectiveRecords();
            homeController.navigateToStudentsList();
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Exit to existing students list',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: null, // v1: inline edit out of scope
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1339FF),
            disabledBackgroundColor: const Color(0xFFE2E8F0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Save details',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Tooltip(
          message: 'Fix all defected records first',
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1339FF),
              disabledBackgroundColor: const Color(0xFFE2E8F0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Complete upload',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsSummary extends StatelessWidget {
  final StudentController controller;

  const _StatsSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = controller.lastBulkUploadResponse.value;
      if (r == null) return const SizedBox.shrink();
      return Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Total rows',
              value: r.total.toString(),
              color: const Color(0xFF1339FF),
              icon: Icons.list_alt,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Created',
              value: r.created.toString(),
              color: const Color(0xFF059669),
              icon: Icons.add_circle_outline,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Updated',
              value: r.updated.toString(),
              color: const Color(0xFF0EA5E9),
              icon: Icons.refresh,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Transferred',
              value: r.transferred.toString(),
              color: const Color(0xFF8B5CF6),
              icon: Icons.swap_horiz,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Failed',
              value: r.failed.toString(),
              color: const Color(0xFFDC2626),
              icon: Icons.error_outline,
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DefectedBanner extends StatelessWidget {
  final StudentController controller;

  const _DefectedBanner({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.defectiveRecords.length;
      if (count == 0) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: const [
              Icon(Icons.check_circle_outline,
                  color: Color(0xFF059669), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All records were imported successfully.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final hasFile = (controller.defectedRecordsFileBase64.value ?? '').isNotEmpty;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFDC2626),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_outlined,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '($count) defected records found',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7F1D1D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Download the defected records file, correct it and re-upload it again.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F1D1D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () => showDialog(
                context: Get.context!,
                builder: (_) => const UploadStudentsDialog(),
              ),
              icon: const Icon(Icons.upload_outlined, size: 16),
              label: const Text('Upload corrected records'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed:
                  hasFile ? () => controller.downloadDefectedRecordsFile() : null,
              icon: const Icon(Icons.download_outlined, size: 16),
              label: const Text('Download defected records'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFDC2626)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                textStyle: const TextStyle(fontSize: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ResultsTable extends StatelessWidget {
  final List<BulkUploadRowResult> rows;

  const _ResultsTable({required this.rows});

  static const _columns = <_Column>[
    _Column('Student First name', _Field.givenName, width: 150),
    _Column('Student last name', _Field.familyName, width: 150),
    _Column('Gender', _Field.gender, width: 90),
    _Column('Date of birth', _Field.dateOfBirth, width: 120),
    _Column('Nationality', _Field.nationality, width: 110),
    _Column('Doc. type', _Field.documentType, width: 110),
    _Column('National ID / Passport', _Field.documentNumber, width: 180),
    _Column('Grade', _Field.grade, width: 80),
    _Column('Class', _Field.studentClass, width: 100),
    _Column('FG Full name', _Field.fgFullName, width: 170),
    _Column('FG Relation', _Field.fgRelation, width: 110),
    _Column('FG Email', _Field.fgEmail, width: 220),
    _Column('FG Phone', _Field.fgPhone, width: 150),
    _Column('SG Full name', _Field.sgFullName, width: 170),
    _Column('SG Relation', _Field.sgRelation, width: 110),
    _Column('SG Email', _Field.sgEmail, width: 220),
    _Column('SG Phone', _Field.sgPhone, width: 150),
  ];

  static double get _totalWidth =>
      _columns.fold<double>(0, (sum, c) => sum + c.width) + 32;

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _TableHeader(),
              Expanded(
                child: ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, i) => _TableRow(result: rows[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: _ResultsTable._columns
            .map((c) => SizedBox(
                  width: c.width,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      c.label,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF334155),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final BulkUploadRowResult result;

  const _TableRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _ResultsTable._columns
            .map((c) => SizedBox(
                  width: c.width,
                  child: _buildCell(c.field),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCell(_Field field) {
    final value = _readField(result.data, field);
    final reason = _reasonFor(field);
    final isInvalid = reason != null;

    if (isInvalid) {
      return Tooltip(
        message: reason,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value.isEmpty ? 'Undefined' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFFB91C1C),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF0F172A),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String? _reasonFor(_Field field) {
    switch (field) {
      case _Field.givenName:
        return result.reasonFor('name.given') ?? result.reasonFor('name');
      case _Field.familyName:
        return result.reasonFor('name.family') ?? result.reasonFor('name');
      case _Field.gender:
        return result.reasonFor('gender');
      case _Field.dateOfBirth:
        return result.reasonFor('dateOfBirth');
      case _Field.nationality:
        return result.reasonFor('nationality');
      case _Field.documentType:
        return result.reasonFor('documentType');
      case _Field.documentNumber:
        return result.reasonFor('documentNumber') ??
            result.reasonFor('documentType');
      case _Field.grade:
        return result.reasonFor('grade');
      case _Field.studentClass:
        return result.reasonFor('class');
      case _Field.fgFullName:
        return result.reasonFor('fgFullName');
      case _Field.fgRelation:
        return result.reasonFor('fgRelation');
      case _Field.fgEmail:
        return result.reasonFor('fgEmail');
      case _Field.fgPhone:
        return result.reasonFor('fgPhone');
      case _Field.sgFullName:
        return result.reasonFor('sgFullName');
      case _Field.sgRelation:
        return result.reasonFor('sgRelation');
      case _Field.sgEmail:
        return result.reasonFor('sgEmail');
      case _Field.sgPhone:
        return result.reasonFor('sgPhone');
    }
  }

  static String _readField(Map<String, dynamic> data, _Field field) {
    switch (field) {
      case _Field.givenName:
        return _readNested(data['name'], 'given');
      case _Field.familyName:
        return _readNested(data['name'], 'family');
      case _Field.gender:
        final raw = data['gender']?.toString() ?? '';
        if (raw.isEmpty) return '';
        return raw[0].toUpperCase() + raw.substring(1);
      case _Field.dateOfBirth:
        return data['dateOfBirth']?.toString() ?? '';
      case _Field.nationality:
        return data['nationality']?.toString() ?? '';
      case _Field.documentType:
        return data['documentType']?.toString() ?? '';
      case _Field.documentNumber:
        return data['documentNumber']?.toString() ?? '';
      case _Field.grade:
        return data['grade']?.toString() ?? '';
      case _Field.studentClass:
        return data['class']?.toString() ?? '';
      case _Field.fgFullName:
        return data['fgFullName']?.toString() ?? '';
      case _Field.fgRelation:
        return data['fgRelation']?.toString() ?? '';
      case _Field.fgEmail:
        return data['fgEmail']?.toString() ?? '';
      case _Field.fgPhone:
        return data['fgPhone']?.toString() ?? '';
      case _Field.sgFullName:
        return data['sgFullName']?.toString() ?? '';
      case _Field.sgRelation:
        return data['sgRelation']?.toString() ?? '';
      case _Field.sgEmail:
        return data['sgEmail']?.toString() ?? '';
      case _Field.sgPhone:
        return data['sgPhone']?.toString() ?? '';
    }
  }

  static String _readNested(dynamic obj, String key) {
    if (obj is Map) return obj[key]?.toString() ?? '';
    return '';
  }
}

enum _Field {
  givenName,
  familyName,
  gender,
  dateOfBirth,
  nationality,
  documentType,
  documentNumber,
  grade,
  studentClass,
  fgFullName,
  fgRelation,
  fgEmail,
  fgPhone,
  sgFullName,
  sgRelation,
  sgEmail,
  sgPhone,
}

class _Column {
  final String label;
  final _Field field;
  final double width;
  const _Column(this.label, this.field, {this.width = 140});
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onSelect;

  const _Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final pages = <int>[];
    final maxButtons = 5;
    int start = (currentPage - 2).clamp(1, totalPages);
    int end = (start + maxButtons - 1).clamp(1, totalPages);
    if (end - start < maxButtons - 1) {
      start = (end - maxButtons + 1).clamp(1, totalPages);
    }
    for (int i = start; i <= end; i++) {
      pages.add(i);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: currentPage > 1 ? onPrev : null,
            icon: const Icon(Icons.arrow_back, size: 14),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const Spacer(),
          ...pages.map((p) {
            final selected = p == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: TextButton(
                onPressed: () => onSelect(p),
                style: TextButton.styleFrom(
                  backgroundColor:
                      selected ? const Color(0xFFE0F2FE) : Colors.transparent,
                  minimumSize: const Size(36, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  '$p',
                  style: TextStyle(
                    color: selected
                        ? const Color(0xFF1339FF)
                        : const Color(0xFF334155),
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: currentPage < totalPages ? onNext : null,
            icon: const Icon(Icons.arrow_forward, size: 14),
            label: const Text('Next'),
            style: OutlinedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
