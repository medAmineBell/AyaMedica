import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/appointment_history_controller.dart';
import '../../../models/appointment_history_model.dart';
import 'date_time_picker_row_widget.dart';

class EditAppointmentDialog extends StatefulWidget {
  final AppointmentHistory appointment;

  const EditAppointmentDialog({Key? key, required this.appointment})
      : super(key: key);

  @override
  State<EditAppointmentDialog> createState() => _EditAppointmentDialogState();
}

class _EditAppointmentDialogState extends State<EditAppointmentDialog> {
  bool _isLoading = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _vaccineConfirmationDate;
  TimeOfDay? _vaccineConfirmationTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.appointment.appointmentDate;
    _selectedTime = TimeOfDay.fromDateTime(widget.appointment.appointmentDate);
    if (widget.appointment.vaccineTypeLastConfirmationDate != null) {
      _vaccineConfirmationDate =
          widget.appointment.vaccineTypeLastConfirmationDate;
      _vaccineConfirmationTime = TimeOfDay.fromDateTime(
          widget.appointment.vaccineTypeLastConfirmationDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Appointment',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Appointment Date & Time
              const Text(
                'Appointment Date & Time',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              DateTimePickerRow(
                initialDate: _selectedDate,
                initialTime: _selectedTime,
                onDateChanged: (date) => _selectedDate = date,
                onTimeChanged: (time) => _selectedTime = time,
              ),
              const SizedBox(height: 20),

              // Vaccine Last Confirmation Date (only for vaccine type)
              if (widget.appointment.appointmentType.toLowerCase() == 'vaccine') ...[
                const Text(
                  'Vaccine Last Confirmation Date',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                DateTimePickerRow(
                  initialDate: _vaccineConfirmationDate,
                  initialTime: _vaccineConfirmationTime,
                  onDateChanged: (date) => _vaccineConfirmationDate = date,
                  onTimeChanged: (time) => _vaccineConfirmationTime = time,
                ),
                const SizedBox(height: 20),
              ],

              const SizedBox(height: 4),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF374151),
                        side: const BorderSide(color: Color(0xFFE5E7EB)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1339FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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

  Future<void> _handleSave() async {
    setState(() => _isLoading = true);

    try {
      final body = <String, dynamic>{};

      // Appointment date & time
      if (_selectedDate != null) {
        final date = _selectedDate!;
        final time = _selectedTime ?? TimeOfDay.fromDateTime(date);
        final combined = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (combined != widget.appointment.appointmentDate) {
          body['appointmentDate'] = combined.toUtc().toIso8601String();
        }
      }

      // Vaccine last confirmation date
      if (widget.appointment.appointmentType.toLowerCase() == 'vaccine' &&
          _vaccineConfirmationDate != null) {
        final date = _vaccineConfirmationDate!;
        final time = _vaccineConfirmationTime ?? TimeOfDay.fromDateTime(date);
        final combined = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        if (combined != widget.appointment.vaccineTypeLastConfirmationDate) {
          body['vaccineLastConfirmationDate'] =
              combined.toUtc().toIso8601String();
        }
      }

      if (body.isEmpty) {
        Navigator.of(context).pop();
        return;
      }

      final controller = Get.find<AppointmentHistoryController>();
      final success =
          await controller.updateAppointment(widget.appointment.id, body);

      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
