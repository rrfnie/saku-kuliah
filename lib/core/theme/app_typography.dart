import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';

/// Tipografi resmi SakuKuliah menggabungkan Epilogue (Headings) dan Inter (Body & Labels)
/// Otomatis kontras dan terang jelas di mode gelap (Dark Mode)
class AppTypography {
  AppTypography._();

  static Color get _onSurface => AppTheme.isDark ? const Color(0xFFF6EEF8) : const Color(0xFF1E1A22);
  static Color get _onSurfaceVariant => AppTheme.isDark ? const Color(0xFFD4C3D2) : const Color(0xFF504447);

  // Headings (Epilogue)
  static TextStyle get displayLg => GoogleFonts.epilogue(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 44 / 36,
    letterSpacing: -0.72,
    color: _onSurface,
  );

  static TextStyle get headlineLg => GoogleFonts.epilogue(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 36 / 28,
    letterSpacing: -0.28,
    color: _onSurface,
  );

  static TextStyle get headlineLgMobile => GoogleFonts.epilogue(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
    letterSpacing: -0.24,
    color: _onSurface,
  );

  static TextStyle get headlineMd => GoogleFonts.epilogue(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    color: _onSurface,
  );

  static TextStyle get headlineSm => GoogleFonts.epilogue(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    color: _onSurface,
  );

  // Body Text (Inter)
  static TextStyle get bodyLg => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: _onSurface,
  );

  static TextStyle get bodyMd => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: _onSurfaceVariant,
  );

  static TextStyle get bodySm => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    color: _onSurfaceVariant,
  );

  // Labels & Badges (Inter)
  static TextStyle get labelLg => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.14,
    color: _onSurface,
  );

  static TextStyle get labelMd => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.24,
    color: _onSurface,
  );

  static TextStyle get labelSm => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 14 / 10,
    letterSpacing: 0.4,
    color: _onSurfaceVariant,
  );
}
