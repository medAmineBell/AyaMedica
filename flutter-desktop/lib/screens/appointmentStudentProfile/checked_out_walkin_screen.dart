import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../config/app_config.dart';
import '../../../controllers/home_controller.dart';
import '../../../models/appointment_history_model.dart';
import '../../../models/student.dart';
import '../../../utils/storage_service.dart';

class CheckedOutWalkInScreen extends StatefulWidget {
  final Student student;
  final AppointmentHistory appointment;

  const CheckedOutWalkInScreen({
    Key? key,
    required this.student,
    required this.appointment,
  }) : super(key: key);

  @override
  State<CheckedOutWalkInScreen> createState() => _CheckedOutWalkInScreenState();
}

class _CheckedOutWalkInScreenState extends State<CheckedOutWalkInScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _studentData;
  Map<String, dynamic>? _recordData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    print(
        '[CheckedOutWalkIn] appointmentId=${widget.appointment.id}, medicalRecordId=${widget.appointment.medicalRecordId}');
    if (widget.appointment.medicalRecordId == null) {
      setState(() => _isLoading = false);
      return;
    }
    try {
      final storageService = Get.find<StorageService>();
      final accessToken = storageService.getAccessToken();
      if (accessToken == null) return;

      final url =
          '${AppConfig.newBackendUrl}/api/appointment-sessions/${widget.appointment.id}/medical-records/${widget.appointment.medicalRecordId}';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success'] == true) {
          final data = jsonData['data'] as Map<String, dynamic>;
          setState(() {
            _studentData = data['student'] as Map<String, dynamic>?;
            _recordData =
                data['medicalRecord'] as Map<String, dynamic>? ?? data;
          });
        }
      }
    } catch (e) {
      print('[CheckedOutWalkIn] Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBFCFD),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Back button
            Row(
              children: [
                InkWell(
                  onTap: () => homeController
                      .changeContent(ContentType.appointmentScheduling),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back,
                          size: 16, color: Color(0xFF6B7280)),
                      SizedBox(width: 8),
                      Text('Back',
                          style: TextStyle(
                              fontSize: 14, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _recordData == null
                      ? const Center(child: Text('No record data available'))
                      : SingleChildScrollView(
                          child: _buildContent(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final record = _recordData!;
    final student = _studentData;

    // Student info
    final nameMap = student?['name'];
    final fullName = nameMap is Map
        ? '${nameMap['given'] ?? ''} ${nameMap['family'] ?? ''}'.trim()
        : widget.student.name;
    final grade = student?['grade'] as String? ?? widget.student.grade ?? '';
    final studentClass =
        student?['studentClass'] as String? ?? widget.student.className ?? '';
    final initials = fullName.split(' ').length >= 2
        ? '${fullName.split(' ')[0][0]}${fullName.split(' ')[1][0]}'
            .toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';

    final effectiveDate = record['effectiveDateTime'] as String?;
    final formattedTime = effectiveDate != null
        ? 'Today at ${DateFormat('hh:mm a').format(DateTime.parse(effectiveDate))}'
        : '';

    final specialty = record['doctor_aid'] != null ? 'School' : 'General';
    final clinicAddress = _studentData?['branch']?['name'] as String? ?? '';
    final doctorAid = record['doctor_aid'] as String? ?? '';

    // Vitals (nested under 'signs')
    final signs = record['signs'] as Map<String, dynamic>? ?? {};
    final heartRate = signs['heart_rate'];
    final bloodPressure = signs['blood_pressure'];
    final temperature = signs['temperature'];
    final respiratoryRate = signs['respiratory_rate'];
    final bloodGlucose = signs['blood_glucose'];
    final oxygenSaturation = signs['oxygen_saturation'];
    final height = signs['height'];
    final weight = signs['weight'];

    // Assessment (nested under 'assessment')
    final assessment = record['assessment'] as Map<String, dynamic>? ?? {};
    final complaints = assessment['chief_complaints'] as List? ?? [];
    final examination = assessment['examination_details'] as String?;
    final diseases = assessment['suspected_diseases'] as List? ?? [];
    final recommendations = assessment['recommendation'] as List? ?? [];
    final note = record['note'] as String?;

    // Drugs
    final drugs = record['drugs'] as List? ?? [];

    // Sick leave
    final sickLeave = record['sick_leave'] as Map<String, dynamic>?;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student header
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFC4A84E),
                backgroundImage: student?['photo'] != null
                    ? NetworkImage(
                        '${AppConfig.newBackendUrl}${student!['photo']}')
                    : null,
                child: student?['photo'] == null
                    ? Text(initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700))
                    : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fullName,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('$grade - $studentClass',
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF6B7280))),
                ],
              ),
              const Spacer(),
              Text(formattedTime,
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            ],
          ),
          const SizedBox(height: 24),

          // Specialty
          Text(specialty,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          // Created by
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text('Created by',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                const SizedBox(width: 16),
                const Icon(Icons.local_hospital,
                    size: 16, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Text('$clinicAddress', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                const Icon(Icons.medical_services,
                    size: 16, color: Color(0xFF6B7280)),
                const SizedBox(width: 6),
                Text(doctorAid, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Vitals
          _buildVitalsRow(heartRate, bloodPressure, temperature,
              respiratoryRate, bloodGlucose, oxygenSaturation, height, weight),
          const SizedBox(height: 24),

          // Chief complaint section
          _buildSectionTitle('Chief complaint'),
          const SizedBox(height: 8),
          _buildInfoRow('Chief complaint',
              complaints.isNotEmpty ? complaints.join(', ') : '-'),
          _buildInfoRow('Examination details', examination ?? '-'),

          const SizedBox(height: 24),

          // Assessment section
          _buildSectionTitle('Assessment'),
          const SizedBox(height: 8),
          _buildInfoRow('Suspected disease(s)',
              diseases.isNotEmpty ? diseases.join(', ') : '-'),
          _buildInfoRow('Recommendations(s)',
              recommendations.isNotEmpty ? recommendations.join(', ') : '-'),

          const SizedBox(height: 24),

          // Plan (Drugs)
          if (drugs.isNotEmpty) ...[
            _buildSectionTitle('Plan'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: drugs
                  .map((d) => _buildDrugCard(d as Map<String, dynamic>))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],

          // General Notes & sick leave
          _buildSectionTitle('General Notes & sick leave (if applicable)'),
          const SizedBox(height: 8),
          _buildInfoRow('General note', note ?? '-'),
          if (sickLeave != null)
            _buildInfoRow(
              'Sick leave details',
              '${sickLeave['days']} Days | From ${sickLeave['start_date'] ?? '-'} To ${_calcEndDate(sickLeave)}',
            ),
        ],
      ),
    );
  }

  Widget _buildVitalsRow(
    dynamic heartRate,
    dynamic bloodPressure,
    dynamic temperature,
    dynamic respiratoryRate,
    dynamic bloodGlucose,
    dynamic oxygenSaturation,
    dynamic height,
    dynamic weight,
  ) {
    final vitals = [
      {
        'title': 'Heart Rate',
        'value': heartRate?.toString() ?? '-',
        'svg': 'assets/svg/heart_rate_01.svg'
      },
      {
        'title': 'Blood Pressure',
        'value': bloodPressure?.toString() ?? '-',
        'svg': 'assets/svg/blood_pressure_02.svg'
      },
      {
        'title': 'Temperature',
        'value': temperature?.toString() ?? '-',
        'svg': 'assets/svg/blood_pressure_01.svg'
      },
      {
        'title': 'Respiratory Rate',
        'value': respiratoryRate?.toString() ?? '-',
        'svg': 'assets/svg/lungs.svg'
      },
      {
        'title': 'Blood Glucose',
        'value': bloodGlucose?.toString() ?? '-',
        'svg': 'assets/svg/blood_glucose.svg'
      },
      {
        'title': 'Oxygen Saturation',
        'value': oxygenSaturation != null ? '${oxygenSaturation}%' : '-',
        'svg': 'assets/svg/Heading.svg'
      },
      {
        'title': 'Height & weight',
        'value': '${height ?? '-'} / ${weight ?? '-'}',
        'svg': 'assets/svg/weight.svg'
      },
    ];

    return Row(
      children: vitals
          .map((v) => Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE4E9ED)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      SvgPicture.asset(v['svg']!,
                          width: 22,
                          height: 22,
                          colorFilter: const ColorFilter.mode(
                              Color(0xFF1339FF), BlendMode.srcIn)),
                      const SizedBox(height: 4),
                      Text(v['title']!,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFFA6A9AC),
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: const Color(0xFFE4E9ED), width: 0.5),
                        ),
                        child: Text(v['value']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                                fontWeight: FontWeight.w500)),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D2E2E),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(width: 24),
          Flexible(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827)),
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    final name = drug['drug_name'] as String? ?? '{Drug name}';
    final ingredient = drug['drug_active_ingredient'] as String? ?? '-';
    final form = drug['drug_administration_form'] as String? ?? 'Oral';
    final foodRelation = drug['drug_relation_to_food'];
    final timing = foodRelation is List
        ? foodRelation.join(', ')
        : foodRelation?.toString() ?? '-';
    final dose = drug['dose']?.toString() ?? '-';
    final doseType = drug['dose_type']?.toString() ?? '';
    final drugNote = drug['drug_note'] as String?;
    final days = drug['drug_days']?.toString() ?? '-';
    final hours = drug['drug_hours']?.toString() ?? '-';
    final startDate = drug['drug_start_date']?.toString() ?? '-';
    final endDate = drug['drug_end_date']?.toString() ?? '-';

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              _pill(ingredient),
              const SizedBox(width: 6),
              _pill(form),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$dose $doseType',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595A5B))),
                  Text(timing,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF747677)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$days days',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF595A5B))),
                  Text('Every $hours hours',
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF747677))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDF1F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _dateCol('Starting date', _formatDate(startDate)),
                _dateCol('End date', _formatDate(endDate)),
              ],
            ),
          ),
          if (drugNote != null && drugNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(drugNote,
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF747677),
                    fontStyle: FontStyle.italic),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFFEDF1F5),
          borderRadius: BorderRadius.circular(64),
        ),
        child: Text(text,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF595A5B)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ),
    );
  }

  Widget _dateCol(String label, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, color: Color(0xFF747677))),
        Text(date,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1339FF))),
      ],
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty || dateStr == '-') return '-';
    try {
      final d = DateTime.parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(d);
    } catch (_) {
      return dateStr;
    }
  }

  String _calcEndDate(Map<String, dynamic> sickLeave) {
    final startStr = sickLeave['start_date'] as String?;
    final days = sickLeave['days'] as int? ?? 0;
    if (startStr == null) return '-';
    try {
      final start = DateTime.parse(startStr);
      final end = start.add(Duration(days: days));
      return DateFormat('dd/MM/yyyy').format(end);
    } catch (_) {
      return '-';
    }
  }
}
