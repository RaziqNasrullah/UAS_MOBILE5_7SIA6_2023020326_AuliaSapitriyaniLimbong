import 'package:flutter/material.dart';

/// Warna identitas Delights (diambil dari logo).
class AppColors {
  AppColors._();

  static const Color coral = Color(0xFFF4845F);
  static const Color coralDark = Color(0xFFE0663F);
  static const Color mint = Color(0xFF2F9C95);
  static const Color tealDark = Color(0xFF1F5F66);
  static const Color cream = Color(0xFFFFF4EC);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF263238);
  static const Color textMuted = Color(0xFF78858C);
  static const Color border = Color(0xFFF1DED3);

  // Status pesanan
  static const Color diproses = Color(0xFFF2A93B);
  static const Color selesai = Color(0xFF2E9E5B);
  static const Color dibatalkan = Color(0xFFD64545);

  // Level pedas
  static const Color tidakPedas = Color(0xFF2E9E5B);
  static const Color sedang = Color(0xFFF2A93B);
  static const Color pedas = Color(0xFFEF6C3A);
  static const Color extraPedas = Color(0xFFC62828);

  static Color statusColor(String status) {
    switch (status) {
      case 'Selesai':
        return selesai;
      case 'Dibatalkan':
        return dibatalkan;
      default:
        return diproses;
    }
  }

  static Color levelPedasColor(String level) {
    switch (level) {
      case 'Sedang':
        return sedang;
      case 'Pedas':
        return pedas;
      case 'Extra Pedas':
        return extraPedas;
      default:
        return tidakPedas;
    }
  }
}

/// ThemeData terpusat aplikasi.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.coral,
      primary: AppColors.coral,
      onPrimary: Colors.white,
      secondary: AppColors.mint,
      onSecondary: Colors.white,
      tertiary: AppColors.tealDark,
      surface: AppColors.surface,
      error: AppColors.dibatalkan,
    );

    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.tealDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.tealDark,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontWeight: FontWeight.w800, color: AppColors.tealDark),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, color: AppColors.tealDark),
        titleMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark),
        bodyMedium: TextStyle(color: AppColors.textDark),
        bodySmall: TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.coral,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey.shade600,
          minimumSize: const Size(64, 50),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.mint,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.tealDark,
          minimumSize: const Size(64, 48),
          side: const BorderSide(color: AppColors.mint),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.coral,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.coral, width: 1.6),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.dibatalkan),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: const BorderSide(color: AppColors.dibatalkan, width: 1.6),
        ),
        prefixIconColor: AppColors.mint,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: AppColors.coral,
        secondarySelectedColor: AppColors.coral,
        labelStyle: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.coral.withValues(alpha: 0.18),
        surfaceTintColor: Colors.white,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.coralDark : AppColors.textMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.coralDark : AppColors.textMuted,
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
