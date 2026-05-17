import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0D6EFD);
  static const Color secondary = Color(0xFF38BDF8);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);
  static const Color infoSoft = Color(0xFFEFF6FF);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

class AppRadii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double pill = 999;
}

class AppFontSizes {
  static const double xs = 12;
  static const double sm = 14;
  static const double md = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xxl = 24;
  static const double display = 28;
}

class AppTextStyles {
  static const TextStyle body = TextStyle(fontSize: AppFontSizes.md, color: AppColors.textPrimary);
  static const TextStyle bodySecondary = TextStyle(fontSize: AppFontSizes.md, color: AppColors.textSecondary);
  static const TextStyle title = TextStyle(fontSize: AppFontSizes.xl, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle display = TextStyle(fontSize: AppFontSizes.display, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const TextStyle caption = TextStyle(fontSize: AppFontSizes.sm, color: AppColors.textSecondary);
}
