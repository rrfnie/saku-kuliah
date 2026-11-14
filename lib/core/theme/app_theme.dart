import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../state/app_state.dart';
import 'app_colors.dart';
import 'app_palettes.dart';
import 'app_typography.dart';

/// Konfigurasi ThemeData Material 3 resmi SakuKuliah dengan dukungan Multi-Palette & Dark Mode
class AppTheme {
  AppTheme._();

  static bool get isDark {
    try {
      final mode = SakuKuliahState.instance.themeMode;
      if (mode == ThemeMode.dark) return true;
      if (mode == ThemeMode.light) return false;
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    } catch (_) {
      return false;
    }
  }

  static AppThemePalette get currentPalette {
    try {
      return AppPalettes.getByType(SakuKuliahState.instance.themePalette);
    } catch (_) {
      return AppPalettes.sakura;
    }
  }

  static ThemeData get lightTheme => buildTheme(paletteType: AppPaletteType.sakura, isDark: false);
  static ThemeData get darkTheme => buildTheme(paletteType: AppPaletteType.sakura, isDark: true);

  static ThemeData buildTheme({
    required AppPaletteType paletteType,
    required bool isDark,
  }) {
    final palette = AppPalettes.getByType(paletteType);

    // Color definitions based on isDark
    final primary = isDark ? palette.primaryDark : palette.primary;
    final onPrimary = isDark ? palette.onPrimaryDark : palette.onPrimary;
    final primaryContainer = isDark ? palette.primaryContainerDark : palette.primaryContainer;
    final onPrimaryContainer = isDark ? palette.onPrimaryContainerDark : palette.onPrimaryContainer;
    final secondary = isDark ? palette.secondaryDark : palette.secondary;
    final onSecondary = isDark ? palette.onSecondaryDark : palette.onSecondary;
    final secondaryContainer = isDark ? palette.secondaryContainerDark : palette.secondaryContainer;
    final onSecondaryContainer = isDark ? palette.onSecondaryContainerDark : palette.onSecondaryContainer;
    final tertiary = isDark ? palette.tertiaryDark : palette.tertiary;
    final onTertiary = isDark ? palette.onTertiaryDark : palette.onTertiary;
    final tertiaryContainer = isDark ? palette.tertiaryContainerDark : palette.tertiaryContainer;
    final onTertiaryContainer = isDark ? palette.onTertiaryContainerDark : palette.onTertiaryContainer;

    // Surfaces & Canvas (Cozy Midnight for Dark, Matching Pastel for Light)
    final background = isDark ? const Color(0xFF140F15) : palette.background;
    final surface = isDark ? const Color(0xFF1B141D) : palette.background;
    final surfaceContainerLowest = isDark ? const Color(0xFF221A25) : const Color(0xFFFFFFFF);
    final surfaceContainerLow = isDark ? const Color(0xFF2A212E) : palette.surfaceContainerLow;
    final surfaceContainer = isDark ? const Color(0xFF332838) : palette.surfaceContainer;
    final surfaceContainerHigh = isDark ? const Color(0xFF3D3042) : palette.surfaceContainerHigh;
    final surfaceContainerHighest = isDark ? const Color(0xFF473A4D) : palette.surfaceContainerHigh;

    final onSurface = isDark ? const Color(0xFFF5ECF4) : const Color(0xFF1E1A22);
    final onSurfaceVariant = isDark ? const Color(0xFFD4C4D1) : const Color(0xFF504447);
    final outline = isDark ? const Color(0xFF9E8B9A) : const Color(0xFF827377);
    final outlineVariant = isDark ? const Color(0xFF4D3F4F) : primary.withValues(alpha: 0.18);
    final cardBorder = isDark ? const Color(0x33D4C4D1) : primary.withValues(alpha: 0.18);

    final colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: tertiary,
      onTertiary: onTertiary,
      tertiaryContainer: tertiaryContainer,
      onTertiaryContainer: onTertiaryContainer,
      error: isDark ? const Color(0xFFFFB4AB) : AppColors.error,
      onError: isDark ? const Color(0xFF690005) : AppColors.onError,
      errorContainer: isDark ? const Color(0xFF93000A) : AppColors.errorContainer,
      onErrorContainer: isDark ? const Color(0xFFFFDAD6) : AppColors.onErrorContainer,
      surface: surface,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      inverseSurface: isDark ? const Color(0xFFEFE6EE) : const Color(0xFF332F37),
      onInverseSurface: isDark ? const Color(0xFF322837) : const Color(0xFFF6EEF9),
      inversePrimary: isDark ? palette.primary : palette.primaryDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      cardColor: surfaceContainerLowest,
      canvasColor: background,
      dialogTheme: DialogThemeData(backgroundColor: surfaceContainerLowest),
      fontFamily: 'Inter',
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLg,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        headlineSmall: AppTypography.headlineSm,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        bodySmall: AppTypography.bodySm,
        labelLarge: AppTypography.labelLg,
        labelMedium: AppTypography.labelMd,
        labelSmall: AppTypography.labelSm,
      ),

      // App Bar Styling
      appBarTheme: AppBarTheme(
        backgroundColor: surface.withValues(alpha: 0.95),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onSurface),
        titleTextStyle: AppTypography.headlineSm.copyWith(
          color: onSurface,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card Styling (16px to 20px radius)
      cardTheme: CardThemeData(
        color: surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: cardBorder,
            width: 1,
          ),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tertiary,
        foregroundColor: isDark ? const Color(0xFF1E1A22) : Colors.white,
        elevation: 4,
        shape: const StadiumBorder(),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: AppTypography.bodyMd.copyWith(color: outline),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: outlineVariant, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryContainer, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tertiary, width: 1.8),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: outlineVariant,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: cardBorder,
        thickness: 1,
        space: 1,
      ),

      // Silky Smooth Page Transitions (iOS Cupertino slide & swipe-back)
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
