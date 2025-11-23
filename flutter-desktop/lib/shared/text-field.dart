import 'package:flutter/material.dart';
import 'package:flutter_getx_app/theme/app_theme.dart';
import '../theme/app_typography.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String hintText;
  final bool obscureText;
  final String? errorText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Color? fillColor;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.keyboardType,
    required this.hintText,
    this.obscureText = false,
    this.errorText,
    this.suffixIcon,
    this.prefixIcon, // add this
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasError = errorText != null && errorText!.isNotEmpty;
    final palette = AppTheme.colorPalette;
    final borderRadius = BorderRadius.circular(8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 60,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            decoration: InputDecoration(
              filled: true,
              fillColor: fillColor ??
                  (hasError
                      ? palette['danger']!['surface']
                      : palette['neutral']!['10']),
              hintText: hintText,
              hintStyle: AppTypography.bodyLargeRegular.copyWith(
                color: palette['neutral']!['50'],
              ),
              border: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: hasError
                      ? palette['danger']!['main']!
                      : palette['neutral']!['40']!,
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: hasError
                      ? palette['danger']!['main']!
                      : palette['neutral']!['40']!,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: hasError
                      ? palette['danger']!['main']!
                      : palette['info']!['main']!,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: borderRadius,
                borderSide: BorderSide(
                  color: palette['danger']!['main']!,
                  width: 2,
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: prefixIcon,
                    )
                  : null,
              suffixIconColor: hasError
                  ? palette['danger']!['main']
                  : palette['neutral']!['50'],
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Text(
              errorText!,
              style: AppTypography.bodySmallRegular.copyWith(
                color: palette['danger']!['main'],
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
