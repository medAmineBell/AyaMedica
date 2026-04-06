import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class SchoolYearCalendarScreen extends StatefulWidget {
  const SchoolYearCalendarScreen({Key? key}) : super(key: key);

  @override
  State<SchoolYearCalendarScreen> createState() =>
      _SchoolYearCalendarScreenState();
}

class _SchoolYearCalendarScreenState extends State<SchoolYearCalendarScreen> {
  String _selectedBranch = 'All branches';
  List<String> _selectedBranches = ['All branches'];
  final List<String> _branches = [
    'All branches',
    'Branch name 1',
    'Branch name 2',
    'Branch name 3',
  ];

  // Term dates
  DateTime? _firstTermStart;
  DateTime? _firstTermEnd;
  DateTime? _secondTermStart;
  DateTime? _secondTermEnd;
  DateTime? _thirdTermStart;
  DateTime? _thirdTermEnd;
  DateTime? _fourthTermStart;
  DateTime? _fourthTermEnd;

  // Weekend days
  Set<String> _selectedWeekendDays = {'Fri', 'Sat', 'Sun'};
  final List<String> _weekdays = [
    'Friday',
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday'
  ];
  final Map<String, String> _weekdayShort = {
    'Friday': 'Fri',
    'Saturday': 'Sat',
    'Sunday': 'Sun',
    'Monday': 'Mon',
    'Tuesday': 'Tue',
    'Wednesday': 'Wed',
    'Thursday': 'Thu',
  };

  // Shift times
  TimeOfDay? _morningShiftStart;
  TimeOfDay? _morningShiftEnd;
  TimeOfDay? _eveningShiftStart;
  TimeOfDay? _eveningShiftEnd;

  String _consultationTimeSlot = '30 min';
  final List<String> _timeSlots = ['15 min', '30 min', '45 min', '60 min'];

  // Holiday form
  String _holidayTitle = '';
  DateTime? _holidayStartDate;
  DateTime? _holidayEndDate;

  // Holidays
  final List<Map<String, dynamic>> _holidays = [
    {
      'title': 'National Independence day',
      'startDate': DateTime(2026, 7, 26),
      'endDate': DateTime(2026, 7, 26),
      'days': 1,
    },
  ];

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Start time';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getWeekendDaysText() {
    if (_selectedWeekendDays.isEmpty) return 'Fri, Sat, Sun';
    return _selectedWeekendDays.join(', ');
  }

  String _getBranchesText() {
    if (_selectedBranches.contains('All branches')) {
      return 'All branches';
    }
    if (_selectedBranches.isEmpty) return 'All branches';
    if (_selectedBranches.length == 1) return _selectedBranches[0];
    return '${_selectedBranches.length} branches selected';
  }

  Future<void> _pickDate(
      Function(DateTime) onPicked, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  Future<void> _pickTime(
      Function(TimeOfDay) onPicked, TimeOfDay? initialTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  void _showBranchSelectionDialog() {
    List<String> tempSelected = List.from(_selectedBranches);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Select Branches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _branches.map((branch) {
                    return CheckboxListTile(
                      title: Text(branch),
                      value: tempSelected.contains(branch),
                      onChanged: (bool? value) {
                        setDialogState(() {
                          if (value == true) {
                            if (branch == 'All branches') {
                              tempSelected.clear();
                              tempSelected.add('All branches');
                            } else {
                              tempSelected.remove('All branches');
                              tempSelected.add(branch);
                            }
                          } else {
                            tempSelected.remove(branch);
                            if (tempSelected.isEmpty) {
                              tempSelected.add('All branches');
                            }
                          }
                        });
                      },
                      activeColor: const Color(0xFF0066FF),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedBranches = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showWeekendDaysDialog() {
    final tempSelected = Set<String>.from(_selectedWeekendDays);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Select Weekend Days',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _weekdays.map((day) {
                  final shortDay = _weekdayShort[day]!;
                  return CheckboxListTile(
                    title: Text(day),
                    value: tempSelected.contains(shortDay),
                    onChanged: (bool? value) {
                      setDialogState(() {
                        if (value == true) {
                          tempSelected.add(shortDay);
                        } else {
                          tempSelected.remove(shortDay);
                        }
                      });
                    },
                    activeColor: const Color(0xFF0066FF),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedWeekendDays = tempSelected;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfigurationHeader(),
                  const SizedBox(height: 24),
                  _buildMainFormSection(),
                  const SizedBox(height: 32),
                  _buildHolidaysSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'School & year calendar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Ayamedica portal',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Resources',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              const Text(
                'School & year calendar',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0066FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationHeader() {
    return Row(
      children: [
        const Text(
          'Configure school year and calendar for',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _showBranchSelectionDialog,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getBranchesText(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0066FF),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF0066FF),
                size: 24,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainFormSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // School year and break section header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'School year and break',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),

          // School year fields
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // First term
                _buildCompactDateRow(
                  label: 'First term  start and end dates',
                  isRequired: true,
                  startDate: _firstTermStart,
                  endDate: _firstTermEnd,
                  onStartPicked: (date) => _firstTermStart = date,
                  onEndPicked: (date) => _firstTermEnd = date,
                ),
                const SizedBox(height: 16),

                // Second term
                _buildCompactDateRow(
                  label: 'Second term start and end dates (If applicable)',
                  startDate: _secondTermStart,
                  endDate: _secondTermEnd,
                  onStartPicked: (date) => _secondTermStart = date,
                  onEndPicked: (date) => _secondTermEnd = date,
                ),
                const SizedBox(height: 16),

                // Third term
                _buildCompactDateRow(
                  label: 'Third term start and end dates (If applicable)',
                  startDate: _thirdTermStart,
                  endDate: _thirdTermEnd,
                  onStartPicked: (date) => _thirdTermStart = date,
                  onEndPicked: (date) => _thirdTermEnd = date,
                ),
                const SizedBox(height: 16),

                // Fourth term
                _buildCompactDateRow(
                  label: 'Fourth term start and end dates (If applicable)',
                  startDate: _fourthTermStart,
                  endDate: _fourthTermEnd,
                  onStartPicked: (date) => _fourthTermStart = date,
                  onEndPicked: (date) => _fourthTermEnd = date,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: RichText(
                        text: const TextSpan(
                          text: 'School Weekend days',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 292, // 140 + 12 + 140 to match two fields
                      height: 32,
                      child: InkWell(
                        onTap: _showWeekendDaysDialog,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFBFCFD),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE9E9E9)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 13,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getWeekendDaysText(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF374151),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // School clinic operating section header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F6),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_outlined,
                  size: 18,
                  color: Colors.grey[700],
                ),
                const SizedBox(width: 8),
                const Text(
                  'School clinic operating days and hours',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),

          // Clinic operating fields
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Morning shift
                _buildCompactTimeRow(
                  label: 'Morning shift start and end time',
                  isRequired: true,
                  startTime: _morningShiftStart,
                  endTime: _morningShiftEnd,
                  onStartPicked: (time) => _morningShiftStart = time,
                  onEndPicked: (time) => _morningShiftEnd = time,
                ),
                const SizedBox(height: 16),

                // Evening shift
                _buildCompactTimeRow(
                  label: 'evening shift start and end time',
                  startTime: _eveningShiftStart,
                  endTime: _eveningShiftEnd,
                  onStartPicked: (time) => _eveningShiftStart = time,
                  onEndPicked: (time) => _eveningShiftEnd = time,
                ),
                const SizedBox(height: 16),

                // Consultation time slot
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: RichText(
                        text: const TextSpan(
                          text:
                              'Consultation time slot (for checkup, followup etc.)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF374151),
                          ),
                          children: [
                            TextSpan(
                              text: ' *',
                              style: TextStyle(color: Color(0xFFDC2626)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 292,
                      height: 32,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBFCFD),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFE9E9E9)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _consultationTimeSlot,
                            isExpanded: true,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Color(0xFF0066FF), size: 18),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w400,
                            ),
                            items: _timeSlots.map((slot) {
                              return DropdownMenuItem<String>(
                                value: slot,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 13,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(slot),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(
                                    () => _consultationTimeSlot = newValue);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDateRow({
    required String label,
    bool isRequired = false,
    DateTime? startDate,
    DateTime? endDate,
    required Function(DateTime) onStartPicked,
    required Function(DateTime) onEndPicked,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 140,
          height: 32,
          child: InkWell(
            onTap: () => _pickDate(onStartPicked, startDate),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      startDate != null ? _formatDate(startDate) : 'Start date',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: startDate != null
                            ? const Color(0xFF374151)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          height: 32,
          child: InkWell(
            onTap: () => _pickDate(onEndPicked, endDate),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 13,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      endDate != null ? _formatDate(endDate) : 'End date',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: endDate != null
                            ? const Color(0xFF374151)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactTimeRow({
    required String label,
    bool isRequired = false,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    required Function(TimeOfDay) onStartPicked,
    required Function(TimeOfDay) onEndPicked,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
              children: isRequired
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Color(0xFFDC2626)),
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 140,
          height: 32,
          child: InkWell(
            onTap: () => _pickTime(onStartPicked, startTime),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      startTime != null ? _formatTime(startTime) : 'Start time',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: startTime != null
                            ? const Color(0xFF374151)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          height: 32,
          child: InkWell(
            onTap: () => _pickTime(onEndPicked, endTime),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE9E9E9)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 13,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      endTime != null ? _formatTime(endTime) : 'End time',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: endTime != null
                            ? const Color(0xFF374151)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHolidaysSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Holidays and national holidays',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: const TextSpan(
                              text: 'Holiday title',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFCFD),
                              borderRadius: BorderRadius.circular(12),
                              border:
                                  Border.all(color: const Color(0xFFE9E9E9)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.celebration_outlined,
                                  size: 20,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Independence day',
                                      hintStyle: TextStyle(
                                        color: Color(0xFF9CA3AF),
                                      ),
                                    ),
                                    onChanged: (value) => _holidayTitle = value,
                                  ),
                                ),
                              ],
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
                          RichText(
                            text: const TextSpan(
                              text: 'Start date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _pickDate(
                              (date) => _holidayStartDate = date,
                              _holidayStartDate,
                            ),
                            child: Container(
                              height: 52,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBFCFD),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE9E9E9)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 20, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _holidayStartDate != null
                                          ? _formatDate(_holidayStartDate!)
                                          : 'Start date',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: _holidayStartDate != null
                                            ? const Color(0xFF374151)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFF0066FF)),
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
                          RichText(
                            text: const TextSpan(
                              text: 'End date',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF374151),
                              ),
                              children: [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Color(0xFFDC2626)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _pickDate(
                              (date) => _holidayEndDate = date,
                              _holidayEndDate,
                            ),
                            child: Container(
                              height: 52,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBFCFD),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFFE9E9E9)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 20, color: Color(0xFF9CA3AF)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _holidayEndDate != null
                                          ? _formatDate(_holidayEndDate!)
                                          : 'End date',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: _holidayEndDate != null
                                            ? const Color(0xFF374151)
                                            : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.arrow_drop_down,
                                      color: Color(0xFF0066FF)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Padding(
                      padding: const EdgeInsets.only(top: 30),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Add holiday logic
                        },
                        icon: const Icon(
                          Icons.add_box_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Add',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Saved holidays',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: [
                _buildHolidayTableHeader(),
                ..._holidays.map((holiday) => _buildHolidayRow(holiday)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: const [
          Expanded(
            flex: 3,
            child: Text(
              'Holiday title',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Start day',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'End date',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Total number of days',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Actions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHolidayRow(Map<String, dynamic> holiday) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              holiday['title'],
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${holiday['startDate'].day} ${DateFormat('MMMM').format(holiday['startDate'])}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${holiday['endDate'].day} ${DateFormat('MMMM').format(holiday['endDate'])}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDEEBFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${holiday['days']} day',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0066FF),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      size: 20, color: Color(0xFFEF4444)),
                  onPressed: () {
                    // Delete holiday
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 20, color: Color(0xFF6B7280)),
                  onPressed: () {
                    // Edit holiday
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
