import 'package:flutter/material.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_palettes.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_card.dart';

/// Kartu Pengaturan Tema & Mode Gelap / Terang di Halaman Profil
class ThemeSelectorCard extends StatelessWidget {
  const ThemeSelectorCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = SakuKuliahState.instance;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PastelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      size: 20,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tema & Tampilan Aplikasi',
                        style: AppTypography.labelLg.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Sesuaikan warna dan mode gelap favoritmu 🌸',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  'Baru ✨',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 1. Mode Tampilan (Terang / Gelap / Sistem)
          Text(
            'Mode Layar',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2A212E) : const Color(0xFFF3EBF6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildModeSegment(
                  context: context,
                  label: 'Terang ☀️',
                  mode: ThemeMode.light,
                  currentMode: appState.themeMode,
                  onTap: () => appState.setThemeMode(ThemeMode.light),
                ),
                _buildModeSegment(
                  context: context,
                  label: 'Gelap 🌙',
                  mode: ThemeMode.dark,
                  currentMode: appState.themeMode,
                  onTap: () => appState.setThemeMode(ThemeMode.dark),
                ),
                _buildModeSegment(
                  context: context,
                  label: 'Sistem ⚙️',
                  mode: ThemeMode.system,
                  currentMode: appState.themeMode,
                  onTap: () => appState.setThemeMode(ThemeMode.system),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Pilihan Palet Warna Pastel Aksen
          Text(
            'Palet Warna Pastel',
            style: AppTypography.labelMd.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Horizontal Palette Choices
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: AppPalettes.all.map((palette) {
                final isSelected = appState.themePalette == palette.type;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => appState.setThemePalette(palette.type),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                            : (isDark ? const Color(0xFF2A212E) : Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark ? const Color(0x22FFFFFF) : AppColors.dividerColor),
                          width: isSelected ? 1.6 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: palette.previewColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: palette.primary.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isSelected
                                  ? Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: palette.primary,
                                    )
                                  : Text(
                                      palette.emoji,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            palette.name,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            palette.description,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSegment({
    required BuildContext context,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == currentMode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? theme.colorScheme.surface : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
