import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/status_badge.dart';

/// Layar Splash & Loading bernuansa feminine pastel dengan animasi manis
class AppSplashLoadingScreen extends StatefulWidget {
  final VoidCallback onLoadingFinished;

  const AppSplashLoadingScreen({
    super.key,
    required this.onLoadingFinished,
  });

  @override
  State<AppSplashLoadingScreen> createState() => _AppSplashLoadingScreenState();
}

class _AppSplashLoadingScreenState extends State<AppSplashLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  double _progressValue = 0.0;
  Timer? _progressTimer;

  final List<String> _loadingMessages = [
    'Menyiapkan ruang belajarmu... 🌸',
    'Memuat jadwal kuliah offline... 📅',
    'Menghitung target SKS & IPK... 🎓',
    'Semua data siap di HP kamu! ✨',
  ];
  int _currentMessageIndex = 0;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.93, end: 1.06).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Animasi progress bar berjalan santai selama ~2.2 detik
    _progressTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (mounted) {
        setState(() {
          _progressValue += 0.02;
          if (_progressValue >= 0.3 && _currentMessageIndex == 0) {
            _currentMessageIndex = 1;
          } else if (_progressValue >= 0.65 && _currentMessageIndex == 1) {
            _currentMessageIndex = 2;
          } else if (_progressValue >= 0.9 && _currentMessageIndex == 2) {
            _currentMessageIndex = 3;
          }

          if (_progressValue >= 1.0) {
            _progressValue = 1.0;
            _progressTimer?.cancel();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                widget.onLoadingFinished();
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 3),

                // Logo Emblem dengan Animasi Breathing & Ambient Glow
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient Soft Pink Glow
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryContainer.withValues(alpha: 0.38),
                        ),
                      ),
                    ),

                    // Breathing Official Logo
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(217, 139, 174, 0.35),
                              blurRadius: 28,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nama Aplikasi
                Text(
                  AppConstants.appName,
                  style: AppTypography.displayLg.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 6),

                // Tagline Manis
                Text(
                  AppConstants.appTagline,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),

                // Trust Badge 100% Offline
                StatusBadge.offlineTrust(),

                const Spacer(flex: 2),

                // Teks status loading dinamis
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    _loadingMessages[_currentMessageIndex],
                    key: ValueKey<int>(_currentMessageIndex),
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Smooth Pastel Linear Progress Bar
                Container(
                  width: 220,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: LinearProgressIndicator(
                      value: _progressValue,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Persentase Angka
                Text(
                  '${(_progressValue * 100).toInt()}%',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.outline,
                    fontSize: 10,
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

