import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final ButtonVariant variant;

  const PrimaryButton({
    Key? key,
    this.onPressed,
    required this.text,
    this.icon,
    this.width,
    this.height = 48,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.variant = ButtonVariant.primary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    // Get colors based on variant and theme
    final buttonColors = _getButtonColors(context, variant);
    
    // Use theme colors with fallbacks
    final buttonBackgroundColor = backgroundColor ?? buttonColors.backgroundColor;
    final buttonTextColor = textColor ?? buttonColors.textColor;
    final buttonFontSize = fontSize ?? textTheme.labelLarge?.fontSize ?? 16;
    final buttonFontWeight = fontWeight ?? textTheme.labelLarge?.fontWeight ?? FontWeight.w600;
    
    return SizedBox(
      width: width,
      height: height,
      child: icon != null
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: buttonTextColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  icon,
                  color: buttonTextColor,
                  size: 16,
                ),
              ),
              label: Text(
                text,
                style: TextStyle(
                  color: buttonTextColor,
                  fontSize: buttonFontSize,
                  fontWeight: buttonFontWeight,
                ),
              ),
              style: _getButtonStyle(context, buttonBackgroundColor, buttonTextColor, buttonColors),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: _getButtonStyle(context, buttonBackgroundColor, buttonTextColor, buttonColors),
              child: Text(
                text,
                style: TextStyle(
                  color: buttonTextColor,
                  fontSize: buttonFontSize,
                  fontWeight: buttonFontWeight,
                ),
              ),
            ),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context, Color backgroundColor, Color textColor, _ButtonColors buttonColors) {
    final theme = Theme.of(context);
    
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Using 12px instead of theme's 28px for table buttons
      ),
      minimumSize: Size.zero,
      disabledBackgroundColor: _getNeutralColor(context, '40'),
      disabledForegroundColor: _getNeutralColor(context, '60'),
    ).copyWith(
      overlayColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.hovered)) {
            return buttonColors.hoverColor;
          }
          if (states.contains(WidgetState.pressed)) {
            return buttonColors.pressedColor;
          }
          if (states.contains(WidgetState.focused)) {
            return buttonColors.focusColor;
          }
          return null;
        },
      ),
    );
  }

  _ButtonColors _getButtonColors(BuildContext context, ButtonVariant variant) {
    switch (variant) {
      case ButtonVariant.primary:
        return _ButtonColors(
          backgroundColor: _getInfoColor(context, 'main'),
          textColor: Colors.white,
          hoverColor: _getInfoColor(context, 'hover'),
          pressedColor: _getInfoColor(context, 'pressed'),
          focusColor: _getInfoColor(context, 'focus'),
        );
      case ButtonVariant.success:
        return _ButtonColors(
          backgroundColor: _getSuccessColor(context, 'main'),
          textColor: Colors.white,
          hoverColor: _getSuccessColor(context, 'hover'),
          pressedColor: _getSuccessColor(context, 'pressed'),
          focusColor: _getSuccessColor(context, 'focus'),
        );
      case ButtonVariant.danger:
        return _ButtonColors(
          backgroundColor: _getDangerColor(context, 'main'),
          textColor: Colors.white,
          hoverColor: _getDangerColor(context, 'hover'),
          pressedColor: _getDangerColor(context, 'pressed'),
          focusColor: _getDangerColor(context, 'focus'),
        );
      case ButtonVariant.secondary:
        return _ButtonColors(
          backgroundColor: _getNeutralColor(context, '20'),
          textColor: _getNeutralColor(context, '80'),
          hoverColor: _getNeutralColor(context, '30'),
          pressedColor: _getNeutralColor(context, '40'),
          focusColor: _getNeutralColor(context, '20'),
        );
      case ButtonVariant.outline:
        return _ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: _getInfoColor(context, 'main'),
          hoverColor: _getInfoColor(context, 'surface'),
          pressedColor: _getInfoColor(context, 'border'),
          focusColor: _getInfoColor(context, 'focus'),
        );
    }
  }

  // Helper methods to get theme colors
  Color _getInfoColor(BuildContext context, String shade) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const infoColors = {
      'main': Color(0xFF0D6EFD),
      'surface': Color(0xFFD0E1FF),
      'border': Color(0xFFA7CAFF),
      'hover': Color(0xFF0B5ED7),
      'pressed': Color(0xFF084298),
      'focus': Color(0xFFCFE2FF),
    };
    return infoColors[shade] ?? infoColors['main']!;
  }

  Color _getSuccessColor(BuildContext context, String shade) {
    const successColors = {
      'main': Color(0xFF10B981),
      'surface': Color(0xFFD1FAE5),
      'border': Color(0xFFA7F3D0),
      'hover': Color(0xFF059669),
      'pressed': Color(0xFF047857),
      'focus': Color(0xFFD1FAEC),
    };
    return successColors[shade] ?? successColors['main']!;
  }

  Color _getDangerColor(BuildContext context, String shade) {
    const dangerColors = {
      'main': Color(0xFFEF4444),
      'surface': Color(0xFFFEE2E2),
      'border': Color(0xFFFCA5A5),
      'hover': Color(0xFFDC2626),
      'pressed': Color(0xFF991B1B),
      'focus': Color(0xFFFEE2E2),
    };
    return dangerColors[shade] ?? dangerColors['main']!;
  }

  Color _getNeutralColor(BuildContext context, String shade) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const neutralColors = {
      '10': Color(0xFFF8FAFC),
      '20': Color(0xFFF1F5F9),
      '30': Color(0xFFE2E8F0),
      '40': Color(0xFFCBD5E1),
      '50': Color(0xFF94A3B8),
      '60': Color(0xFF64748B),
      '70': Color(0xFF475569),
      '80': Color(0xFF334155),
      '90': Color(0xFF1E293B),
      '100': Color(0xFF0F172A),
    };
    return neutralColors[shade] ?? neutralColors['50']!;
  }
}

enum ButtonVariant {
  primary,
  success,
  danger,
  secondary,
  outline,
}

class _ButtonColors {
  final Color backgroundColor;
  final Color textColor;
  final Color hoverColor;
  final Color pressedColor;
  final Color focusColor;

  _ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    required this.hoverColor,
    required this.pressedColor,
    required this.focusColor,
  });
}
