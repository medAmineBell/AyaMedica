import 'package:get/get.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/student.dart';

enum CalendarViewMode { day, week, month }

class CalendarController extends GetxController {
  // Current view mode
  final Rx<CalendarViewMode> currentViewMode = CalendarViewMode.day.obs;

  // Current selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Current week start date (for week view)
  final Rx<DateTime> weekStartDate = DateTime.now().obs;

  // Current month date (for month view)
  final Rx<DateTime> monthDate = DateTime.now().obs;

  // Appointments data
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxMap<String, AppointmentStatus> appointmentStatuses =
      <String, AppointmentStatus>{}.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Doctors list for the day view columns
  final RxList<String> doctors = <String>[
    'Dr. Salem Said Al Ali',
    'Dr. Ahmad Samir',
    'Dr. Salem Said Al Ali', // Third column
    'Dr. Salem Said Al Ali', // Fourth column
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeWeekStartDate();
    _initializeMonthDate();
    _loadSampleAppointments();
  }

  void _initializeWeekStartDate() {
    final now = DateTime.now();
    // Get the Monday of current week
    final daysFromMonday = now.weekday - 1;
    weekStartDate.value = now.subtract(Duration(days: daysFromMonday));
  }

  void _initializeMonthDate() {
    monthDate.value = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  // View mode switching
  void switchToDay() {
    currentViewMode.value = CalendarViewMode.day;
  }

  void switchToWeek() {
    currentViewMode.value = CalendarViewMode.week;
  }

  void switchToMonth() {
    currentViewMode.value = CalendarViewMode.month;
  }

  // Date navigation
  void goToPreviousDay() {
    selectedDate.value = selectedDate.value.subtract(const Duration(days: 1));
  }

  void goToNextDay() {
    selectedDate.value = selectedDate.value.add(const Duration(days: 1));
  }

  void goToPreviousWeek() {
    weekStartDate.value = weekStartDate.value.subtract(const Duration(days: 7));
  }

  void goToNextWeek() {
    weekStartDate.value = weekStartDate.value.add(const Duration(days: 7));
  }

  void goToPreviousMonth() {
    monthDate.value =
        DateTime(monthDate.value.year, monthDate.value.month - 1, 1);
  }

  void goToNextMonth() {
    monthDate.value =
        DateTime(monthDate.value.year, monthDate.value.month + 1, 1);
  }

  void goToToday() {
    final now = DateTime.now();
    selectedDate.value = now;
    _initializeWeekStartDate();
    _initializeMonthDate();
  }

  // Get appointments for specific date
  List<Appointment> getAppointmentsForDate(DateTime date) {
    print('CalendarController.getAppointmentsForDate called with date: $date');
    print('Total appointments in controller: ${appointments.length}');

    final filteredAppointments = appointments.where((appointment) {
      // Compare only year, month, and day, ignoring time components
      final matches = appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day;

      if (matches) {
        print(
            'Found matching appointment: ${appointment.doctor} at ${appointment.time} on ${appointment.date}');
      }

      return matches;
    }).toList();

    print('Filtered appointments count: ${filteredAppointments.length}');
    return filteredAppointments;
  }

  // Get appointments for date range
  List<Appointment> getAppointmentsForDateRange(DateTime start, DateTime end) {
    return appointments.where((appointment) {
      return appointment.date
              .isAfter(start.subtract(const Duration(days: 1))) &&
          appointment.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  // Get week dates (Monday to Sunday)
  List<DateTime> getWeekDates() {
    List<DateTime> weekDates = [];
    for (int i = 0; i < 7; i++) {
      weekDates.add(weekStartDate.value.add(Duration(days: i)));
    }
    return weekDates;
  }

  // Get week number for a date
  int getWeekNumber(DateTime date) {
    // Calculate week number based on the year
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    final weekNumber =
        ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
    return weekNumber;
  }

  // Get month dates for calendar grid
  List<DateTime> getMonthDates() {
    final firstDayOfMonth = monthDate.value;

    // Get the first Monday of the calendar grid
    final firstMonday =
        firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday - 1));

    List<DateTime> dates = [];
    DateTime current = firstMonday;

    // Generate 6 weeks (42 days) for the calendar grid
    for (int i = 0; i < 42; i++) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }

    return dates;
  }

  // Create a new appointment
  void createAppointment({
    required DateTime date,
    required String time,
    required String doctor,
    required String type,
    required String disease,
    required String diseaseType,
    required String grade,
    required String className,
    List<Student> selectedStudents = const [],
    bool allStudents = false,
  }) {
    print('CalendarController.createAppointment called with:');
    print('Date: $date');
    print('Time: $time');
    print('Doctor: $doctor');
    print('Type: $type');

    final newAppointment = Appointment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      allStudents: allStudents,
      date: date,
      time: time,
      disease: disease,
      diseaseType: diseaseType,
      grade: grade,
      className: className,
      doctor: doctor,
      selectedStudents: selectedStudents,
    );

    // Add to appointments list
    appointments.add(newAppointment);

    // Set default status
    appointmentStatuses[newAppointment.id!] = AppointmentStatus.received;

    print('Appointment created with ID: ${newAppointment.id}');
    print('Total appointments now: ${appointments.length}');
    print(
        'Appointments for date $date: ${getAppointmentsForDate(date).length}');

    // Update UI
    appointments.refresh();
  }

  // Update appointment status
  void updateAppointmentStatus(String appointmentId, AppointmentStatus status) {
    if (appointmentStatuses.containsKey(appointmentId)) {
      appointmentStatuses[appointmentId] = status;
      appointmentStatuses.refresh();
    }
  }

  // Delete appointment
  void deleteAppointment(String appointmentId) {
    appointments.removeWhere((appointment) => appointment.id == appointmentId);
    appointmentStatuses.remove(appointmentId);
    appointments.refresh();
  }

  // Get appointments for a specific doctor and date
  List<Appointment> getAppointmentsForDoctorAndDate(
      String doctor, DateTime date) {
    return appointments.where((appointment) {
      return appointment.doctor == doctor &&
          appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day;
    }).toList();
  }

  // Get appointments for a specific time slot
  List<Appointment> getAppointmentsForTimeSlot(String time, DateTime date) {
    return appointments.where((appointment) {
      return appointment.time.toLowerCase() == time.toLowerCase() &&
          appointment.date.year == date.year &&
          appointment.date.month == date.month &&
          appointment.date.day == date.day;
    }).toList();
  }

  // Check if a time slot is available for a doctor
  bool isTimeSlotAvailable(String doctor, String time, DateTime date) {
    final existingAppointments = getAppointmentsForDoctorAndDate(doctor, date);
    return !existingAppointments
        .any((apt) => apt.time.toLowerCase() == time.toLowerCase());
  }

  void _loadSampleAppointments() {
    // Sample appointments similar to the images
    final now = DateTime.now();

    appointments.addAll([
      Appointment(
        id: '1',
        type: 'Follow-up',
        allStudents: false,
        date: now,
        time: '09:00 AM',
        disease: 'General Checkup',
        diseaseType: 'Routine',
        grade: 'Grade 1',
        className: 'Lion Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [],
      ),
      Appointment(
        id: '2',
        type: 'Urgent',
        allStudents: false,
        date: now,
        time: '09:00 AM',
        disease: 'Emergency Check',
        diseaseType: 'Urgent',
        grade: 'Grade 2',
        className: 'Tiger Class',
        doctor: 'Dr. Ahmad Samir',
        selectedStudents: [],
      ),
      Appointment(
        id: '3',
        type: 'Visit Finalized',
        allStudents: false,
        date: now,
        time: '09:30 AM',
        disease: 'Completed Visit',
        diseaseType: 'Completed',
        grade: 'Grade 3',
        className: 'Eagle Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [],
      ),
      Appointment(
        id: '4',
        type: 'received',
        allStudents: false,
        date: now,
        time: '10:00 AM',
        disease: 'Paid Consultation',
        diseaseType: 'Paid',
        grade: 'Grade 1',
        className: 'Lion Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [],
      ),
      Appointment(
        id: '5',
        type: 'Cancelled',
        allStudents: false,
        date: now,
        time: '10:00 AM',
        disease: 'Cancelled Appointment',
        diseaseType: 'Cancelled',
        grade: 'Grade 2',
        className: 'Tiger Class',
        doctor: 'Dr. Ahmad Samir',
        selectedStudents: [],
      ),
      Appointment(
        id: '6',
        type: 'Urgent',
        allStudents: false,
        date: now,
        time: '11:00 AM',
        disease: 'Urgent Care',
        diseaseType: 'Urgent',
        grade: 'Grade 3',
        className: 'Eagle Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [],
      ),
      Appointment(
        id: '7',
        type: 'Paid',
        allStudents: false,
        date: now,
        time: '11:30 AM',
        disease: 'Paid Service',
        diseaseType: 'Paid',
        grade: 'Grade 2',
        className: 'Tiger Class',
        doctor: 'Dr. Ahmad Samir',
        selectedStudents: [],
      ),
    ]);

    // Set appointment statuses
    appointmentStatuses['1'] = AppointmentStatus.received;
    appointmentStatuses['2'] = AppointmentStatus.notDone;
    appointmentStatuses['3'] = AppointmentStatus.done;
    appointmentStatuses['4'] = AppointmentStatus.done;
    appointmentStatuses['5'] = AppointmentStatus.cancelled;
    appointmentStatuses['6'] = AppointmentStatus.notDone;
    appointmentStatuses['7'] = AppointmentStatus.done;
  }
}
