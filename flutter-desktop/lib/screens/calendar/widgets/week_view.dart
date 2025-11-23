import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/appointment_card.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/create_appointment_dialog.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WeekView extends GetView<CalendarController> {
  const WeekView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Week Days Header
        Container(
          height: 83,
          decoration: BoxDecoration(
            color: AppTheme.colorPalette['neutral']!['10']!,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.colorPalette['neutral']!['30']!,
              ),
            ),
          ),
          child: Row(
            children: [
              // Doctors column header
              Container(
                width: 160,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Doctors',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorPalette['neutral']!['70']!,
                  ),
                ),
              ),

              // Working hours header
              Container(
                width: 120,
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Working hours',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.colorPalette['neutral']!['70']!,
                  ),
                ),
              ),

              // Day columns
              Expanded(
                child: Obx(() {
                  final weekDates = controller.getWeekDates();
                  return Row(
                    children: weekDates.map((date) {
                      final isToday = _isToday(date);
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppTheme.colorPalette['info']!['surface']!
                                    .withOpacity(0.3)
                                : null,
                            border: Border(
                              left: BorderSide(
                                color: AppTheme.colorPalette['neutral']!['30']!,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'W ${controller.getWeekNumber(date)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isToday
                                      ? AppTheme.colorPalette['info']!['main']!
                                      : AppTheme
                                          .colorPalette['neutral']!['60']!,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('d').format(date),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isToday
                                      ? AppTheme.colorPalette['info']!['main']!
                                      : AppTheme
                                          .colorPalette['neutral']!['90']!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
            ],
          ),
        ),

        // Doctors and Appointments (Vertical Layout)
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: controller.doctors.map((doctor) {
                return _buildDoctorRow(doctor);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorRow(String doctor) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.colorPalette['neutral']!['20']!,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Info
          Container(
            width: 160,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.colorPalette['info']!['surface']!,
                  child: Image.asset("assets/images/student_avatar_male.png"),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Obx(() {
                        final todayAppointments =
                            controller.getAppointmentsForDate(
                                controller.selectedDate.value);
                        final doctorAppointments = todayAppointments
                            .where((apt) => apt.doctor == doctor)
                            .length;
                        return Text(
                          '($doctorAppointments) Patients today',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.colorPalette['neutral']!['60']!,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Working Hours
          Container(
            width: 120,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.colorPalette['success']!['main']!,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '12 hrs',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.colorPalette['success']!['main']!,
                  ),
                ),
              ],
            ),
          ),

          // Week Days with Appointments
          Expanded(
            child: Obx(() {
              final weekDates = controller.getWeekDates();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: weekDates.map((date) {
                  return Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isToday(date)
                            ? AppTheme.colorPalette['info']!['surface']!
                                .withOpacity(0.1)
                            : null,
                        border: Border(
                          left: BorderSide(
                            color: AppTheme.colorPalette['neutral']!['30']!,
                          ),
                        ),
                      ),
                      child: _buildDoctorDayColumn(doctor, date),
                    ),
                  );
                }).toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorDayColumn(String doctor, DateTime date) {
    final dayAppointments = controller.getAppointmentsForDate(date);
    final doctorAppointments =
        dayAppointments.where((apt) => apt.doctor == doctor).toList();

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          ...doctorAppointments.map((appointment) {
            final status = controller.appointmentStatuses[appointment.id] ??
                AppointmentStatus.notDone;
            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              child: AppointmentCard(
                appointment: appointment,
                status: status,
                isCompact: true,
                onTap: () {
                  // TODO: Handle appointment tap
                },
              ),
            );
          }).toList(),
          // Add empty slot for creating new appointments
          if (doctorAppointments.isEmpty)
            GestureDetector(
              onTap: () => _showCreateAppointmentDialog(doctor, date),
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color:
                      AppTheme.colorPalette['neutral']!['10']!.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppTheme.colorPalette['neutral']!['20']!,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: AppTheme.colorPalette['neutral']!['50']!,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  void _showCreateAppointmentDialog(String doctor, DateTime date) {
    Get.dialog(
      CreateAppointmentDialog(
        selectedDate: date,
        selectedDoctor: doctor,
      ),
      barrierDismissible: false,
    );
  }
}
