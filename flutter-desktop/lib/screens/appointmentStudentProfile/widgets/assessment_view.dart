import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getx_app/models/appointment_history_model.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../controllers/assessment_controller.dart';

class AssessmentView extends StatefulWidget {
  final AppointmentHistory appointment;

  const AssessmentView({super.key, required this.appointment});

  @override
  State<AssessmentView> createState() => _AssessmentViewState();
}

class _AssessmentViewState extends State<AssessmentView> {
  late final AssessmentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AssessmentController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingRecord.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(48),
            child: CircularProgressIndicator(),
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Assessments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildEditableVitals(),
            const SizedBox(height: 24),
            _buildSectionLabel("Chief complaint", required: true),
            const SizedBox(height: 8),
            _buildSearchableField(
              textController: controller.complaintSearchController,
              results: controller.complaints,
              isLoading: controller.isLoadingComplaints,
              onChanged: controller.onComplaintSearchChanged,
              onSelected: controller.addComplaint,
              displayKey: 'name_en',
            ),
            const SizedBox(height: 8),
            Obx(() => _buildTagsWrap(
                  items: controller.selectedComplaints,
                  displayKey: 'name_en',
                  onRemove: controller.removeComplaint,
                )),
            const SizedBox(height: 24),
            const Text("Examination",
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            _buildMultilineField("Examination details"),
            const SizedBox(height: 24),
            const Text("Assessment",
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel("Suspected disease(s)",
                          required: true),
                      _buildSearchableField(
                        textController: controller.diseaseSearchController,
                        results: controller.suspectedDiseases,
                        isLoading: controller.isLoadingDiseases,
                        onChanged: controller.onDiseaseSearchChanged,
                        onSelected: controller.addDisease,
                        displayKey: 'name_en',
                      ),
                      const SizedBox(height: 8),
                      Obx(() => _buildTagsWrap(
                            items: controller.selectedDiseases,
                            displayKey: 'name_en',
                            onRemove: controller.removeDisease,
                          )),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel("Recommendations(s)", required: true),
                      _buildSearchableField(
                        textController:
                            controller.recommendationSearchController,
                        results: controller.recommendations,
                        isLoading: controller.isLoadingRecommendations,
                        onChanged: controller.onRecommendationSearchChanged,
                        onSelected: controller.addRecommendation,
                        displayKey: 'name',
                      ),
                      const SizedBox(height: 8),
                      Obx(() => _buildTagsWrap(
                            items: controller.selectedRecommendations,
                            displayKey: 'name',
                            onRemove: controller.removeRecommendation,
                          )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  // Tracks which vital fields have been blurred for validation
  final Set<String> _blurredVitalFields = {};

  String? _validateVitalRange(String value, double min, double max, String label) {
    if (value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Invalid $label';
    if (parsed < min) return '$label must be at least ${min.toStringAsFixed(min == min.roundToDouble() ? 0 : 1)}';
    if (parsed > max) return '$label must be at most ${max.toStringAsFixed(max == max.roundToDouble() ? 0 : 1)}';
    return null;
  }

  Widget _buildEditableVitals() {
    return Row(
      children: [
        _buildSingleVitalCard('Temperature', 'assets/svg/blood_pressure_01.svg',
            controller.temperatureController,
            min: 30, max: 45, validationKey: 'temperature'),
        const SizedBox(width: 8),
        _buildSingleVitalCard('Heart Rate', 'assets/svg/heart_rate_01.svg',
            controller.heartRateController,
            min: 20, max: 300, validationKey: 'heartRate'),
        const SizedBox(width: 8),
        _buildSingleVitalCard('Respiratory Rate', 'assets/svg/lungs.svg',
            controller.respiratoryRateController,
            min: 5, max: 80, validationKey: 'respiratoryRate'),
        const SizedBox(width: 8),
        _buildSingleVitalCard('Blood Pressure', 'assets/svg/blood_pressure_02.svg',
            controller.bloodPressureController),
        const SizedBox(width: 8),
        _buildSingleVitalCard(
            'Oxygen Saturation', 'assets/svg/Heading.svg',
            controller.oxygenSaturationController,
            suffix: '%', min: 50, max: 100, validationKey: 'oxygenSaturation'),
        const SizedBox(width: 8),
        _buildSingleVitalCard('Blood Glucose', 'assets/svg/blood_glucose.svg',
            controller.bloodGlucoseController,
            min: 10, max: 800, validationKey: 'bloodGlucose'),
        const SizedBox(width: 8),
        _buildDualVitalCard(
          'Height & weight',
          'assets/svg/weight.svg',
          controller.heightController,
          controller.weightController,
        ),
      ],
    );
  }

  Widget _buildSingleVitalCard(
    String title,
    String svgPath,
    TextEditingController textController, {
    String? suffix,
    double? min,
    double? max,
    String? validationKey,
  }) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE4E9ED)),
        ),
        child: Column(
          children: [
            SvgPicture.asset(svgPath, width: 24, height: 24,
                colorFilter: const ColorFilter.mode(
                    Color(0xFF1339FF), BlendMode.srcIn)),
            const SizedBox(height: 4),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFFA6A9AC),
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            _buildVitalInput(textController,
                suffix: suffix, min: min, max: max, validationKey: validationKey, label: title),
          ],
        ),
      ),
    );
  }

  Widget _buildDualVitalCard(
    String title,
    String svgPath,
    TextEditingController controller1,
    TextEditingController controller2,
  ) {
    return Expanded(
      child: Container(
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE4E9ED)),
        ),
        child: Column(
          children: [
            SvgPicture.asset(svgPath, width: 24, height: 24,
                colorFilter: const ColorFilter.mode(
                    Color(0xFF1339FF), BlendMode.srcIn)),
            const SizedBox(height: 4),
            Text(title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFFA6A9AC),
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
            const Spacer(),
            Row(
              children: [
                Expanded(child: _buildVitalInput(controller1,
                    min: 30, max: 250, validationKey: 'height', label: 'Height')),
                const SizedBox(width: 4),
                Expanded(child: _buildVitalInput(controller2,
                    min: 1, max: 300, validationKey: 'weight', label: 'Weight')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalInput(TextEditingController textController,
      {String? suffix, double? min, double? max, String? validationKey, String? label}) {
    final hasValidation = min != null || max != null;
    final key = validationKey ?? label ?? '';
    final isBlurred = _blurredVitalFields.contains(key);

    String? errorText;
    if (hasValidation && isBlurred) {
      errorText = _validateVitalRange(textController.text, min ?? 0, max ?? double.infinity, label ?? key);
    }
    final isError = errorText != null;

    return Tooltip(
      message: errorText ?? '',
      child: SizedBox(
        height: 30,
        child: Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus && hasValidation) {
              setState(() {
                _blurredVitalFields.remove(key);
              });
            } else if (!hasFocus && hasValidation) {
              setState(() {
                _blurredVitalFields.add(key);
              });
            }
          },
          child: TextField(
            controller: textController,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d./]')),
            ],
            onChanged: (_) {
              if (isBlurred && hasValidation) {
                setState(() {});
              }
            },
            style: TextStyle(
                color: isError ? const Color(0xFFDC2626) : const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              suffixText: suffix,
              suffixStyle: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w500),
              filled: true,
              fillColor: isError ? const Color(0xFFFEF2F2) : const Color(0xFFFBFCFD),
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(width: 0.5, color: Color(0xFFE4E9ED)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  width: isError ? 1 : 0.5,
                  color: isError ? const Color(0xFFDC2626) : const Color(0xFFE4E9ED),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  width: 1,
                  color: isError ? const Color(0xFFDC2626) : const Color(0xFF1339FF),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style:
            const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        children: required
            ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  Widget _buildSearchableField({
    required TextEditingController textController,
    required RxList<Map<String, dynamic>> results,
    required RxBool isLoading,
    required void Function(String) onChanged,
    required void Function(Map<String, dynamic>) onSelected,
    required String displayKey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            if (hasFocus) {
              // Fetch results on focus (show dropdown even without typing)
              onChanged(textController.text);
            } else {
              // Clear results when losing focus (with delay for tap to register)
              Future.delayed(const Duration(milliseconds: 200), () {
                results.clear();
              });
            }
          },
          child: TextField(
            controller: textController,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              prefixIcon:
                  const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
              hintText: "search",
              hintStyle:
                  const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE9E9E9), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE9E9E9), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFFE9E9E9), width: 1),
              ),
            ),
          ),
        ),
        Obx(() {
          if (isLoading.value) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }
          if (results.isEmpty) return const SizedBox.shrink();
          return Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE9E9E9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                final displayText = item[displayKey]?.toString() ?? '';
                return InkWell(
                  onTap: () => onSelected(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Text(
                      displayText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTagsWrap({
    required List<Map<String, dynamic>> items,
    required String displayKey,
    required void Function(Map<String, dynamic>) onRemove,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final label = item[displayKey]?.toString() ?? '';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => onRemove(item),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEC4899),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultilineField(String hint) {
    return TextField(
      controller: controller.examinationController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE9E9E9), width: 1),
        ),
      ),
    );
  }
}
