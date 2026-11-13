import 'package:flutter/material.dart';

/// Widget animasi angka berhitung naik (Counter Roll-Up)
/// Menghidupkan angka IPK, SKS, dan Persentase saat layar dimuat
class AnimatedCountText extends StatelessWidget {
  final double value;
  final String suffix;
  final String prefix;
  final int fractionDigits;
  final TextStyle? style;
  final Duration duration;

  const AnimatedCountText({
    super.key,
    required this.value,
    this.suffix = '',
    this.prefix = '',
    this.fractionDigits = 2,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        final text = val.toStringAsFixed(fractionDigits);
        return Text('$prefix$text$suffix', style: style);
      },
    );
  }
}

