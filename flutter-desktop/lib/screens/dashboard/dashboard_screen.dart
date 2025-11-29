import 'package:flutter/material.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/bar_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/line_chart_widget.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_sample.dart';
import 'package:flutter_getx_app/screens/dashboard/widgets/charts/pie_chart_widget.dart';
import 'package:flutter_getx_app/shared/widgets/breadcrumb_widget.dart';
import 'package:flutter_svg/svg.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey filterButtonKey = GlobalKey();
    return Container(
      color: const Color(0xFFFBFCFD),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                80, // Subtract navbar height
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          color: Color(0xFF2D2E2E) /* Text-Text-100 */,
                          fontSize: 20,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w700,
                          height: 1.40,
                        ),
                      ),
                      BreadcrumbWidget(
                        items: [
                          BreadcrumbItem(label: 'Ayamedica portal'),
                          BreadcrumbItem(label: 'Dashboard'),
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  // Download Button
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: InkWell(
                      onTap: () {
                        print('Export data pressed');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/download.svg', // your SVG path
                            width: 18,
                            height: 18,
                            color: const Color(0xFF7A7A7A), // icon color
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Export data',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  // Filters Button
                  Container(
                    key: filterButtonKey,
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: InkWell(
                      onTap: () {
                        showFilterDropdown(context, filterButtonKey);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/filter-2.svg', // your SVG path
                            width: 18,
                            height: 18,
                            color: const Color(0xFF7A7A7A), // icon color
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Filters',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 0),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFC2E53),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              "1",
                              style: TextStyle(
                                color: Color(0xFFF9F9F9),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight:
                                    true ? FontWeight.w700 : FontWeight.w500,
                                height: 1.58,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // First row: 1/3 + 2/3

              const SizedBox(
                height: 350,
                child: Row(
                  children: const [
                    Expanded(
                      flex: 1,
                      child: PieChartWidget(),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      flex: 2,
                      child: LineChartWidget(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Second row: 2/3 + 1/3
              const SizedBox(
                height: 350, // Fixed height for second row
                child: Row(
                  children: const [
                    Expanded(
                      flex: 2,
                      child: BarChartWidget(),
                    ),
                    SizedBox(width: 32),
                    Expanded(
                      flex: 1,
                      child: PieChartSample(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final SvgPicture? icon;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;

  const OutlineButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.borderColor = const Color(0xFFB8B8B8),
    this.textColor = const Color(0xFF7A7A7A),
    this.iconColor = const Color(0xFF7A7A7A),
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.w500,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        padding: padding,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: fontWeight,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom download icon to match the image
class DownloadIcon extends StatelessWidget {
  final Color color;
  final double size;

  const DownloadIcon({
    super.key,
    this.color = const Color(0xFF7A7A7A),
    this.size = 18.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: DownloadIconPainter(color: color),
    );
  }
}

class DownloadIconPainter extends CustomPainter {
  final Color color;

  DownloadIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw vertical line (arrow body)
    canvas.drawLine(
      Offset(center.dx, size.height * 0.2),
      Offset(center.dx, size.height * 0.75),
      paint,
    );

    // Draw arrow head
    canvas.drawLine(
      Offset(center.dx - size.width * 0.15, size.height * 0.6),
      Offset(center.dx, size.height * 0.75),
      paint,
    );

    canvas.drawLine(
      Offset(center.dx + size.width * 0.15, size.height * 0.6),
      Offset(center.dx, size.height * 0.75),
      paint,
    );

    // Draw base line
    canvas.drawLine(
      Offset(size.width * 0.25, size.height * 0.85),
      Offset(size.width * 0.75, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ------re-e-e-e--e
class FilterDropdownOverlay extends StatefulWidget {
  const FilterDropdownOverlay({Key? key}) : super(key: key);

  @override
  State<FilterDropdownOverlay> createState() => _FilterDropdownOverlayState();
}

class _FilterDropdownOverlayState extends State<FilterDropdownOverlay> {
  // Branch section
  bool isBranchExpanded = true;
  List<String> branches = ['branch 1', 'branch 2', 'branch 3', 'branch 4'];
  Set<String> selectedBranches = {};
  bool showAllBranches = false;

  // Grades section
  bool isGradesExpanded = true;
  List<String> grades = ['Grade 1', 'Grade 2', 'Grade 3'];
  Set<String> selectedGrades = {};

  // Classes section
  bool isClassesExpanded = true;
  List<String> classes = [
    'Lions',
    'Butterflies',
    'Tigers',
    'Cats',
    'Eagles',
    'Pandas'
  ];
  Set<String> selectedClasses = {'Cats'};
  bool showAllClasses = false;
  String classSearchQuery = '';

  // Other section
  bool isOtherExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 272,
      height: MediaQuery.of(context).size.height * 0.8,
      //constraints: const BoxConstraints(maxHeight: ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2E2E),
                  ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1339FF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              //padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Branch Section
                  _buildExpandableSection(
                    title: 'Branch',
                    isExpanded: isBranchExpanded,
                    onToggle: () {
                      setState(() {
                        isBranchExpanded = !isBranchExpanded;
                      });
                    },
                    child: Column(
                      children: [
                        ...branches
                            .take(showAllBranches ? branches.length : 2)
                            .map((branch) => _buildCheckboxItem(
                                  label: branch,
                                  isSelected: selectedBranches.contains(branch),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedBranches.add(branch);
                                      } else {
                                        selectedBranches.remove(branch);
                                      }
                                    });
                                  },
                                )),
                        if (branches.length > 2)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  showAllBranches = !showAllBranches;
                                });
                              },
                              child: Text(
                                showAllBranches ? 'Show less' : 'Show more',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1339FF),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // const SizedBox(height: 16),

                  // Grades Section
                  _buildExpandableSection(
                    title: 'Grades',
                    isExpanded: isGradesExpanded,
                    onToggle: () {
                      setState(() {
                        isGradesExpanded = !isGradesExpanded;
                      });
                    },
                    child: Column(
                      children: grades
                          .map((grade) => _buildCheckboxItem(
                                label: grade,
                                isSelected: selectedGrades.contains(grade),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedGrades.add(grade);
                                    } else {
                                      selectedGrades.remove(grade);
                                    }
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),

                  // const SizedBox(height: 16),

                  // Classes Section
                  _buildExpandableSection(
                    title: 'Classes',
                    isExpanded: isClassesExpanded,
                    onToggle: () {
                      setState(() {
                        isClassesExpanded = !isClassesExpanded;
                      });
                    },
                    child: Column(
                      children: [
                        // Search field
                        Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(0xFF1339FF),
                              width: 1,
                            ),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                classSearchQuery = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search',
                              hintStyle: TextStyle(
                                color: Color(0xFFB8B8B8),
                                fontSize: 16,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: Icon(
                                Icons.search,
                                color: Color(0xFFB8B8B8),
                              ),
                            ),
                          ),
                        ),
                        // Class items
                        ...classes
                            .where((c) => c
                                .toLowerCase()
                                .contains(classSearchQuery.toLowerCase()))
                            .take(showAllClasses ? classes.length : 4)
                            .map((className) => _buildCheckboxItem(
                                  label: className,
                                  isSelected:
                                      selectedClasses.contains(className),
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedClasses.add(className);
                                      } else {
                                        selectedClasses.remove(className);
                                      }
                                    });
                                  },
                                )),
                        if (classes.length > 4)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  showAllClasses = !showAllClasses;
                                });
                              },
                              child: Text(
                                showAllClasses ? 'Show less' : 'Show more',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1339FF),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // const SizedBox(height: 16),

                  // Other Section
                  _buildExpandableSection(
                    title: 'Other',
                    isExpanded: isOtherExpanded,
                    onToggle: () {
                      setState(() {
                        isOtherExpanded = !isOtherExpanded;
                      });
                    },
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2E2E),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFF2D2E2E),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required String label,
    required bool isSelected,
    required Function(bool?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: isSelected,
              onChanged: onChanged,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              activeColor: const Color(0xFF1339FF),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFF1339FF)
                    : const Color(0xFFD1D5DB),
                width: 2,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isSelected
                  ? const Color(0xFF2D2E2E)
                  : const Color(0xFFB8B8B8),
            ),
          ),
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      selectedBranches.clear();
      selectedGrades.clear();
      selectedClasses.clear();
      classSearchQuery = '';
    });
  }
}

// Function to show the filter dropdown overlay
void showFilterDropdown(BuildContext context, GlobalKey buttonKey) {
  final RenderBox renderBox =
      buttonKey.currentContext!.findRenderObject() as RenderBox;
  final offset = renderBox.localToGlobal(Offset.zero);
  final size = renderBox.size;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withOpacity(0.3),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          // Positioned overlay
          Positioned(
            top: offset.dy + size.height + 8,
            right: MediaQuery.of(context).size.width - offset.dx - size.width,
            child: Material(
              color: Colors.transparent,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 200),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: 0.9 + (0.1 * value),
                    alignment: Alignment.topRight,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: const FilterDropdownOverlay(),
              ),
            ),
          ),
        ],
      );
    },
  );
}
