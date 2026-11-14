import 'package:flutter/material.dart';

/// Jenis palet tema warna pastel SakuKuliah
enum AppPaletteType {
  sakura,
  matcha,
  lilac,
  sky,
  caramel,
}

/// Model Palet Warna SakuKuliah
class AppThemePalette {
  final AppPaletteType type;
  final String name;
  final String emoji;
  final String description;
  final Color previewColor;

  // Light Mode Colors
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color onTertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  // Dark Mode Colors
  final Color primaryDark;
  final Color onPrimaryDark;
  final Color primaryContainerDark;
  final Color onPrimaryContainerDark;
  final Color secondaryDark;
  final Color onSecondaryDark;
  final Color secondaryContainerDark;
  final Color onSecondaryContainerDark;
  final Color tertiaryDark;
  final Color onTertiaryDark;
  final Color tertiaryContainerDark;
  final Color onTertiaryContainerDark;

  // Background & Surface Containers (Nuansa pastel lembut sesuai palet)
  final Color background;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;

  const AppThemePalette({
    required this.type,
    required this.name,
    required this.emoji,
    required this.description,
    required this.previewColor,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.primaryDark,
    required this.onPrimaryDark,
    required this.primaryContainerDark,
    required this.onPrimaryContainerDark,
    required this.secondaryDark,
    required this.onSecondaryDark,
    required this.secondaryContainerDark,
    required this.onSecondaryContainerDark,
    required this.tertiaryDark,
    required this.onTertiaryDark,
    required this.tertiaryContainerDark,
    required this.onTertiaryContainerDark,
    required this.background,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
  });
}

/// Kumpulan 5 Palet Warna Pastel Resmi SakuKuliah
class AppPalettes {
  AppPalettes._();

  // 1. 🌸 Blush Sakura (Khas SakuKuliah)
  static const AppThemePalette sakura = AppThemePalette(
    type: AppPaletteType.sakura,
    name: 'Blush Sakura',
    emoji: '🌸',
    description: 'Manis & Ceria',
    previewColor: Color(0xFFF4B8CD),
    // Light
    primary: Color(0xFF805063),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF4B8CD),
    onPrimaryContainer: Color(0xFF744658),
    secondary: Color(0xFF6B5A60),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF4DCE4),
    onSecondaryContainer: Color(0xFF716066),
    tertiary: Color(0xFF8B4969),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFFB2D3),
    onTertiaryContainer: Color(0xFF7F3E5E),
    // Dark
    primaryDark: Color(0xFFF2B6CB),
    onPrimaryDark: Color(0xFF4C2234),
    primaryContainerDark: Color(0xFF65394B),
    onPrimaryContainerDark: Color(0xFFFFD9E4),
    secondaryDark: Color(0xFFD7C1C8),
    onSecondaryDark: Color(0xFF3B2D33),
    secondaryContainerDark: Color(0xFF524249),
    onSecondaryContainerDark: Color(0xFFF4DCE4),
    tertiaryDark: Color(0xFFFFAFD2),
    onTertiaryDark: Color(0xFF531D39),
    tertiaryContainerDark: Color(0xFF6E3350),
    onTertiaryContainerDark: Color(0xFFFFD8E6),
    // Surfaces
    background: Color(0xFFFEF7FF),
    surfaceContainerLow: Color(0xFFF9F1FC),
    surfaceContainer: Color(0xFFF3EBF6),
    surfaceContainerHigh: Color(0xFFEEE5F0),
  );

  // 2. 🍵 Matcha Latte (Sage Green)
  static const AppThemePalette matcha = AppThemePalette(
    type: AppPaletteType.matcha,
    name: 'Matcha Latte',
    emoji: '🍵',
    description: 'Sejuk & Menenangkan',
    previewColor: Color(0xFFB5D6B7),
    // Light
    primary: Color(0xFF436B46),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFC6E9C9),
    onPrimaryContainer: Color(0xFF2C5330),
    secondary: Color(0xFF526353),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD6E7D5),
    onSecondaryContainer: Color(0xFF3E4E3F),
    tertiary: Color(0xFF556B4E),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD8EFCE),
    onTertiaryContainer: Color(0xFF3E5338),
    // Dark
    primaryDark: Color(0xFFABCEA8),
    onPrimaryDark: Color(0xFF16381C),
    primaryContainerDark: Color(0xFF2C4F30),
    onPrimaryContainerDark: Color(0xFFC7EBC6),
    secondaryDark: Color(0xFFB9CBB7),
    onSecondaryDark: Color(0xFF253426),
    secondaryContainerDark: Color(0xFF3B4B3C),
    onSecondaryContainerDark: Color(0xFFD5E7D3),
    tertiaryDark: Color(0xFFBDD4B4),
    onTertiaryDark: Color(0xFF283823),
    tertiaryContainerDark: Color(0xFF3E4E38),
    onTertiaryContainerDark: Color(0xFFD9F0CE),
    // Surfaces
    background: Color(0xFFF7FAF7),
    surfaceContainerLow: Color(0xFFEEF5EE),
    surfaceContainer: Color(0xFFE3EFE3),
    surfaceContainerHigh: Color(0xFFD7E7D7),
  );

  // 3. 💜 Lilac Dream (Soft Lavender)
  static const AppThemePalette lilac = AppThemePalette(
    type: AppPaletteType.lilac,
    name: 'Lilac Dream',
    emoji: '💜',
    description: 'Lembut & Estetik',
    previewColor: Color(0xFFD5BDE8),
    // Light
    primary: Color(0xFF6A4E7E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE9D5F7),
    onPrimaryContainer: Color(0xFF523665),
    secondary: Color(0xFF625B6C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE8DEF2),
    onSecondaryContainer: Color(0xFF4A4354),
    tertiary: Color(0xFF7C4B78),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFF7D1F2),
    onTertiaryContainer: Color(0xFF62345E),
    // Dark
    primaryDark: Color(0xFFD5BDE8),
    onPrimaryDark: Color(0xFF3B204D),
    primaryContainerDark: Color(0xFF523765),
    onPrimaryContainerDark: Color(0xFFEFDCFC),
    secondaryDark: Color(0xFFCCC1D5),
    onSecondaryDark: Color(0xFF342D3D),
    secondaryContainerDark: Color(0xFF4A4354),
    onSecondaryContainerDark: Color(0xFFE8DEF2),
    tertiaryDark: Color(0xFFECB4E5),
    onTertiaryDark: Color(0xFF491E47),
    tertiaryContainerDark: Color(0xFF62345F),
    onTertiaryContainerDark: Color(0xFFFFD7F5),
    // Surfaces
    background: Color(0xFFFAF7FF),
    surfaceContainerLow: Color(0xFFF3EDFC),
    surfaceContainer: Color(0xFFEBE1F8),
    surfaceContainerHigh: Color(0xFFE1D3F4),
  );

  // 4. ☁️ Baby Blue Sky (Cloud Pastel)
  static const AppThemePalette sky = AppThemePalette(
    type: AppPaletteType.sky,
    name: 'Baby Blue Sky',
    emoji: '☁️',
    description: 'Segar & Bersih',
    previewColor: Color(0xFFAACBE6),
    // Light
    primary: Color(0xFF3D637E),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFCEE4F7),
    onPrimaryContainer: Color(0xFF244A64),
    secondary: Color(0xFF52606C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD5E3F0),
    onSecondaryContainer: Color(0xFF3B4853),
    tertiary: Color(0xFF486782),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFCEE6FC),
    onTertiaryContainer: Color(0xFF2E4D67),
    // Dark
    primaryDark: Color(0xFFAACBE6),
    onPrimaryDark: Color(0xFF08344D),
    primaryContainerDark: Color(0xFF244A65),
    onPrimaryContainerDark: Color(0xFFCDE4F8),
    secondaryDark: Color(0xFFB9C8D6),
    onSecondaryDark: Color(0xFF24323D),
    secondaryContainerDark: Color(0xFF3A4854),
    onSecondaryContainerDark: Color(0xFFD5E4F1),
    tertiaryDark: Color(0xFFB0CFEB),
    onTertiaryDark: Color(0xFF18374F),
    tertiaryContainerDark: Color(0xFF2F4E67),
    onTertiaryContainerDark: Color(0xFFD1E6FC),
    // Surfaces
    background: Color(0xFFF5F9FD),
    surfaceContainerLow: Color(0xFFEAF3FB),
    surfaceContainer: Color(0xFFDDECF8),
    surfaceContainerHigh: Color(0xFFD0E4F4),
  );

  // 5. ☕ Warm Caramel (Oat Milk)
  static const AppThemePalette caramel = AppThemePalette(
    type: AppPaletteType.caramel,
    name: 'Warm Caramel',
    emoji: '☕',
    description: 'Hangat & Cozy',
    previewColor: Color(0xFFECC3A7),
    // Light
    primary: Color(0xFF7A563D),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF7DAC0),
    onPrimaryContainer: Color(0xFF5F3E26),
    secondary: Color(0xFF6B5C51),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFF2E2D6),
    onSecondaryContainer: Color(0xFF53453B),
    tertiary: Color(0xFF7A503B),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFFAD7C5),
    onTertiaryContainer: Color(0xFF603824),
    // Dark
    primaryDark: Color(0xFFECC2A4),
    onPrimaryDark: Color(0xFF462912),
    primaryContainerDark: Color(0xFF603F27),
    onPrimaryContainerDark: Color(0xFFF7DAC2),
    secondaryDark: Color(0xFFD7C3B6),
    onSecondaryDark: Color(0xFF3B2E24),
    secondaryContainerDark: Color(0xFF52443A),
    onSecondaryContainerDark: Color(0xFFF2E2D5),
    tertiaryDark: Color(0xFFECB8A0),
    onTertiaryDark: Color(0xFF472311),
    tertiaryContainerDark: Color(0xFF613926),
    onTertiaryContainerDark: Color(0xFFFFDCC9),
    // Surfaces
    background: Color(0xFFFDF9F6),
    surfaceContainerLow: Color(0xFFF7EFE8),
    surfaceContainer: Color(0xFFF0E4D9),
    surfaceContainerHigh: Color(0xFFE8D7CB),
  );

  static const List<AppThemePalette> all = [
    sakura,
    matcha,
    lilac,
    sky,
    caramel,
  ];

  static AppThemePalette getByType(AppPaletteType type) {
    switch (type) {
      case AppPaletteType.sakura:
        return sakura;
      case AppPaletteType.matcha:
        return matcha;
      case AppPaletteType.lilac:
        return lilac;
      case AppPaletteType.sky:
        return sky;
      case AppPaletteType.caramel:
        return caramel;
    }
  }
}
