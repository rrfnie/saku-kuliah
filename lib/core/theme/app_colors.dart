import 'package:flutter/material.dart';
import 'app_palettes.dart';
import 'app_theme.dart';

/// Palet warna resmi SakuKuliah dengan dukungan Multi-Palette & Dark Mode reaktif
class AppColors {
  AppColors._();

  static bool get _isDark => AppTheme.isDark;
  static AppThemePalette get _palette => AppTheme.currentPalette;

  // Core Brand Colors (Dinamis berubah sesuai palet pilihan: Sakura, Matcha, Lilac, Sky, Caramel)
  static Color get primary => _isDark ? _palette.primaryDark : _palette.primary;
  static Color get onPrimary => _isDark ? _palette.onPrimaryDark : _palette.onPrimary;
  static Color get primaryContainer => _isDark ? _palette.primaryContainerDark : _palette.primaryContainer;
  static Color get onPrimaryContainer => _isDark ? _palette.onPrimaryContainerDark : _palette.onPrimaryContainer;
  static Color get inversePrimary => _isDark ? _palette.primary : _palette.primaryDark;

  // Secondary Tones
  static Color get secondary => _isDark ? _palette.secondaryDark : _palette.secondary;
  static Color get onSecondary => _isDark ? _palette.onSecondaryDark : _palette.onSecondary;
  static Color get secondaryContainer => _isDark ? _palette.secondaryContainerDark : _palette.secondaryContainer;
  static Color get onSecondaryContainer => _isDark ? _palette.onSecondaryContainerDark : _palette.onSecondaryContainer;

  // Tertiary / Accent Tones
  static Color get tertiary => _isDark ? _palette.tertiaryDark : _palette.tertiary;
  static Color get onTertiary => _isDark ? _palette.onTertiaryDark : _palette.onTertiary;
  static Color get tertiaryContainer => _isDark ? _palette.tertiaryContainerDark : _palette.tertiaryContainer;
  static Color get onTertiaryContainer => _isDark ? _palette.onTertiaryContainerDark : _palette.onTertiaryContainer;

  // Surface & Canvas Containers (Sesuai palet terpilih)
  static Color get background => _isDark ? const Color(0xFF140F15) : _palette.background;
  static Color get canvasGround => _isDark ? const Color(0xFF19131A) : _palette.background;
  static Color get onBackground => _isDark ? const Color(0xFFF6EEF8) : const Color(0xFF1E1A22);

  static Color get surface => _isDark ? const Color(0xFF1B141D) : _palette.background;
  static Color get surfaceDim => _isDark ? const Color(0xFF161018) : const Color(0xFFDFD7E2);
  static Color get surfaceBright => _isDark ? const Color(0xFF28202B) : _palette.background;
  static Color get surfaceContainerLowest => _isDark ? const Color(0xFF221A25) : const Color(0xFFFFFFFF);
  static Color get surfaceContainerLow => _isDark ? const Color(0xFF2A212E) : _palette.surfaceContainerLow;
  static Color get surfaceContainer => _isDark ? const Color(0xFF332838) : _palette.surfaceContainer;
  static Color get surfaceContainerHigh => _isDark ? const Color(0xFF3D3042) : _palette.surfaceContainerHigh;
  static Color get surfaceContainerHighest => _isDark ? const Color(0xFF473A4D) : _palette.surfaceContainerHigh;

  // Typography & Content Neutrals (Terang jelas di mode gelap)
  static Color get onSurface => _isDark ? const Color(0xFFF6EEF8) : const Color(0xFF1E1A22);
  static Color get onSurfaceVariant => _isDark ? const Color(0xFFD4C3D2) : const Color(0xFF504447);
  static Color get inverseSurface => _isDark ? const Color(0xFFEFE6EE) : const Color(0xFF332F37);
  static Color get inverseOnSurface => _isDark ? const Color(0xFF322837) : const Color(0xFFF6EEF9);
  static Color get outline => _isDark ? const Color(0xFF9E8B9A) : const Color(0xFF827377);
  static Color get outlineVariant => _isDark ? const Color(0xFF4D3F4F) : primary.withValues(alpha: 0.18);
  static Color get surfaceTint => primary;

  // Card Borders & Dividers Dinamis
  static Color get cardBorder => _isDark ? const Color(0x33D4C4D1) : primary.withValues(alpha: 0.18);
  static Color get dividerColor => _isDark ? const Color(0x22FFFFFF) : primary.withValues(alpha: 0.12);

  // Fixed Accent Chips (Dinamis berubah sesuai palet pilihan)
  static Color get primaryFixed => _isDark ? _palette.primaryContainerDark : _palette.primaryContainer;
  static Color get primaryFixedDim => _isDark ? _palette.primaryDark : _palette.primary;
  static Color get onPrimaryFixed => _isDark ? _palette.onPrimaryContainerDark : _palette.onPrimaryContainer;
  static Color get onPrimaryFixedVariant => _isDark ? _palette.primaryDark : _palette.primary;

  static Color get secondaryFixed => _isDark ? _palette.secondaryContainerDark : _palette.secondaryContainer;
  static Color get secondaryFixedDim => _isDark ? _palette.secondaryDark : _palette.secondary;
  static Color get onSecondaryFixed => _isDark ? _palette.onSecondaryContainerDark : _palette.onSecondaryContainer;
  static Color get onSecondaryFixedVariant => _isDark ? _palette.secondaryDark : _palette.secondary;

  static Color get tertiaryFixed => _isDark ? _palette.tertiaryContainerDark : _palette.tertiaryContainer;
  static Color get tertiaryFixedDim => _isDark ? _palette.tertiaryDark : _palette.tertiary;
  static Color get onTertiaryFixed => _isDark ? _palette.onTertiaryContainerDark : _palette.onTertiaryContainer;
  static Color get onTertiaryFixedVariant => _isDark ? _palette.tertiaryDark : _palette.tertiary;

  // Functional Semantic Statuses
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  static const Color success = Color(0xFFA8CBAF);
  static const Color onSuccess = Color(0xFF1E3A24);
  static const Color successContainer = Color(0xFFD8EAD9);

  static const Color warning = Color(0xFFF5D58A);
  static const Color onWarning = Color(0xFF453300);
  static const Color warningContainer = Color(0xFFFEF3CD);

  // Shadows (Mengikuti warna palet yang aktif)
  static List<BoxShadow> get cardShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ]
      : [
          BoxShadow(
            color: primary.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ];

  static List<BoxShadow> get elevatedShadow => _isDark
      ? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ]
      : [
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ];
}
