import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/home_controller.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/controllers/creating_appointment_controller.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/creating_appointment_dialog.dart';
import 'package:flutter_getx_app/screens/appointmentScheduling/widgets/notify_parents_dialog.dart';
import 'package:flutter_getx_app/utils/api_service.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../models/appointment.dart';
import '../../../controllers/appointment_scheduling_controller.dart';
import '../screens/appointmentScheduling/widgets/parents_notification_dialog.dart';

class CreateAppointmentController extends GetxController {
  final AppointmentSchedulingController appointmentController = Get.find();
  final ApiService _apiService = Get.find<ApiService>();
  
  final _formKey = GlobalKey<FormState>();
  late final List<Map<String, dynamic>> _appointmentTypes;
  late final List<String> _doctors;
  late final List<String> _diseaseTypes;
  late final List<String> _diseases;
  late final List<String> _classes;
  late final List<String> _grades;
  late final List<String> _vaccinationTypes;
  late final List<Student> _students;

  // Regular appointment fields
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final Rx<TimeOfDay?> selectedTime = Rx<TimeOfDay?>(null);
  final RxString selectedType = 'Checkup'.obs;
  final RxString selectedOption = 'all'.obs;
  final RxString selectedDateTimeOption = 'addDate'.obs; // 'addDate' or 'startNow'
  final Rx<String?> selectedClass = Rx<String?>(null);
  final Rx<String?> selectedGrade = Rx<String?>(null);
  final Rx<String?> selectedDisease = Rx<String?>(null);
  final Rx<String?> selectedDiseaseType = Rx<String?>(null);
  final Rx<String?> selectedDoctor = Rx<String?>(null);
  final Rx<String?> selectedVaccinationType = Rx<String?>(null);
  final RxList<Student> selectedStudents = <Student>[].obs;

  // Walk-In specific fields
  final aidController = TextEditingController();
  final Rx<Student?> walkInSelectedStudent = Rx<Student?>(null);
  final RxList<Student> filteredStudentsForWalkIn = <Student>[].obs;

  // Getters for easy access
  GlobalKey<FormState> get formKey => _formKey;
  List<Map<String, dynamic>> get appointmentTypes => _appointmentTypes;
  List<String> get doctors => _doctors;
  List<String> get diseaseTypes => _diseaseTypes;
  List<String> get diseases => _diseases;
  List<String> get classes => _classes;
  List<String> get grades => _grades;
  List<String> get vaccinationTypes => _vaccinationTypes;
  List<Student> get students => _students;

  @override
  void onInit() {
    super.onInit();
    
    // Initialize lists
    _appointmentTypes = _buildAppointmentTypes();
    _doctors = _buildDoctorsList();
    _diseaseTypes = _buildDiseaseTypes();
    _diseases = _buildDiseasesList();
    _classes = _buildClassesList();
    _grades = _buildGradesList();
    _vaccinationTypes = _buildVaccinationTypes();
    _students = _buildStudentsList();
    
    filteredStudentsForWalkIn.value = _students;

    // Listen to grade and class changes for Walk-In filtering
    ever(selectedGrade, (_) => _filterStudentsForWalkIn());
    ever(selectedClass, (_) => _filterStudentsForWalkIn());
  }

  @override
  void onClose() {
    aidController.dispose();
    super.onClose();
  }

  // Regular appointment methods
  void updateSelectedDate(DateTime? date) {
    selectedDate.value = date;
  }

  void updateSelectedTime(TimeOfDay? time) {
    selectedTime.value = time;
  }

  void updateSelectedType(String type) {
    selectedType.value = type;
    // Reset fields when switching between regular and walk-in
    if (type == 'Walk-In') {
      _resetWalkInFields();
    } else {
      _resetRegularFields();
    }
  }

  void updateSelectedOption(String option) {
    selectedOption.value = option;
  }

  void updateSelectedDateTimeOption(String option) {
    selectedDateTimeOption.value = option;
    // If "Start now" is selected, set current date and time
    if (option == 'startNow') {
      selectedDate.value = DateTime.now();
      selectedTime.value = TimeOfDay.now();
    }
  }

  void updateSelectedClass(String? className) {
    selectedClass.value = className;
  }

  void updateSelectedGrade(String? grade) {
    selectedGrade.value = grade;
  }

  void updateSelectedDisease(String? disease) {
    selectedDisease.value = disease;
  }

  void updateSelectedDiseaseType(String? diseaseType) {
    selectedDiseaseType.value = diseaseType;
  }

  void updateSelectedDoctor(String? doctor) {
    selectedDoctor.value = doctor;
  }

  void updateSelectedVaccinationType(String? vaccinationType) {
    selectedVaccinationType.value = vaccinationType;
  }

  void updateSelectedStudents(List<Student> students) {
    selectedStudents.value = students;
  }

  // Walk-In specific methods
  void updateWalkInSelectedStudent(Student? student) {
    walkInSelectedStudent.value = student;
    if (student != null) {
      aidController.text = student.id;
      _autoSelectGradeAndClass(student);
    }
  }

  void searchByAID(String aid) {
    if (aid.isEmpty) {
      walkInSelectedStudent.value = null;
      return;
    }

    final student = _students.firstWhereOrNull(
      (s) => s.id.toLowerCase().contains(aid.toLowerCase()),
    );

    if (student != null) {
      walkInSelectedStudent.value = student;
      _autoSelectGradeAndClass(student);
    }
  }

  void removeWalkInSelectedStudent() {
    walkInSelectedStudent.value = null;
    aidController.clear();
  }

  void _filterStudentsForWalkIn() {
    List<Student> filtered = _students;

    // Here you would filter based on actual student grade/class data
    // For now, we'll just return all students as demo data doesn't have grade/class info
    if (selectedGrade.value != null || selectedClass.value != null) {
      filtered = _students;
    }

    filteredStudentsForWalkIn.value = filtered;
  }

  void _autoSelectGradeAndClass(Student student) {
    // Auto-select grade and class based on student data
    // For demo purposes, we'll set some defaults
    if (selectedGrade.value == null) {
      selectedGrade.value = 'Grade 1';
    }
    if (selectedClass.value == null) {
      selectedClass.value = 'Lion Class';
    }
  }

  void _resetWalkInFields() {
    walkInSelectedStudent.value = null;
    aidController.clear();
    selectedGrade.value = null;
    selectedClass.value = null;
  }

  void _resetRegularFields() {
    selectedDate.value = null;
    selectedTime.value = null;
    selectedOption.value = 'all';
    selectedClass.value = null;
    selectedGrade.value = null;
    selectedDisease.value = null;
    selectedDiseaseType.value = null;
    selectedDoctor.value = null;
    selectedStudents.clear();
  }

  // Regular appointment creation
  Future<void> handleCreateAppointment() async {
    try {
      // Validate form and date/time first
      if (!(_formKey.currentState?.validate() ?? false) ||
          !_validateDateTime()) {
        return;
      }

      // Create appointment object
      final appointment = Appointment(
        type: selectedType.value,
        allStudents: selectedOption.value == 'all',
        date: selectedDate.value ?? DateTime.now(),
        time: _formatTime(selectedTime.value),
        disease: selectedDisease.value ?? '',
        diseaseType: selectedDiseaseType.value ?? '',
        grade: selectedGrade.value ?? '',
        className: selectedClass.value ?? '',
        doctor: selectedDoctor.value ?? '',
        selectedStudents: selectedStudents,
        status: selectedType.value == 'Vaccination'
            ? AppointmentStatus.pendingApproval
            : AppointmentStatus.notDone,
      );

      // Close the form dialog
      Get.back();

      // Initialize progress controller
      Get.put(CreatingAppointmentController());
      final progressController = Get.find<CreatingAppointmentController>();

      // Show loading dialog
      Get.dialog(
        const CreatingAppointmentDialog(),
        barrierDismissible: false,
      );

      // Simulate progress updates (replace with actual operations)
      const totalSteps = 10;
      for (int i = 1; i <= totalSteps; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        progressController.updateProgress(i / totalSteps);
      }

      // Create appointment via API
      final result = await _apiService.createAppointment(appointment);
      
      // Close dialog and clean up
      Get.back();
      Get.delete<CreatingAppointmentController>();

      if (result['success']) {
        // Add to local controller for immediate UI update
        await appointmentController.createAppointment(appointment);
        
        // Show success
        Get.snackbar(
          'Success',
          result['message'] ?? 'Appointment created successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade800,
          duration: const Duration(seconds: 3),
        );
      } else {
        // Show error
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to create appointment',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade800,
          duration: const Duration(seconds: 5),
        );
      }

      // Handle parent notification
      if (selectedType.value == 'Vaccination') {
        // Show notification dialog for vaccination appointments
        bool? shouldNotify = await Get.dialog<bool>(
          ParentsNotificationDialog(
            onDismiss: () {
              Get.back(); // Close the dialog
            },
          ),
          barrierDismissible: false,
        );

        if (shouldNotify ?? false) {
          await _notifyParents(appointment);
        }
      } else {
        final shouldNotify = await showNotifyParentsDialog();

        if (shouldNotify ?? false) {
          // Call your notification function here
          await _notifyParents(appointment);
        }
      }
    } catch (e) {
      // Clean up on error
      Get.back();
      Get.delete<CreatingAppointmentController>();

      Get.snackbar(
        'Error',
        'Failed to create appointment: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
        duration: const Duration(seconds: 5),
      );
    }
  }

  Future<void> _notifyParents(Appointment appointment) async {
    // Show loading indicator
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      // Call your notification service here

      Get.back(); // Close loading
      Get.snackbar(
        'Success',
        'Parents notified successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.back(); // Close loading
      Get.snackbar(
        'Error',
        'Failed to notify parents: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  // Walk-In appointment creation

  Future<void> handleStartWalkInAppointment() async {
    if (!_validateWalkInForm()) return;

    try {
      final appointment = Appointment(
        type: selectedType.value,
        allStudents: false,
        date: DateTime.now(),
        time: _getCurrentTime(),
        disease: 'Walk-in Consultation',
        diseaseType: '',
        grade: selectedGrade.value ?? '',
        className: selectedClass.value ?? '',
        doctor: 'Available Doctor',
        selectedStudents: walkInSelectedStudent.value != null
            ? [walkInSelectedStudent.value!]
            : [],
      );

      await appointmentController.createAppointment(appointment);
      Get.back(); // Close dialog

      // Navigate to student profile
      final homeController = Get.find<HomeController>();
      homeController.navigateToStudentProfile(
        walkInSelectedStudent.value!,
        appointmentType: selectedType.value,
      );

      Get.snackbar(
        'Success',
        'Walk-in appointment started successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to start appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  bool _validateDateTime() {
    if (selectedDate.value == null || selectedTime.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select date and time',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }
    return true;
  }

  bool _validateWalkInForm() {
    if (walkInSelectedStudent.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a student',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }

    if (selectedGrade.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a grade',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }

    if (selectedClass.value == null) {
      Get.snackbar(
        'Validation Error',
        'Please select a class',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return false;
    }

    return true;
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '';
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('hh:mm a').format(dt);
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour =
        now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // Helper methods for initializing lists
  List<Map<String, dynamic>> _buildAppointmentTypes() => [
        {
          'label': 'Checkup',
          'icon': Icon(Icons.health_and_safety, color: Colors.black)
        },
        {
          'label': 'Follow-Up',
          'icon': Icon(Icons.schedule, color: Colors.black)
        },
        {
          'label': 'Vaccination',
          'icon': Icon(Icons.vaccines, color: Colors.black)
        },
        {
          'label': 'Walk-In',
          'icon': Icon(Icons.directions_walk, color: Colors.black)
        },
      ];

  List<String> _buildDoctorsList() => [
        'Dr. Smith',
        'Dr. Johnson',
        'Dr. Williams',
        'Dr. Brown',
      ];

  List<String> _buildDiseaseTypes() => [
        'Type A',
        'Type B',
        'Type C',
        'Type D',
      ];

  List<String> _buildDiseasesList() => [
        'General Health',
        'Flu Prevention',
        'Vision Check',
        'Dental Checkup',
      ];

  List<String> _buildClassesList() => [
        'Lion Class',
        'Tiger Class',
        'Eagle Class',
        'Dragon Class',
      ];

  List<String> _buildGradesList() => [
        'Grade 1',
        'Grade 2',
        'Grade 3',
        'Grade 4',
        'Grade 5',
      ];

  List<String> _buildVaccinationTypes() => [
    'COVID-19', 'Flu Vaccine', 'Hepatitis A', 'Hepatitis B', 'MMR', 
    'Polio', 'Tetanus', 'Diphtheria', 'Pertussis', 'Chickenpox',
    'Meningitis', 'HPV', 'Pneumococcal', 'Rotavirus', 'Hib'
  ];

  List<Student> _buildStudentsList() => [
        Student(
          id: '8EG390J65A',
          name: 'Ahmed Khaled Ali Ibrahim',
          avatarColor: Color(4279450111),
          dateOfBirth: DateTime.parse('2010-10-02'),
          bloodType: 'O+',
          weightKg: 39.2,
          heightCm: 136,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'Ronald Taylor',
          firstGuardianPhone: '(903)105-7844x138',
          firstGuardianEmail: 'ejohnson@owen-campbell.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Mr. Kevin Ramirez',
          secondGuardianPhone: '151-548-4860',
          secondGuardianEmail: 'jacksondennis@rhodes.net',
          secondGuardianStatus: 'Offline',
          city: 'North Zachary',
          street: '365 Mcclure Spring',
          zipCode: '63039',
          province: 'Delaware',
          insuranceCompany: 'Allianz',
          policyNumber: 'POL0499418',
          passportIdNumber: 'Vi36090905',
          nationality: 'Egyptian',
          nationalId: '2101013573669393',
          gender: 'Male',
          phoneNumber: '+1-743-315-1141x81905',
          email: 'scott82@mendoza.com',
        ),
        Student(
          id: '8EG390J66B',
          name: 'Sara Mohamed Hassan',
          avatarColor: Color(4279286145),
          dateOfBirth: DateTime.parse('2015-02-26'),
          bloodType: 'B-',
          weightKg: 48.1,
          heightCm: 138,
          goToHospital: 'Al Salam Hospital',
          firstGuardianName: 'Laura Kennedy',
          firstGuardianPhone: '(151)240-2718',
          firstGuardianEmail: 'ijohnson@lyons-taylor.net',
          firstGuardianStatus: 'Offline',
          secondGuardianName: 'Brian Cardenas',
          secondGuardianPhone: '(492)549-0512x00087',
          secondGuardianEmail: 'jessica97@hotmail.com',
          secondGuardianStatus: 'Offline',
          city: 'East Rose',
          street: '851 Reese Heights',
          zipCode: '99340',
          province: 'Maryland',
          insuranceCompany: 'CIB',
          policyNumber: 'POL9961387',
          passportIdNumber: 'ln06876152',
          nationality: 'Egyptian',
          nationalId: '2746755682256140',
          gender: 'Female',
          phoneNumber: '301.261.2846x390',
          email: 'andrewmendoza@jones-carroll.info',
        ),
        Student(
          id: '8EG390J67C',
          name: 'Omar Ahmed Farid',
          avatarColor: Color(4293870660),
          dateOfBirth: DateTime.parse('2014-08-18'),
          bloodType: 'A-',
          weightKg: 39.8,
          heightCm: 147,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'Bruce Smith',
          firstGuardianPhone: '+1-383-541-1239',
          firstGuardianEmail: 'courtneymatthews@barnes.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Alexander Dixon',
          secondGuardianPhone: '+1-409-517-0017',
          secondGuardianEmail: 'ulee@yahoo.com',
          secondGuardianStatus: 'Online',
          city: 'South Danielville',
          street: '9053 Kevin Ridge',
          zipCode: '02378',
          province: 'New Hampshire',
          insuranceCompany: 'CIB',
          policyNumber: 'POL8991389',
          passportIdNumber: 'ok97972521',
          nationality: 'Egyptian',
          nationalId: '2628575843788600',
          gender: 'Male',
          phoneNumber: '001-685-915-3428x243',
          email: 'andreathompson@hotmail.com',
        ),
        Student(
          id: '8EG390J65E',
          name: 'Ahmed Khaled Ali Ibrahim',
          avatarColor: Color(4279450111),
          dateOfBirth: DateTime.parse('2014-01-17'),
          bloodType: 'AB+',
          weightKg: 35.4,
          heightCm: 147,
          goToHospital: 'Al Salam Hospital',
          firstGuardianName: 'Nicole Marshall',
          firstGuardianPhone: '331-178-7656',
          firstGuardianEmail: 'medinagarrett@young.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Lisa Hall',
          secondGuardianPhone: '001-605-815-5262x89726',
          secondGuardianEmail: 'taylorjohn@gmail.com',
          secondGuardianStatus: 'Online',
          city: 'Whitakerside',
          street: '70453 Kirk Course Suite 916',
          zipCode: '62213',
          province: 'Washington',
          insuranceCompany: 'Allianz',
          policyNumber: 'POL9709109',
          passportIdNumber: 'qT53122254',
          nationality: 'Egyptian',
          nationalId: '2777888206975572',
          gender: 'Male',
          phoneNumber: '471.110.3632',
          email: 'lindsaylane@williams-harris.com',
        ),
        Student(
          id: '8EGdvJ66R',
          name: 'Sara Mohamed Hassan',
          avatarColor: Color(4279286145),
          dateOfBirth: DateTime.parse('2013-09-08'),
          bloodType: 'B-',
          weightKg: 43.8,
          heightCm: 145,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'Diana Ochoa',
          firstGuardianPhone: '227.571.9987',
          firstGuardianEmail: 'rubenwashington@hotmail.com',
          firstGuardianStatus: 'Offline',
          secondGuardianName: 'Rachel Munoz PhD',
          secondGuardianPhone: '001-208-871-9718x7376',
          secondGuardianEmail: 'cgordon@pierce.info',
          secondGuardianStatus: 'Offline',
          city: 'Khanside',
          street: '7120 Brittney Passage',
          zipCode: '58606',
          province: 'Hawaii',
          insuranceCompany: 'CIB',
          policyNumber: 'POL7578448',
          passportIdNumber: 'OI47501527',
          nationality: 'Egyptian',
          nationalId: '2963636324432351',
          gender: 'Male',
          phoneNumber: '002.472.8675x12705',
          email: 'andersonrobert@gmail.com',
        ),
        Student(
          id: '8EGv390J67C',
          name: 'Omar Ahmed Farid',
          avatarColor: Color(4293870660),
          dateOfBirth: DateTime.parse('2015-01-04'),
          bloodType: 'A-',
          weightKg: 44.6,
          heightCm: 148,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'Samuel Lawson',
          firstGuardianPhone: '(137)285-4585',
          firstGuardianEmail: 'lesterjenna@baker-wu.com',
          firstGuardianStatus: 'Offline',
          secondGuardianName: 'Jesus Duran',
          secondGuardianPhone: '(559)291-3822',
          secondGuardianEmail: 'preyes@yahoo.com',
          secondGuardianStatus: 'Online',
          city: 'Lake Michaelmouth',
          street: '07101 Hester Meadows Apt. 505',
          zipCode: '47990',
          province: 'Wisconsin',
          insuranceCompany: 'Allianz',
          policyNumber: 'POL0303972',
          passportIdNumber: 'iI15345273',
          nationality: 'Egyptian',
          nationalId: '2523725007411252',
          gender: 'Male',
          phoneNumber: '700-558-8839',
          email: 'weeksaustin@hotmail.com',
        ),
        Student(
          id: '8EGz390J65A',
          name: 'Ahmed Khaled Ali Ibrahim',
          avatarColor: Color(4279450111),
          dateOfBirth: DateTime.parse('2013-11-15'),
          bloodType: 'O-',
          weightKg: 46.9,
          heightCm: 136,
          goToHospital: 'Al Salam Hospital',
          firstGuardianName: 'George Barron',
          firstGuardianPhone: '001-673-192-8823x7757',
          firstGuardianEmail: 'rogersvanessa@yahoo.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Jonathan Miller',
          secondGuardianPhone: '001-847-809-2774x032',
          secondGuardianEmail: 'mcdonaldalejandro@hotmail.com',
          secondGuardianStatus: 'Offline',
          city: 'Lake Maria',
          street: '1781 Anderson Bypass Apt. 678',
          zipCode: '61320',
          province: 'New Mexico',
          insuranceCompany: 'AXA',
          policyNumber: 'POL1041317',
          passportIdNumber: 'xP08361822',
          nationality: 'Egyptian',
          nationalId: '2716352158642562',
          gender: 'Female',
          phoneNumber: '001-403-536-2872x86196',
          email: 'juan06@evans-stone.com',
        ),
        Student(
          id: '8EG3s90J66B',
          name: 'Sara Mohamed Hassan',
          avatarColor: Color(4279286145),
          dateOfBirth: DateTime.parse('2012-03-06'),
          bloodType: 'B-',
          weightKg: 39.9,
          heightCm: 148,
          goToHospital: 'City Health Center',
          firstGuardianName: 'Christopher Watson',
          firstGuardianPhone: '+1-091-197-8573x10902',
          firstGuardianEmail: 'daviscynthia@garrett-hall.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Melanie Bryan',
          secondGuardianPhone: '199-296-4850',
          secondGuardianEmail: 'rfigueroa@gmail.com',
          secondGuardianStatus: 'Online',
          city: 'East Danafurt',
          street: '716 Jill Extension',
          zipCode: '06869',
          province: 'Minnesota',
          insuranceCompany: 'AXA',
          policyNumber: 'POL1048291',
          passportIdNumber: 'PY34010496',
          nationality: 'Egyptian',
          nationalId: '2107742253531468',
          gender: 'Male',
          phoneNumber: '+1-917-514-3766',
          email: 'caroline99@gmail.com',
        ),
        Student(
          id: '8EGv3c90J67C',
          name: 'Omar Ahmed Farid',
          avatarColor: Color(4293870660),
          dateOfBirth: DateTime.parse('2012-08-10'),
          bloodType: 'A+',
          weightKg: 35.9,
          heightCm: 139,
          goToHospital: 'City Health Center',
          firstGuardianName: 'Robert Pena',
          firstGuardianPhone: '913-588-8884x91807',
          firstGuardianEmail: 'bmiller@smith-morgan.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Shelly Robbins',
          secondGuardianPhone: '211-942-9712x5743',
          secondGuardianEmail: 'johnsonthomas@edwards.com',
          secondGuardianStatus: 'Online',
          city: 'West Erintown',
          street: '76066 Jacob Cliff',
          zipCode: '13234',
          province: 'Colorado',
          insuranceCompany: 'AXA',
          policyNumber: 'POL1613649',
          passportIdNumber: 'Ba29513094',
          nationality: 'Egyptian',
          nationalId: '2615677392091925',
          gender: 'Female',
          phoneNumber: '(362)335-0010x035',
          email: 'trose@kane-norton.com',
        ),
        Student(
          id: '8EGr390J65A',
          name: 'Ahmed Khaled Ali Ibrahim',
          avatarColor: Color(4279450111),
          dateOfBirth: DateTime.parse('2012-07-07'),
          bloodType: 'A+',
          weightKg: 37.4,
          heightCm: 148,
          goToHospital: 'Cleopatra Hospital',
          firstGuardianName: 'William Roberson',
          firstGuardianPhone: '978.654.3323x01430',
          firstGuardianEmail: 'marksmith@gmail.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Mark Smith',
          secondGuardianPhone: '854-977-3481x7716',
          secondGuardianEmail: 'stephenbowers@yahoo.com',
          secondGuardianStatus: 'Offline',
          city: 'Johnport',
          street: '660 Figueroa Spurs',
          zipCode: '22438',
          province: 'Virginia',
          insuranceCompany: 'Allianz',
          policyNumber: 'POL0720281',
          passportIdNumber: 'EA01578358',
          nationality: 'Egyptian',
          nationalId: '2835215733633856',
          gender: 'Female',
          phoneNumber: '486.821.4501x334',
          email: 'tonya49@gmail.com',
        ),
        Student(
          id: '8EGz2390J66B',
          name: 'Sara Mohamed Hassan',
          avatarColor: Color(4279286145),
          dateOfBirth: DateTime.parse('2011-07-16'),
          bloodType: 'O-',
          weightKg: 40.8,
          heightCm: 155,
          goToHospital: 'City Health Center',
          firstGuardianName: 'Barry Gill',
          firstGuardianPhone: '084-995-1606x856',
          firstGuardianEmail: 'trevor20@gmail.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Kevin Newman',
          secondGuardianPhone: '+1-907-902-9623x2500',
          secondGuardianEmail: 'qrodriguez@norton.biz',
          secondGuardianStatus: 'Offline',
          city: 'South Eddie',
          street: '75220 Jill Highway',
          zipCode: '50038',
          province: 'New Mexico',
          insuranceCompany: 'CIB',
          policyNumber: 'POL1693199',
          passportIdNumber: 'Gc47739778',
          nationality: 'Egyptian',
          nationalId: '2798161679987357',
          gender: 'Male',
          phoneNumber: '818-145-2457x96216',
          email: 'rbrown@yahoo.com',
        ),
        Student(
          id: '8EG3g90J67C',
          name: 'Omar Ahmed Farid',
          avatarColor: Color(4293870660),
          dateOfBirth: DateTime.parse('2014-04-27'),
          bloodType: 'O-',
          weightKg: 36.3,
          heightCm: 135,
          goToHospital: 'City Health Center',
          firstGuardianName: 'Yvonne Armstrong',
          firstGuardianPhone: '+1-913-474-1258x955',
          firstGuardianEmail: 'colemanthomas@gmail.com',
          firstGuardianStatus: 'Online',
          secondGuardianName: 'Lisa Cohen',
          secondGuardianPhone: '+1-469-484-4161x901',
          secondGuardianEmail: 'sandra12@bailey.com',
          secondGuardianStatus: 'Online',
          city: 'Port Robertchester',
          street: '930 Chapman Forest',
          zipCode: '96587',
          province: 'Colorado',
          insuranceCompany: 'AXA',
          policyNumber: 'POL2275709',
          passportIdNumber: 'vB26744206',
          nationality: 'Egyptian',
          nationalId: '2052745994636926',
          gender: 'Female',
          phoneNumber: '312-437-0326x279',
          email: 'staceyclarke@gmail.com',
        ),
      ];
}
