import 'package:flutter/material.dart';

class CustomMultiSelectDropdown<T> extends StatefulWidget {
  final String hint;
  final List<T> selectedValues;
  final List<MultiSelectItem<T>> items;
  final ValueChanged<List<T>>? onChanged;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? hintColor;
  final Color? iconColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final int? maxSelectedDisplay;
  final String? overflowText;
  final bool showSelectAll;
  final String? selectAllText;
  final Widget? checkboxIcon;
  final Widget? checkedIcon;

  const CustomMultiSelectDropdown({
    Key? key,
    required this.hint,
    required this.items,
    this.selectedValues = const [],
    this.onChanged,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.hintColor,
    this.iconColor,
    this.borderRadius,
    this.padding,
    this.height,
    this.textStyle,
    this.hintStyle,
    this.maxSelectedDisplay = 2,
    this.overflowText,
    this.showSelectAll = false,
    this.selectAllText = "Select All",
    this.checkboxIcon,
    this.checkedIcon,
  }) : super(key: key);

  @override
  State<CustomMultiSelectDropdown<T>> createState() => _CustomMultiSelectDropdownState<T>();
}

class _CustomMultiSelectDropdownState<T> extends State<CustomMultiSelectDropdown<T>> {
  bool _isOpen = false;
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _key = GlobalKey();

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;
    
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isOpen = true;
    });
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) {
      setState(() {
        _isOpen = false;
      });
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = _key.currentContext!.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 4),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
                border: Border.all(
                  color: const Color(0xFFE9E9E9),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showSelectAll) _buildSelectAllItem(),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        return _buildDropdownItem(widget.items[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectAllItem() {
    bool allSelected = widget.selectedValues.length == widget.items.length;
    bool someSelected = widget.selectedValues.isNotEmpty;

    return InkWell(
      onTap: () {
        List<T> newSelected = allSelected ? [] : widget.items.map((e) => e.value).toList();
        widget.onChanged?.call(newSelected);
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
                  ? widget.checkedIcon ?? const Icon(Icons.check, size: 14, color: Colors.white)
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
                widget.selectAllText!,
                style: TextStyle(
                  color: widget.textColor ?? const Color(0xFF374151),
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

  Widget _buildDropdownItem(MultiSelectItem<T> item) {
    bool isSelected = widget.selectedValues.contains(item.value);

    return InkWell(
      onTap: () {
        List<T> newSelected = List.from(widget.selectedValues);
        if (isSelected) {
          newSelected.remove(item.value);
        } else {
          newSelected.add(item.value);
        }
        widget.onChanged?.call(newSelected);
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
                  ? widget.checkedIcon ?? const Icon(Icons.check, size: 14, color: Colors.white)
                  : widget.checkboxIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: widget.textColor ?? const Color(0xFF374151),
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

  String _getDisplayText() {
    if (widget.selectedValues.isEmpty) {
      return widget.hint;
    }

    if (widget.selectedValues.length <= (widget.maxSelectedDisplay ?? 2)) {
      List<String> labels = widget.selectedValues
          .map((value) => widget.items.firstWhere((item) => item.value == value).label)
          .toList();
      return labels.join(', ');
    } else {
      return '${widget.selectedValues.length} ${widget.overflowText ?? 'items selected'}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        key: _key,
        onTap: _toggleDropdown,
        child: Container(
          height: widget.height ?? 52,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? const Color(0xFFFBFCFD),
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
            border: Border.all(
              color: const Color(0xFFE9E9E9),
              width: 1,
            ),
          ),
          child: Padding(
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getDisplayText(),
                    style: widget.selectedValues.isEmpty
                        ? (widget.hintStyle ?? TextStyle(
                            color: widget.hintColor ?? const Color(0xFF9CA3AF),
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ))
                        : (widget.textStyle ?? TextStyle(
                            color: widget.textColor ?? const Color(0xFF374151),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          )),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _isOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: widget.iconColor ?? const Color(0xFF1339FF),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Data class for multi-select items
class MultiSelectItem<T> {
  final T value;
  final String label;

  const MultiSelectItem({
    required this.value,
    required this.label,
  });
}

// Helper class for creating multi-select items
class MultiSelectHelper {
  static List<MultiSelectItem<String>> createStringItems(List<String> items) {
    return items.map((String value) {
      return MultiSelectItem<String>(
        value: value,
        label: value,
      );
    }).toList();
  }

  static List<MultiSelectItem<T>> createItems<T>(
    List<T> items,
    String Function(T) labelBuilder,
  ) {
    return items.map((T value) {
      return MultiSelectItem<T>(
        value: value,
        label: labelBuilder(value),
      );
    }).toList();
  }
}