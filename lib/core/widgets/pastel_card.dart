import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Kartu bernuansa pastel dengan rounded corner, bayangan lembut,
/// dan animasi sentuhan membal (tactile spring bounce feedback) yang responsif
class PastelCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? accentColor; // Warna strip vertikal di sisi kiri kartu
  final VoidCallback? onTap;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final bool enableBounce;

  const PastelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.borderRadius = 16,
    this.backgroundColor,
    this.accentColor,
    this.onTap,
    this.border,
    this.boxShadow,
    this.enableBounce = true,
  });

  @override
  State<PastelCard> createState() => _PastelCardState();
}

class _PastelCardState extends State<PastelCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: widget.padding,
      child: widget.child,
    );

    // Jika memiliki strip aksen di sisi kiri (seperti pada Jadwal & Tugas Card)
    if (widget.accentColor != null) {
      content = Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: Container(
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(widget.borderRadius),
                  bottomLeft: Radius.circular(widget.borderRadius),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: content,
          ),
        ],
      );
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    content = DefaultTextStyle.merge(
      style: TextStyle(
        color: isDark ? const Color(0xFFF6EEF8) : const Color(0xFF1E1A22),
      ),
      child: content,
    );

    final cardWidget = Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: widget.border ??
            Border.all(
              color: AppColors.cardBorder,
              width: 1,
            ),
        boxShadow: widget.boxShadow ??
            (isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : AppColors.cardShadow),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    if (widget.onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) {
          if (widget.enableBounce && mounted) {
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) {
          if (widget.enableBounce && mounted) {
            setState(() => _isPressed = false);
          }
        },
        onTapCancel: () {
          if (widget.enableBounce && mounted) {
            setState(() => _isPressed = false);
          }
        },
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isPressed ? 0.965 : 1.0,
          duration: Duration(milliseconds: _isPressed ? 90 : 220),
          curve: _isPressed ? Curves.easeOutQuad : Curves.easeOutBack,
          child: cardWidget,
        ),
      );
    }

    return cardWidget;
  }
}
