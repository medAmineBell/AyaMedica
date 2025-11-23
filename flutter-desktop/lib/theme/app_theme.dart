import 'package:flutter/material.dart';
import 'package:flutter_getx_app/theme/app_typography.dart';

class AppTheme {
  // Color Palette from Style Guide
  static const Map<String, Map<String, Color>> colorPalette = {
    'info': {
      'main': Color(0xFF0D6EFD), // #0D6EFD
      'surface': Color(0xFFD0E1FF), // #D0E1FF
      'border': Color(0xFFA7CAFF), // #A7CAFF
      'hover': Color(0xFF0B5ED7), // #0B5ED7
      'pressed': Color(0xFF084298), // #084298
      'focus': Color(0xFFCFE2FF), // #CFE2FF
    },
    'success': {
      'main': Color(0xFF10B981), // #10B981
      'surface': Color(0xFFD1FAE5), // #D1FAE5
      'border': Color(0xFFA7F3D0), // #A7F3D0
      'hover': Color(0xFF059669), // #059669
      'pressed': Color(0xFF047857), // #047857
      'focus': Color(0xFFD1FAEC), // #D1FAEC
    },
    'danger': {
      'main': Color(0xFFEF4444), // #EF4444
      'surface': Color(0xFFFEE2E2), // #FEE2E2
      'border': Color(0xFFFCA5A5), // #FCA5A5
      'hover': Color(0xFFDC2626), // #DC2626
      'pressed': Color(0xFF991B1B), // #991B1B
      'focus': Color(0xFFFEE2E2), // #FEE2E2
    },
    'neutral': {
      '10': Color(0xFFF8FAFC), // #F8FAFC
      '20': Color(0xFFF1F5F9), // #F1F5F9
      '30': Color(0xFFE2E8F0), // #E2E8F0
      '40': Color(0xFFCBD5E1), // #CBD5E1
      '50': Color(0xFF94A3B8), // #94A3B8
      '60': Color(0xFF64748B), // #64748B
      '70': Color(0xFF475569), // #475569
      '80': Color(0xFF334155), // #334155
      '90': Color(0xFF1E293B), // #1E293B
      '100': Color(0xFF0F172A), // #0F172A
    },
  };

  // Light Theme
  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        primaryColor: colorPalette['info']!['main'],
        primaryColorDark: colorPalette['info']!['pressed'],
        primaryColorLight: colorPalette['info']!['surface'],
        colorScheme: ColorScheme.light(
          primary: colorPalette['info']!['main']!,
          secondary: colorPalette['success']!['main']!,
          error: colorPalette['danger']!['main']!,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
          background: colorPalette['neutral']!['10']!,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: colorPalette['info']!['main']!,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: AppTypography.heading4.copyWith(color: Colors.white),
        ),
        textTheme: const TextTheme(
          displayLarge: AppTypography.heading1,
          displayMedium: AppTypography.heading2,
          displaySmall: AppTypography.heading3,
          headlineMedium: AppTypography.heading4,
          headlineSmall: AppTypography.heading5,
          titleLarge: AppTypography.heading6,
          titleMedium: AppTypography.bodyLargeMedium,
          titleSmall: AppTypography.bodyMediumMedium,
          bodyLarge: AppTypography.bodyLargeRegular,
          bodyMedium: AppTypography.bodyMediumRegular,
          bodySmall: AppTypography.bodySmallRegular,
          labelLarge: AppTypography.bodyMediumSemibold,
          labelMedium: AppTypography.bodySmallSemibold,
          labelSmall: AppTypography.bodyXSmallSemibold,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPalette['info']!['main']!,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            textStyle: AppTypography.bodyMediumSemibold,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: colorPalette['neutral']!['30']!,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: AppTypography.bodyMediumRegular
              .copyWith(color: colorPalette['neutral']!['50']!),
          labelStyle: AppTypography.bodyMediumMedium,
        ),
      );

  // Dark Theme
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        primaryColor: colorPalette['info']!['main']!,
        primaryColorDark: colorPalette['info']!['pressed']!,
        primaryColorLight: colorPalette['info']!['surface']!,
        colorScheme: ColorScheme.dark(
          primary: colorPalette['info']!['main']!,
          secondary: colorPalette['success']!['main']!,
          error: colorPalette['danger']!['main']!,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onError: Colors.white,
          background: colorPalette['neutral']!['100']!,
          surface: colorPalette['neutral']!['90']!,
        ),
        scaffoldBackgroundColor: colorPalette['neutral']!['100']!,
        appBarTheme: AppBarTheme(
          backgroundColor: colorPalette['neutral']!['90']!,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: AppTypography.heading4.copyWith(color: Colors.white),
        ),
        textTheme: TextTheme(
          displayLarge: AppTypography.heading1
              .copyWith(color: colorPalette['neutral']!['10']!),
          displayMedium: AppTypography.heading2
              .copyWith(color: colorPalette['neutral']!['10']!),
          displaySmall: AppTypography.heading3
              .copyWith(color: colorPalette['neutral']!['10']!),
          headlineMedium: AppTypography.heading4
              .copyWith(color: colorPalette['neutral']!['10']!),
          headlineSmall: AppTypography.heading5
              .copyWith(color: colorPalette['neutral']!['10']!),
          titleLarge: AppTypography.heading6
              .copyWith(color: colorPalette['neutral']!['10']!),
          titleMedium: AppTypography.bodyLargeMedium
              .copyWith(color: colorPalette['neutral']!['20']!),
          titleSmall: AppTypography.bodyMediumMedium
              .copyWith(color: colorPalette['neutral']!['20']!),
          bodyLarge: AppTypography.bodyLargeRegular
              .copyWith(color: colorPalette['neutral']!['20']!),
          bodyMedium: AppTypography.bodyMediumRegular
              .copyWith(color: colorPalette['neutral']!['20']!),
          bodySmall: AppTypography.bodySmallRegular
              .copyWith(color: colorPalette['neutral']!['20']!),
          labelLarge: AppTypography.bodyMediumSemibold
              .copyWith(color: colorPalette['neutral']!['20']!),
          labelMedium: AppTypography.bodySmallSemibold
              .copyWith(color: colorPalette['neutral']!['20']!),
          labelSmall: AppTypography.bodyXSmallSemibold
              .copyWith(color: colorPalette['neutral']!['20']!),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPalette['info']!['main']!,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            textStyle: AppTypography.bodyMediumSemibold,
          ),
        ),
        cardTheme: CardThemeData(
          color: colorPalette['neutral']!['90']!,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: colorPalette['neutral']!['70']!,
          thickness: 1,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: BorderSide(color: colorPalette['neutral']!['70']!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide:
                BorderSide(color: colorPalette['info']!['main']!, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide:
                BorderSide(color: colorPalette['danger']!['main']!, width: 2),
          ),
          filled: true,
          fillColor: colorPalette['neutral']!['80']!,
          hintStyle: AppTypography.bodyMediumRegular
              .copyWith(color: colorPalette['neutral']!['50']!),
          labelStyle: AppTypography.bodyMediumMedium
              .copyWith(color: colorPalette['neutral']!['30']!),
        ),
      );
}
