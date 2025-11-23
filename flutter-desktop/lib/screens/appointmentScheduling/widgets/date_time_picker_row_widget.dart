import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class DateTimePickerRow extends StatefulWidget {
  final ValueChanged<DateTime?>? onDateChanged;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final String? dateHint;
  final String? timeHint;

  const DateTimePickerRow({
    super.key,
    this.onDateChanged,
    this.onTimeChanged,
    this.initialDate,
    this.initialTime,
    this.dateHint = 'Select Date',
    this.timeHint = 'Select Time',
  });

  @override
  State<DateTimePickerRow> createState() => _DateTimePickerRowState();
}

class _DateTimePickerRowState extends State<DateTimePickerRow> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    
    if (_selectedDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
    
    if (_selectedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute),
      );
      _timeController.text = formattedTime;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      widget.onDateChanged?.call(pickedDate);
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        final now = DateTime.now();
        final formattedTime = DateFormat('hh:mm a').format(
          DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
        );
        _timeController.text = formattedTime;
      });
      widget.onTimeChanged?.call(pickedTime);
    }
  }

  // Helper method to create consistent input decoration
  InputDecoration _buildInputDecoration({
    required String labelText,
    required String iconPath,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(
        color: Color(0xFFA6A9AC),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            Color(0xFFA6A9AC),
            BlendMode.srcIn,
          ),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFE9E9E9),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFE9E9E9),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Color(0xFFE9E9E9),
          width: 1,
        ),
      ),
      fillColor: const Color(0xFFFBFCFD),
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  // Helper method to create picker field
  Widget _buildPickerField({
    required TextEditingController controller,
    required VoidCallback onTap,
    required String labelText,
    required String iconPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        style: const TextStyle(
          color: Color(0xFF2D2E2E),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: _buildInputDecoration(
          labelText: labelText,
          iconPath: iconPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Date Picker Field
        Expanded(
          child: _buildPickerField(
            controller: _dateController,
            onTap: _pickDate,
            labelText: widget.dateHint!,
            iconPath: 'assets/svg/date-picker.svg',
          ),
        ),
        const SizedBox(width: 12),
        // Time Picker Field
        Expanded(
          child: _buildPickerField(
            controller: _timeController,
            onTap: _pickTime,
            labelText: widget.timeHint!,
            iconPath: 'assets/svg/clock.svg',
          ),
        ),
      ],
    );
  }
}

// Extended version with more customization options
class CustomDateTimePickerRow extends StatefulWidget {
  final ValueChanged<DateTime?>? onDateChanged;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final DateTime? initialDate;
  final TimeOfDay? initialTime;
  final String? dateHint;
  final String? timeHint;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? iconColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const CustomDateTimePickerRow({
    super.key,
    this.onDateChanged,
    this.onTimeChanged,
    this.initialDate,
    this.initialTime,
    this.dateHint = 'Select Date',
    this.timeHint = 'Select Time',
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.labelColor,
    this.iconColor,
    this.borderRadius,
    this.padding,
    this.enabled = true,
  });

  @override
  State<CustomDateTimePickerRow> createState() => _CustomDateTimePickerRowState();
}

class _CustomDateTimePickerRowState extends State<CustomDateTimePickerRow> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _selectedTime = widget.initialTime;
    
    if (_selectedDate != null) {
      _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate!);
    }
    
    if (_selectedTime != null) {
      final now = DateTime.now();
      final formattedTime = DateFormat('hh:mm a').format(
        DateTime(now.year, now.month, now.day, _selectedTime!.hour, _selectedTime!.minute),
      );
      _timeController.text = formattedTime;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (!widget.enabled) return;
    
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime.now(), // Prevent selecting past dates
      lastDate: DateTime(2100),
      initialDate: _selectedDate ?? DateTime.now(),
    );
    
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
      widget.onDateChanged?.call(pickedDate);
    }
  }

  Future<void> _pickTime() async {
    if (!widget.enabled) return;
    
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
        final now = DateTime.now();
        final formattedTime = DateFormat('hh:mm a').format(
          DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute),
        );
        _timeController.text = formattedTime;
      });
      widget.onTimeChanged?.call(pickedTime);
    }
  }

  InputDecoration _buildInputDecoration({
    required String labelText,
    required String iconPath,
  }) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(
        color: widget.labelColor ?? const Color(0xFFA6A9AC),
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SvgPicture.asset(
          iconPath,
          width: 20,
          height: 20,
          colorFilter: ColorFilter.mode(
            widget.iconColor ?? const Color(0xFFA6A9AC),
            BlendMode.srcIn,
          ),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        borderSide: BorderSide(
          color: widget.borderColor ?? const Color(0xFFE9E9E9),
          width: 1,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        borderSide: BorderSide(
          color: widget.borderColor ?? const Color(0xFFE9E9E9),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        borderSide: BorderSide(
          color: widget.borderColor ?? const Color(0xFFE9E9E9),
          width: 1,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        borderSide: BorderSide(
          color: (widget.borderColor ?? const Color(0xFFE9E9E9)).withOpacity(0.5),
          width: 1,
        ),
      ),
      fillColor: widget.backgroundColor ?? const Color(0xFFFBFCFD),
      filled: true,
      contentPadding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );
  }

  Widget _buildPickerField({
    required TextEditingController controller,
    required VoidCallback onTap,
    required String labelText,
    required String iconPath,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
        boxShadow: widget.enabled ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ] : null,
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        enabled: widget.enabled,
        onTap: widget.enabled ? onTap : null,
        style: TextStyle(
          color: widget.enabled 
            ? (widget.textColor ?? const Color(0xFF2D2E2E))
            : (widget.textColor ?? const Color(0xFF2D2E2E)).withOpacity(0.5),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: _buildInputDecoration(
          labelText: labelText,
          iconPath: iconPath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildPickerField(
            controller: _dateController,
            onTap: _pickDate,
            labelText: widget.dateHint!,
            iconPath: 'assets/svg/date-picker.svg',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPickerField(
            controller: _timeController,
            onTap: _pickTime,
            labelText: widget.timeHint!,
            iconPath: 'assets/svg/clock.svg',
          ),
        ),
      ],
    );
  }
}