import 'package:flutter/material.dart';
import 'package:flutter_getx_app/controllers/calendar_controller.dart';
import 'package:flutter_getx_app/models/appointment.dart';
import 'package:flutter_getx_app/models/appointment_models.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAppointmentDialog extends StatefulWidget {
  final DateTime? selectedDate;
  final String? selectedTime;
  final String? selectedDoctor;

  const CreateAppointmentDialog({
    Key? key,
    this.selectedDate,
    this.selectedTime,
    this.selectedDoctor,
  }) : super(key: key);

  @override
  State<CreateAppointmentDialog> createState() =>
      _CreateAppointmentDialogState();
}

class _CreateAppointmentDialogState extends State<CreateAppointmentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  String _selectedTime = '09:00 AM';
  String _selectedDoctor = 'Dr. Salem Said Al Ali';
  String _selectedType = 'Follow-up';

  final List<String> _availableDoctors = [
    'Dr. Salem Said Al Ali',
    'Dr. Ahmad Samir',
  ];

  final List<String> _availableTimes = [
    '09:00 AM',
    '09:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '01:00 PM',
    '01:30 PM',
    '02:00 PM',
    '02:30 PM',
    '03:00 PM',
    '03:30 PM',
    '04:00 PM',
    '04:30 PM',
  ];

  final List<String> _availableTypes = [
    'Follow-up',
    'Urgent',
    'Visit Finalized',
    'Received',
    'Cancelled',
    'Paid',
  ];

  @override
  void initState() {
    super.initState();
    // If no specific date is provided, use the current selected date from the calendar
    if (widget.selectedDate != null) {
      _selectedDate = widget.selectedDate!;
    } else {
      // Get the current selected date from the calendar controller
      try {
        final calendarController = Get.find<CalendarController>();
        _selectedDate = calendarController.selectedDate.value;
      } catch (e) {
        _selectedDate = DateTime.now();
      }
    }

    if (widget.selectedTime != null &&
        _availableTimes.contains(widget.selectedTime)) {
      _selectedTime = widget.selectedTime!;
    } else {
      _selectedTime = _availableTimes.first;
    }
    if (widget.selectedDoctor != null &&
        _availableDoctors.contains(widget.selectedDoctor)) {
      _selectedDoctor = widget.selectedDoctor!;
    } else {
      _selectedDoctor = _availableDoctors.first;
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Appointment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.colorPalette['neutral']!['90']!,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close,
                        color: AppTheme.colorPalette['neutral']!['60']!),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Patient Name
              Text('Patient Name *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _patientNameController,
                decoration: InputDecoration(
                  hintText: 'Enter patient name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (value) =>
                    value?.trim().isEmpty == true ? 'Required' : null,
              ),
              

              const SizedBox(height: 20),

              // Date and Time Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date *',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      AppTheme.colorPalette['neutral']!['30']!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(DateFormat('MMM dd, yyyy')
                                    .format(_selectedDate)),
                                Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Time *',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _availableTimes.contains(_selectedTime)
                              ? _selectedTime
                              : _availableTimes.first,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          items: _availableTimes
                              .map((time) => DropdownMenuItem(
                                  value: time, child: Text(time)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedTime = value!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Doctor Selection
              Text('Doctor *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _availableDoctors.contains(_selectedDoctor)
                    ? _selectedDoctor
                    : _availableDoctors.first,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _availableDoctors
                    .map((doctor) =>
                        DropdownMenuItem(value: doctor, child: Text(doctor)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDoctor = value!),
              ),

              const SizedBox(height: 20),

              // Type Selection
              Text('Type *',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _availableTypes.contains(_selectedType)
                    ? _selectedType
                    : _availableTypes.first,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                items: _availableTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),

              const SizedBox(height: 20),

              // Notes
              Text('Notes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Add any additional notes...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Get.back(), child: Text('Cancel')),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _createAppointment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.colorPalette['info']!['60'],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Create Appointment'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _createAppointment() {
    if (_formKey.currentState!.validate()) {
      // Ensure all values are valid
      if (!_availableTypes.contains(_selectedType) ||
          !_availableTimes.contains(_selectedTime) ||
          !_availableDoctors.contains(_selectedDoctor)) {
        Get.snackbar(
          'Error',
          'Please select valid values for all fields',
          backgroundColor: AppTheme.colorPalette['error']!['20']!,
          colorText: AppTheme.colorPalette['error']!['80']!,
        );
        return;
      }

      final controller = Get.find<CalendarController>();

      // Debug: Print the appointment details
      print('Creating appointment:');
      print('Date: ${_selectedDate}');
      print('Time: ${_selectedTime}');
      print('Doctor: ${_selectedDoctor}');
      print('Current calendar selected date: ${controller.selectedDate.value}');

      // Use the controller's createAppointment method
      controller.createAppointment(
        date: _selectedDate,
        time: _selectedTime,
        doctor: _selectedDoctor,
        type: _selectedType,
        disease: 'General Checkup',
        diseaseType: 'Routine',
        grade: 'Grade 1',
        className: 'Lion Class',
        selectedStudents: [],
        allStudents: false,
      );

      // Debug: Print all appointments after adding
      print('Total appointments: ${controller.appointments.length}');
      print(
          'Appointments for selected date: ${controller.getAppointmentsForDate(controller.selectedDate.value).length}');

      Get.back();

      Get.snackbar(
        'Success',
        'Appointment created successfully',
        backgroundColor: AppTheme.colorPalette['success']!['20'],
        colorText: AppTheme.colorPalette['success']!['80'],
      );
    }
  }
}
