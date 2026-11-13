import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografi resmi SakuKuliah menggabungkan Epilogue (Headings) dan Inter (Body & Labels)
class AppTypography {
  AppTypography._();

  // Headings (Epilogue)
  static TextStyle displayLg = GoogleFonts.epilogue(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLg = GoogleFonts.epilogue(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLgMobile = GoogleFonts.epilogue(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.24,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.epilogue(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSm = GoogleFonts.epilogue(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: AppColors.onSurface,
  );

  // Body Text (Inter)
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMd = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: AppColors.onSurfaceVariant,
  );

  // Labels & Badges (Inter)
  static TextStyle labelLg = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.14,
    color: AppColors.onSurface,
  );

  static TextStyle labelMd = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.24,
    color: AppColors.onSurface,
  );

  static TextStyle labelSm = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 14 / 10,
    letterSpacing: 0.4,
    color: AppColors.onSurfaceVariant,
  );
}

