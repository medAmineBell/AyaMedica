import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
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

  const CustomDropdown({
    Key? key,
    required this.hint,
    required this.items,
    this.value,
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
  }) : super(key: key);

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 52,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? const Color(0xFFFBFCFD),
        borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
        border: Border.all(
          color: const Color(0xFFE9E9E9),
          width: 0,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: widget.value,
          hint: Padding(
            padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              widget.hint,
              style: widget.hintStyle ?? TextStyle(
                color: widget.hintColor ?? const Color(0xFF9CA3AF),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          items: widget.items,
          onChanged: widget.enabled ? widget.onChanged : null,
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.arrow_drop_down,
              color: widget.iconColor ?? const Color(0xFF1339FF),
              size: 24,
            ),
          ),
          selectedItemBuilder: (BuildContext context) {
            return widget.items.map<Widget>((DropdownMenuItem<T> item) {
              return Container(
                alignment: Alignment.centerLeft,
                padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  item.child is Text ? (item.child as Text).data ?? '' : item.value.toString(),
                  style: widget.textStyle ?? TextStyle(
                    color: widget.textColor ?? const Color(0xFF374151),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList();
          },
          dropdownColor: Colors.white,
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          menuMaxHeight: 300,
        ),
      ),
    );
  }
}

// Helper method to create dropdown items easily
class DropdownHelper {
  static List<DropdownMenuItem<String>> createStringItems(List<String> items) {
    return items.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(
          value,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }).toList();
  }

  static List<DropdownMenuItem<T>> createItems<T>(
    List<T> items,
    String Function(T) labelBuilder,
  ) {
    return items.map((T value) {
      return DropdownMenuItem<T>(
        value: value,
        child: Text(
          labelBuilder(value),
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }).toList();
  }
}
