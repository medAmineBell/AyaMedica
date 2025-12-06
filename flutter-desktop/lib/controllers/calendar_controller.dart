import 'package:flutter/material.dart';
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

  // Status filter: 'checkIn', 'checkedOut', 'cancelled'
  final RxString selectedStatusFilter = 'checkIn'.obs;

  // Search query
  final RxString searchQuery = ''.obs;

  // Filter options
  final RxSet<String> selectedAppointmentTypes = <String>{}.obs;
  final RxSet<String> selectedDiseaseTypes = <String>{}.obs;
  final RxSet<String> selectedGrades = <String>{}.obs;
  final RxSet<String> selectedClasses = <String>{}.obs;
  final RxSet<String> selectedDoctors = <String>{}.obs;

  // View state - track if showing details or list
  final Rx<Appointment?> selectedAppointmentForDetails = Rx<Appointment?>(null);
  
  void showAppointmentDetails(Appointment appointment) {
    selectedAppointmentForDetails.value = appointment;
  }
  
  void hideAppointmentDetails() {
    selectedAppointmentForDetails.value = null;
  }
  
  bool get isShowingDetails => selectedAppointmentForDetails.value != null;

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
    // Sample appointments matching the Figma design
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    appointments.addAll([
      Appointment(
        id: '1',
        type: 'Checkup',
        allStudents: true,
        date: today.add(const Duration(hours: 8)),
        time: '08:00 AM - 08:30 AM',
        disease: 'Body Mass index - BMI',
        diseaseType: 'Disease type',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [],
        status: AppointmentStatus.received,
      ),
      Appointment(
        id: '2',
        type: 'Follow up',
        allStudents: true,
        date: today.add(const Duration(hours: 9)),
        time: '09:00 AM - 09:30 AM',
        disease: 'Body Mass index - BMI',
        diseaseType: 'Disease type',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Ahmad Samir',
        selectedStudents: [],
        status: AppointmentStatus.notDone,
      ),
      Appointment(
        id: '3',
        type: 'Walk in',
        allStudents: false,
        date: today.add(const Duration(hours: 10)),
        time: '10:00 AM - 10:30 AM',
        disease: 'General Checkup',
        diseaseType: '',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [
          Student(
            id: 'student_walkin',
            name: 'Noha Ahed',
            avatarColor: Colors.blue,
            grade: 'G4',
            className: 'Lion Class',
          ),
        ],
        status: AppointmentStatus.notDone,
      ),
      Appointment(
        id: '4',
        type: 'Follow up',
        allStudents: true,
        date: today.add(const Duration(hours: 11)),
        time: '11:00 AM - 11:30 AM',
        disease: 'Body Mass index - BMI',
        diseaseType: 'Disease type',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Ahmad Samir',
        selectedStudents: [],
        status: AppointmentStatus.notDone,
      ),
      Appointment(
        id: '5',
        type: 'Follow up',
        allStudents: true,
        date: today.add(const Duration(hours: 12)),
        time: '12:00 PM - 12:30 PM',
        disease: 'Body Mass index - BMI',
        diseaseType: 'Disease type',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [],
        status: AppointmentStatus.notDone,
      ),
      Appointment(
        id: '6',
        type: 'Follow up',
        allStudents: true,
        date: today.add(const Duration(hours: 13)),
        time: '01:00 PM - 01:30 PM',
        disease: 'Body Mass index - BMI',
        diseaseType: 'Disease type',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Ahmad Samir',
        selectedStudents: [],
        status: AppointmentStatus.notDone,
      ),
      Appointment(
        id: '7',
        type: 'Follow up',
        allStudents: true,
        date: today.add(const Duration(hours: 14)),
        time: '02:00 PM - 02:30 PM',
        disease: 'Body Mass index - BMI',
        diseaseType: 'Disease type',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Salem Said Al Ali',
        selectedStudents: [],
        status: AppointmentStatus.done,
      ),
      Appointment(
        id: '8',
        type: 'Checkup',
        allStudents: true,
        date: today.add(const Duration(days: 1)),
        time: '08:00 AM - 08:30 AM',
        disease: 'Body Mass index - BMI',
        diseaseType: 'Disease type',
        grade: 'G4',
        className: 'Lion Class',
        doctor: 'Dr. Ahmad Samir',
        selectedStudents: [],
        status: AppointmentStatus.cancelled,
      ),
    ]);

    // Set appointment statuses
    appointmentStatuses['1'] = AppointmentStatus.received;
    appointmentStatuses['2'] = AppointmentStatus.notDone;
    appointmentStatuses['3'] = AppointmentStatus.notDone;
    appointmentStatuses['4'] = AppointmentStatus.notDone;
    appointmentStatuses['5'] = AppointmentStatus.notDone;
    appointmentStatuses['6'] = AppointmentStatus.notDone;
    appointmentStatuses['7'] = AppointmentStatus.done;
    appointmentStatuses['8'] = AppointmentStatus.cancelled;
  }

  // Get filtered appointments based on status, search, and filters
  List<Appointment> get filteredAppointments {
    var filtered = appointments.toList();

    // Filter by status
    filtered = filtered.where((appointment) {
      final status = appointmentStatuses[appointment.id] ?? appointment.status;
      switch (selectedStatusFilter.value) {
        case 'checkIn':
          return status == AppointmentStatus.received || 
                 status == AppointmentStatus.notDone ||
                 status == AppointmentStatus.pendingApproval;
        case 'checkedOut':
          return status == AppointmentStatus.done;
        case 'cancelled':
          return status == AppointmentStatus.cancelled;
        default:
          return true;
      }
    }).toList();

    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      filtered = filtered.where((appointment) {
        return appointment.className.toLowerCase().contains(query) ||
               appointment.grade.toLowerCase().contains(query) ||
               appointment.type.toLowerCase().contains(query) ||
               appointment.disease.toLowerCase().contains(query) ||
               appointment.diseaseType.toLowerCase().contains(query) ||
               appointment.doctor.toLowerCase().contains(query) ||
               (appointment.allStudents 
                 ? 'all students'.contains(query)
                 : appointment.selectedStudents.any((student) => 
                     student.name.toLowerCase().contains(query)));
      }).toList();
    }

    // Filter by appointment types
    if (selectedAppointmentTypes.isNotEmpty) {
      filtered = filtered.where((appointment) => 
        selectedAppointmentTypes.contains(appointment.type)).toList();
    }

    // Filter by disease types
    if (selectedDiseaseTypes.isNotEmpty) {
      filtered = filtered.where((appointment) => 
        selectedDiseaseTypes.contains(appointment.diseaseType)).toList();
    }

    // Filter by grades
    if (selectedGrades.isNotEmpty) {
      filtered = filtered.where((appointment) => 
        selectedGrades.contains(appointment.grade)).toList();
    }

    // Filter by classes
    if (selectedClasses.isNotEmpty) {
      filtered = filtered.where((appointment) => 
        selectedClasses.contains(appointment.className)).toList();
    }

    // Filter by doctors
    if (selectedDoctors.isNotEmpty) {
      filtered = filtered.where((appointment) => 
        selectedDoctors.contains(appointment.doctor)).toList();
    }

    return filtered;
  }

  // Get count for each status tab
  int get checkInCount {
    return appointments.where((appointment) {
      final status = appointmentStatuses[appointment.id] ?? appointment.status;
      return status == AppointmentStatus.received || 
             status == AppointmentStatus.notDone ||
             status == AppointmentStatus.pendingApproval;
    }).length;
  }

  int get checkedOutCount {
    return appointments.where((appointment) {
      final status = appointmentStatuses[appointment.id] ?? appointment.status;
      return status == AppointmentStatus.done;
    }).length;
  }

  int get cancelledCount {
    return appointments.where((appointment) {
      final status = appointmentStatuses[appointment.id] ?? appointment.status;
      return status == AppointmentStatus.cancelled;
    }).length;
  }

  // Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (selectedAppointmentTypes.isNotEmpty) count++;
    if (selectedDiseaseTypes.isNotEmpty) count++;
    if (selectedGrades.isNotEmpty) count++;
    if (selectedClasses.isNotEmpty) count++;
    if (selectedDoctors.isNotEmpty) count++;
    return count;
  }

  // Set status filter
  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
  }

  // Set search query
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Clear all filters
  void clearFilters() {
    selectedAppointmentTypes.clear();
    selectedDiseaseTypes.clear();
    selectedGrades.clear();
    selectedClasses.clear();
    selectedDoctors.clear();
  }
}
