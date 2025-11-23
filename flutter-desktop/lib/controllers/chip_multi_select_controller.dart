import 'package:flutter/material.dart';
import 'package:flutter_getx_app/models/student.dart';
import 'package:get/get.dart';

class ChipMultiSelectController extends GetxController {
  final RxBool isOpen = false.obs;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _key = GlobalKey();

  LayerLink get layerLink => _layerLink;
  GlobalKey get key => _key;

  @override
  void onClose() {
    removeOverlay();
    super.onClose();
  }

  void toggleDropdown<T>({
    required bool enabled,
    required BuildContext context,
    required Widget Function() overlayBuilder,
  }) {
    if (!enabled) return;
    
    if (isOpen.value) {
      removeOverlay();
    } else {
      showOverlay(context: context, overlayBuilder: overlayBuilder);
    }
  }

  void showOverlay({
    required BuildContext context,
    required Widget Function() overlayBuilder,
  }) {
    _overlayEntry = _createOverlayEntry(overlayBuilder);
    Overlay.of(context).insert(_overlayEntry!);
    isOpen.value = true;
  }

  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    isOpen.value = false;
  }

  OverlayEntry _createOverlayEntry(Widget Function() overlayBuilder) {
    RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4),
          child: overlayBuilder(),
        ),
      ),
    );
  }
}

class ReactiveChipMultiSelectDropdown<T> extends StatelessWidget {
  final String hint;
  final RxList<T> selectedValues; // Changed to RxList
  final List<MultiSelectChipItem<T>> items;
  final ValueChanged<List<T>>? onChanged;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? minHeight;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool showSelectAll;
  final String? selectAllText;
  final Widget? checkboxIcon;
  final Widget? checkedIcon;
  final Color? chipBackgroundColor;
  final Color? chipTextColor;
  final Color? chipRemoveIconColor;

  const ReactiveChipMultiSelectDropdown({
    Key? key,
    required this.hint,
    required this.items,
    required this.selectedValues, // Now expects RxList
    this.onChanged,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.iconColor,
    this.borderRadius,
    this.padding,
    this.minHeight,
    this.textStyle,
    this.hintStyle,
    this.showSelectAll = false,
    this.selectAllText = "Select All",
    this.checkboxIcon,
    this.checkedIcon,
    this.chipBackgroundColor,
    this.chipTextColor,
    this.chipRemoveIconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChipMultiSelectController(), tag: hint);

    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: controller.layerLink,
          child: GestureDetector(
            key: controller.key,
            onTap: () => controller.toggleDropdown<T>(
              enabled: enabled,
              context: context,
              overlayBuilder: () => _buildOverlay(controller),
            ),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: backgroundColor ?? const Color(0xFFFBFCFD),
                borderRadius: BorderRadius.circular(borderRadius ?? 12),
                border: Border.all(
                  color: const Color(0xFFE9E9E9),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        hint,
                        style: hintStyle ?? TextStyle(
                          color: hintColor ?? const Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      controller.isOpen.value ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                      color: iconColor ?? const Color(0xFF1339FF),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selectedValues.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedValues.map((value) {
                MultiSelectChipItem<T> item = items.firstWhere((item) => item.value == value);
                return _buildChip(item);
              }).toList(),
            ),
          ),
      ],
    ));
  }

  Widget _buildOverlay(ChipMultiSelectController controller) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          border: Border.all(
            color: const Color(0xFFE9E9E9),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSelectAll) _buildSelectAllItem(controller),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildDropdownItem(items[index], controller);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectAllItem(ChipMultiSelectController controller) {
    bool allSelected = selectedValues.length == items.length;
    bool someSelected = selectedValues.isNotEmpty;

    return InkWell(
      onTap: () {
        List<T> newSelected = allSelected ? [] : items.map((e) => e.value).toList();
        onChanged?.call(newSelected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE9E9E9), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: allSelected ? const Color(0xFF1339FF) : Colors.transparent,
                border: Border.all(
                  color: allSelected || someSelected ? const Color(0xFF1339FF) : const Color(0xFFE9E9E9),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: allSelected
                  ? checkedIcon ?? const Icon(Icons.check, size: 14, color: Colors.white)
                  : someSelected
                      ? Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1339FF),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectAllText!,
                style: TextStyle(
                  color: textColor ?? const Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem(MultiSelectChipItem<T> item, ChipMultiSelectController controller) {
    bool isSelected = selectedValues.contains(item.value);

    return InkWell(
      onTap: () {
        List<T> newSelected = List.from(selectedValues);
        if (isSelected) {
          newSelected.remove(item.value);
        } else {
          newSelected.add(item.value);
        }
        onChanged?.call(newSelected);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1339FF) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFF1339FF) : const Color(0xFFE9E9E9),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? checkedIcon ?? const Icon(Icons.check, size: 14, color: Colors.white)
                  : checkboxIcon,
            ),
            const SizedBox(width: 12),
            if (item.avatar != null) ...[
              item.avatar!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: textColor ?? const Color(0xFF374151),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(MultiSelectChipItem<T> item) {
    return Container(
      decoration: BoxDecoration(
        color: chipBackgroundColor ?? const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.avatar != null) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: item.avatar!,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              item.label,
              style: TextStyle(
                color: chipTextColor ?? const Color(0xFF374151),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {
                List<T> newSelected = List.from(selectedValues);
                newSelected.remove(item.value);
                onChanged?.call(newSelected);
              },
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: chipRemoveIconColor ?? const Color(0xFFEF4444),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Keep the original ChipMultiSelectDropdown for backward compatibility
// but create an alias for the reactive version
typedef ChipMultiSelectDropdown<T> = ReactiveChipMultiSelectDropdown<T>;

// Data class for multi-select chip items with avatar support
class MultiSelectChipItem<T> {
  final T value;
  final String label;
  final Widget? avatar;

  const MultiSelectChipItem({
    required this.value,
    required this.label,
    this.avatar,
  });
}

// Helper class for creating multi-select chip items
class ChipMultiSelectHelper {
  static List<MultiSelectChipItem<String>> createStringItems(List<String> items) {
    return items.map((String value) {
      return MultiSelectChipItem<String>(
        value: value,
        label: value,
      );
    }).toList();
  }

  static List<MultiSelectChipItem<T>> createItems<T>(
    List<T> items,
    String Function(T) labelBuilder, {
    Widget Function(T)? avatarBuilder,
  }) {
    return items.map((T value) {
      return MultiSelectChipItem<T>(
        value: value,
        label: labelBuilder(value),
        avatar: avatarBuilder?.call(value),
      );
    }).toList();
  }

  // Helper for creating student items with avatars
  static List<MultiSelectChipItem<Student>> createStudentItems(List<Student> students) {
    return students.map((Student student) {
      return MultiSelectChipItem<Student>(
        value: student,
        label: student.name,
        avatar: CircleAvatar(
          radius: 10,
          backgroundColor: student.avatarColor ?? const Color(0xFF1339FF),
          child: Text(
            student.name.isNotEmpty ? student.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }).toList();
  }
}