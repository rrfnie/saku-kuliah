import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Pill Badge serbaguna untuk status, SKS, prioritas, dan tag
class StatusBadge extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Widget? leading;
  final bool hasPulseDot;
  final Color? dotColor;
  final EdgeInsetsGeometry padding;
  final double fontSize;

  StatusBadge({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.leading,
    this.hasPulseDot = false,
    this.dotColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.fontSize = 11,
  });

  /// Factory untuk SKS Badge (contoh: "3 SKS")
  factory StatusBadge.sks(int sks) {
    return StatusBadge(
      label: '$sks SKS',
      backgroundColor: AppColors.surfaceContainerHigh,
      textColor: AppColors.onSurfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      fontSize: 10,
    );
  }

  /// Factory untuk Urgent / Prioritas Tinggi
  factory StatusBadge.urgent({String label = 'Prioritas Tinggi'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.errorContainer,
      textColor: AppColors.onErrorContainer,
      hasPulseDot: true,
      dotColor: AppColors.error,
    );
  }

  /// Factory untuk Prioritas Sedang
  factory StatusBadge.mediumPriority({String label = 'Sedang'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.surfaceContainer,
      textColor: AppColors.onSurfaceVariant,
    );
  }

  /// Factory untuk Status "Segera Dimulai" (Active Class)
  factory StatusBadge.ongoing({String label = 'Segera Dimulai'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.primaryContainer,
      textColor: AppColors.onPrimaryContainer,
      hasPulseDot: true,
      dotColor: AppColors.primary,
    );
  }

  /// Factory untuk Prestasi / Cumlaude
  factory StatusBadge.cumlaude({String label = 'Cumlaude Track'}) {
    return StatusBadge(
      label: label,
      backgroundColor: AppColors.primaryFixed,
      textColor: AppColors.onPrimaryFixed,
      leading: Icon(Icons.stars, size: 14, color: AppColors.primary),
    );
  }

  /// Factory untuk Badge 100% Offline
  factory StatusBadge.offlineTrust() {
    return StatusBadge(
      label: '100% Offline & Privat • Tanpa Akun',
      backgroundColor: AppColors.secondaryContainer,
      textColor: AppColors.onSecondaryContainer,
      leading: Icon(Icons.cloud_off, size: 14, color: AppColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.secondaryContainer;
    final effectiveText = textColor ?? AppColors.onSecondaryContainer;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasPulseDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: dotColor ?? effectiveText,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ] else if (leading != null) ...[
            leading!,
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: effectiveText,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

