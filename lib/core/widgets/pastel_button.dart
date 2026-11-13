import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum PastelButtonType { primary, primaryBlush, secondary, outlined, ghost }

/// Tombol berbentuk pill lembut bergaya SakuKuliah dengan animasi tactile spring bounce
class PastelButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PastelButtonType type;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const PastelButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = PastelButtonType.primary,
    this.leadingIcon,
    this.trailingIcon,
    this.width,
    this.height = 48,
    this.borderRadius = 9999,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  State<PastelButton> createState() => _PastelButtonState();
}

class _PastelButtonState extends State<PastelButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;

    switch (widget.type) {
      case PastelButtonType.primary:
        bgColor = AppColors.primary;
        textColor = AppColors.onPrimary;
        border = null;
        break;
      case PastelButtonType.primaryBlush:
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimaryContainer;
        border = null;
        break;
      case PastelButtonType.secondary:
        bgColor = AppColors.secondaryContainer;
        textColor = AppColors.onSecondaryContainer;
        border = null;
        break;
      case PastelButtonType.outlined:
        bgColor = Colors.transparent;
        textColor = AppColors.onSurface;
        border = Border.all(color: AppColors.primaryContainer, width: 1.5);
        break;
      case PastelButtonType.ghost:
        bgColor = Colors.transparent;
        textColor = AppColors.onSurfaceVariant;
        border = null;
        break;
    }

    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: Duration(milliseconds: _isPressed ? 80 : 200),
      curve: _isPressed ? Curves.easeOutQuad : Curves.easeOutBack,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTapDown: (_) {
              if (mounted) setState(() => _isPressed = true);
            },
            onTapUp: (_) {
              if (mounted) setState(() => _isPressed = false);
            },
            onTapCancel: () {
              if (mounted) setState(() => _isPressed = false);
            },
            onTap: widget.onPressed,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: border,
                boxShadow: (widget.type == PastelButtonType.primary)
                    ? [
                        const BoxShadow(
                          color: Color.fromRGBO(128, 80, 99, 0.25),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.leadingIcon != null) ...[
                    widget.leadingIcon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: AppTypography.labelLg.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    widget.trailingIcon!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
