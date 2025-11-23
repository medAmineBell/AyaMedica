import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/appointment_card.dart';
import 'package:flutter_getx_app/screens/calendar/widgets/create_appointment_dialog.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DayView extends GetView<CalendarController> {
  const DayView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Doctor Headers
        Container(
          height: 100,
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
              // Working hours column header
              Container(
                width: 100,
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

              // Doctor columns
              Expanded(
                child: Row(
                  children: controller.doctors.map((doctor) {
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: AppTheme.colorPalette['neutral']!['30']!,
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Doctor Avatar and Name
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppTheme
                                      .colorPalette['info']!['surface']!,
                                  child: Image.asset(
                                      "assets/images/student_avatar_male.png"),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                        final doctorAppointments =
                                            todayAppointments
                                                .where((apt) =>
                                                    apt.doctor == doctor)
                                                .length;
                                        return Text(
                                          '($doctorAppointments) Patients today',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w400,
                                            color: AppTheme.colorPalette[
                                                'neutral']!['60']!,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Working hours indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: AppTheme
                                        .colorPalette['success']!['main']!,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '12 hrs',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme
                                        .colorPalette['success']!['main']!,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        // Time Slots and Appointments
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Time column
                Container(
                  width: 100,
                  child: Column(
                    children: _buildTimeSlots(),
                  ),
                ),

                // Doctor columns with appointments
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: controller.doctors.map((doctor) {
                      return Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: AppTheme.colorPalette['neutral']!['30']!,
                              ),
                            ),
                          ),
                          child: Column(
                            children: _buildDoctorColumn(doctor),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTimeSlots() {
    List<Widget> timeSlots = [];

    for (int hour = 8; hour <= 18; hour++) {
      // Main hour slot
      timeSlots.add(
        Container(
          height: 160,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppTheme.colorPalette['neutral']!['20']!,
              ),
            ),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              _formatTime(hour, 0),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.colorPalette['neutral']!['60']!,
              ),
            ),
          ),
        ),
      );

      // Half hour slot
      if (hour < 18) {
        timeSlots.add(
          Container(
            height: 160,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.colorPalette['neutral']!['20']!,
                ),
              ),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                _formatTime(hour, 30),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.colorPalette['neutral']!['60']!,
                ),
              ),
            ),
          ),
        );
      }
    }

    return timeSlots;
  }

  List<Widget> _buildDoctorColumn(String doctor) {
    List<Widget> slots = [];

    for (int hour = 8; hour <= 18; hour++) {
      // Main hour slot
      slots.add(_buildTimeSlot(doctor, hour, 0));

      // Half hour slot
      if (hour < 18) {
        slots.add(_buildTimeSlot(doctor, hour, 30));
      }
    }

    return slots;
  }

  Widget _buildTimeSlot(String doctor, int hour, int minute) {
    final timeSlot = DateTime(2023, 1, 1, hour, minute);
    // Use the same time format as the appointment creation (with leading zeros)
    final timeString = _formatTime(hour, minute);

    return Obx(() {
      final todayAppointments =
          controller.getAppointmentsForDate(controller.selectedDate.value);

      // Debug: Print appointments for this time slot
      if (hour == 9 && minute == 0) {
        // Only print for 9:00 AM to avoid spam
        print('Day view - Selected date: ${controller.selectedDate.value}');
        print(
            'Day view - Total appointments: ${controller.appointments.length}');
        print(
            'Day view - Appointments for selected date: ${todayAppointments.length}');
        print('Day view - Looking for doctor: $doctor, time: $timeString');
        todayAppointments.forEach((apt) {
          print(
              'Day view - Found appointment: ${apt.doctor} at ${apt.time} on ${apt.date}');
        });
      }

      final slotAppointments = todayAppointments
          .where((apt) =>
              apt.doctor == doctor &&
              apt.time.toLowerCase() == timeString.toLowerCase())
          .toList();

      return Container(
        height: 160,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppTheme.colorPalette['neutral']!['20']!,
            ),
          ),
        ),
        child: slotAppointments.isNotEmpty
            ? Column(
                children: slotAppointments.map((appointment) {
                  final status =
                      controller.appointmentStatuses[appointment.id] ??
                          AppointmentStatus.notDone;
                  return Expanded(
                    child: AppointmentCard(
                      appointment: appointment,
                      status: status,
                      isCompact: false,
                      onTap: () {
                        // TODO: Handle appointment tap
                      },
                    ),
                  );
                }).toList(),
              )
            : GestureDetector(
                onTap: () => _showCreateAppointmentDialog(hour, minute),
                child: _buildEmptySlot(),
              ),
      );
    });
  }

  Widget _buildEmptySlot() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.colorPalette['neutral']!['10']!.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.colorPalette['neutral']!['20']!,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Text(
          'Not available',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppTheme.colorPalette['neutral']!['50']!,
          ),
        ),
      ),
    );
  }

  void _showCreateAppointmentDialog(int hour, int minute) {
    final timeString = _formatTime(hour, minute);

    Get.dialog(
      CreateAppointmentDialog(
        selectedDate: controller.selectedDate.value,
        selectedTime: timeString,
      ),
      barrierDismissible: false,
    );
  }

  String _formatTime(int hour, int minute) {
    // Format time to match the appointment creation format (e.g., "09:00 AM", "01:30 PM")
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final formattedHour = displayHour.toString().padLeft(2, '0');
    final formattedMinute = minute.toString().padLeft(2, '0');
    return '$formattedHour:$formattedMinute $period';
  }
}
