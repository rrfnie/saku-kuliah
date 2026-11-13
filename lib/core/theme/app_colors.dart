import 'package:flutter/material.dart';

/// Palet warna feminine pastel resmi SakuKuliah sesuai pedoman DESIGN.md
class AppColors {
  AppColors._();

  // Core Brand Colors
  static const Color primary = Color(0xFF805063);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFF4B8CD); // Blush Pink
  static const Color onPrimaryContainer = Color(0xFF744658);
  static const Color inversePrimary = Color(0xFFF2B6CB);

  // Secondary Tones
  static const Color secondary = Color(0xFF6B5A60);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF4DCE4); // Soft Pink
  static const Color onSecondaryContainer = Color(0xFF716066);

  // Tertiary / Accent Tones
  static const Color tertiary = Color(0xFF8B4969); // Dusty Rose
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFB2D3);
  static const Color onTertiaryContainer = Color(0xFF7F3E5E);

  // Surface & Canvas Containers
  static const Color background = Color(0xFFFEF7FF);
  static const Color canvasGround = Color(0xFFFFF8FA); // Warm blush canvas
  static const Color onBackground = Color(0xFF1E1A22);

  static const Color surface = Color(0xFFFEF7FF);
  static const Color surfaceDim = Color(0xFFDFD7E2);
  static const Color surfaceBright = Color(0xFFFEF7FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // Card ground
  static const Color surfaceContainerLow = Color(0xFFF9F1FC);
  static const Color surfaceContainer = Color(0xFFF3EBF6);
  static const Color surfaceContainerHigh = Color(0xFFEEE5F0);
  static const Color surfaceContainerHighest = Color(0xFFE8E0EA);

  // Typography & Content Neutrals
  static const Color onSurface = Color(0xFF1E1A22); // Dark Charcoal / Plum
  static const Color onSurfaceVariant = Color(0xFF504447); // Muted slate
  static const Color inverseSurface = Color(0xFF332F37);
  static const Color inverseOnSurface = Color(0xFFF6EEF9);
  static const Color outline = Color(0xFF827377);
  static const Color outlineVariant = Color(0xFFD4C2C6);
  static const Color surfaceTint = Color(0xFF805063);

  // Fixed Accent Chips
  static const Color primaryFixed = Color(0xFFFFD9E4);
  static const Color primaryFixedDim = Color(0xFFF2B6CB);
  static const Color onPrimaryFixed = Color(0xFF320F1F);
  static const Color onPrimaryFixedVariant = Color(0xFF65394B);

  static const Color secondaryFixed = Color(0xFFF4DCE4);
  static const Color secondaryFixedDim = Color(0xFFD7C1C8);
  static const Color onSecondaryFixed = Color(0xFF25181E);
  static const Color onSecondaryFixedVariant = Color(0xFF524249);

  static const Color tertiaryFixed = Color(0xFFFFD8E6);
  static const Color tertiaryFixedDim = Color(0xFFFFAFD2);
  static const Color onTertiaryFixed = Color(0xFF3A0524);
  static const Color onTertiaryFixedVariant = Color(0xFF6F3251);

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

  // Soft Ambient Drop Shadows (Warm diffuse pink tint)
  static List<BoxShadow> get cardShadow => [
        const BoxShadow(
          color: Color.fromRGBO(217, 139, 174, 0.12),
          blurRadius: 16,
          offset: Offset(0, 4),
          spreadRadius: -2,
        ),
        const BoxShadow(
          color: Color.fromRGBO(52, 48, 56, 0.03),
          blurRadius: 6,
          offset: Offset(0, 2),
          spreadRadius: -1,
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        const BoxShadow(
          color: Color.fromRGBO(217, 139, 174, 0.24),
          blurRadius: 24,
          offset: Offset(0, 8),
          spreadRadius: -4,
        ),
      ];
}

