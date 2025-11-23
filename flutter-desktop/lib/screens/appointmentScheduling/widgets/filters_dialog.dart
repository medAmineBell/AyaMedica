import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FiltersDialog extends StatefulWidget {
  const FiltersDialog({Key? key}) : super(key: key);

  @override
  State<FiltersDialog> createState() => _FiltersDialogState();
}

class _FiltersDialogState extends State<FiltersDialog> {
  final TextEditingController _classesController = TextEditingController();
  final TextEditingController _gradesController = TextEditingController();
  
  // Filter states
  bool _isDateRangeExpanded = true;
  bool _isGradesExpanded = true;
  bool _isClassesExpanded = true;
  bool _isOtherExpanded = false;
  
  // Date range
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Selected filters
  Set<String> _selectedClasses = {};
  Set<String> _selectedGrades = {};
  Set<String> _selectedOther = {};
  
  // Autocomplete filtering
  String _gradesQuery = '';
  String _classesQuery = '';
  
  // Sample data
  final List<String> _allClasses = [
    'Lions',
    'Butterflies', 
    'Tigers',
    'Cats',
    'Eagles',
    'Dolphins',
    'Bears',
    'Wolves'
  ];
  
  final List<String> _allGrades = [
    'Grade 1',
    'Grade 2', 
    'Grade 3',
    'Grade 4',
    'Grade 5'
  ];
  
  final List<String> _otherOptions = [
    'Urgent',
    'Follow-up',
    'Vaccination',
    'Check-up'
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with some default selections
    _selectedClasses.add('Cats');
  }

  @override
  void dispose() {
    _classesController.dispose();
    _gradesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearAllFilters,
                      child: const Text(
                        'Clear filters',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date Range Section
                    _buildCollapsibleSection(
                      title: 'Date range',
                      isExpanded: _isDateRangeExpanded,
                      onToggle: () => setState(() => _isDateRangeExpanded = !_isDateRangeExpanded),
                      child: _buildDateRangeSection(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Grades Section
                    _buildCollapsibleSection(
                      title: 'Grades',
                      isExpanded: _isGradesExpanded,
                      onToggle: () => setState(() => _isGradesExpanded = !_isGradesExpanded),
                      child: _buildGradesSection(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Classes Section
                    _buildCollapsibleSection(
                      title: 'Classes',
                      isExpanded: _isClassesExpanded,
                      onToggle: () => setState(() => _isClassesExpanded = !_isClassesExpanded),
                      child: _buildClassesSection(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Other Section
                    _buildCollapsibleSection(
                      title: 'Other',
                      isExpanded: _isOtherExpanded,
                      onToggle: () => setState(() => _isOtherExpanded = !_isOtherExpanded),
                      child: _buildOtherSection(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Apply Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Apply filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: const Color(0xFF6B7280),
                size: 20,
              ),
            ],
          ),
        ),
        if (isExpanded) ...[
          const SizedBox(height: 12),
          child,
        ],
      ],
    );
  }

  Widget _buildDateRangeSection() {
    return Column(
      children: [
        // Start Date Picker
        GestureDetector(
          onTap: () => _selectStartDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3B82F6)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _startDate != null 
                        ? _formatDate(_startDate!)
                        : 'Select start date',
                    style: TextStyle(
                      color: _startDate != null 
                          ? const Color(0xFF111827) 
                          : const Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // End Date Picker
        GestureDetector(
          onTap: () => _selectEndDate(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF3B82F6)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _endDate != null 
                        ? _formatDate(_endDate!)
                        : 'Select end date',
                    style: TextStyle(
                      color: _endDate != null 
                          ? const Color(0xFF111827) 
                          : const Color(0xFF9CA3AF),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradesSection() {
    final filteredGrades = _allGrades
        .where((grade) => grade.toLowerCase().contains(_gradesQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF3B82F6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _gradesController,
            onChanged: (value) {
              setState(() {
                _gradesQuery = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search grades',
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        
        // Selected grades chips
        if (_selectedGrades.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedGrades.map((grade) {
              return Chip(
                label: Text(
                  grade,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: const Color(0xFF3B82F6),
                deleteIcon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedGrades.remove(grade);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        
        // Show checkboxes when no search query or show filtered results
        if (_gradesQuery.isEmpty) ...[
          // Show all grades as checkboxes
          ..._allGrades.map((grade) {
            final isSelected = _selectedGrades.contains(grade);
            return CheckboxListTile(
              title: Text(
                grade,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedGrades.add(grade);
                  } else {
                    _selectedGrades.remove(grade);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF3B82F6),
            );
          }).toList(),
        ] else if (filteredGrades.isNotEmpty) ...[
          // Show filtered results as checkboxes
          ...filteredGrades.map((grade) {
            final isSelected = _selectedGrades.contains(grade);
            return CheckboxListTile(
              title: Text(
                grade,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedGrades.add(grade);
                  } else {
                    _selectedGrades.remove(grade);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF3B82F6),
            );
          }).toList(),
        ] else ...[
          // No results found
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No grades found',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildClassesSection() {
    final filteredClasses = _allClasses
        .where((className) => className.toLowerCase().contains(_classesQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF3B82F6)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _classesController,
            onChanged: (value) {
              setState(() {
                _classesQuery = value;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Search classes',
              hintStyle: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Color(0xFF9CA3AF),
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        
        // Selected classes chips
        if (_selectedClasses.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedClasses.map((className) {
              return Chip(
                label: Text(
                  className,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                backgroundColor: const Color(0xFF3B82F6),
                deleteIcon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
                onDeleted: () {
                  setState(() {
                    _selectedClasses.remove(className);
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],
        
        // Show checkboxes when no search query or show filtered results
        if (_classesQuery.isEmpty) ...[
          // Show all classes as checkboxes
          ..._allClasses.map((className) {
            final isSelected = _selectedClasses.contains(className);
            return CheckboxListTile(
              title: Text(
                className,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedClasses.add(className);
                  } else {
                    _selectedClasses.remove(className);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF3B82F6),
            );
          }).toList(),
        ] else if (filteredClasses.isNotEmpty) ...[
          // Show filtered results as checkboxes
          ...filteredClasses.map((className) {
            final isSelected = _selectedClasses.contains(className);
            return CheckboxListTile(
              title: Text(
                className,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
              ),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedClasses.add(className);
                  } else {
                    _selectedClasses.remove(className);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: const Color(0xFF3B82F6),
            );
          }).toList(),
        ] else ...[
          // No results found
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'No classes found',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOtherSection() {
    return Column(
      children: _otherOptions.map((option) {
        final isSelected = _selectedOther.contains(option);
        return CheckboxListTile(
          title: Text(
            option,
            style: TextStyle(
              color: isSelected ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
              fontSize: 14,
            ),
          ),
          value: isSelected,
          onChanged: (bool? value) {
            setState(() {
              if (value == true) {
                _selectedOther.add(option);
              } else {
                _selectedOther.remove(option);
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF3B82F6),
        );
      }).toList(),
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, clear it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF3B82F6),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF111827),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _clearAllFilters() {
    setState(() {
      _selectedClasses.clear();
      _selectedGrades.clear();
      _selectedOther.clear();
      _startDate = null;
      _endDate = null;
      _classesController.clear();
      _gradesController.clear();
      _classesQuery = '';
      _gradesQuery = '';
    });
  }

  void _applyFilters() {
    // Here you would apply the filters to your controller
    Get.back();
    
    // Show a snackbar with applied filters
    final appliedFilters = <String>[];
    
    if (_startDate != null || _endDate != null) {
      String dateRange = '';
      if (_startDate != null && _endDate != null) {
        dateRange = 'Date Range: ${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}';
      } else if (_startDate != null) {
        dateRange = 'From: ${_formatDate(_startDate!)}';
      } else if (_endDate != null) {
        dateRange = 'Until: ${_formatDate(_endDate!)}';
      }
      appliedFilters.add(dateRange);
    }
    
    if (_selectedClasses.isNotEmpty) {
      appliedFilters.add('Classes: ${_selectedClasses.join(', ')}');
    }
    if (_selectedGrades.isNotEmpty) {
      appliedFilters.add('Grades: ${_selectedGrades.join(', ')}');
    }
    if (_selectedOther.isNotEmpty) {
      appliedFilters.add('Other: ${_selectedOther.join(', ')}');
    }
    
    if (appliedFilters.isNotEmpty) {
      Get.snackbar(
        'Filters Applied',
        appliedFilters.join('\n'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
