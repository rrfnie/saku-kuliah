import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pastel_button.dart';
import '../../../core/widgets/status_badge.dart';
import 'widgets/first_time_setup_sheet.dart';

/// Halaman Splash dan Onboarding interaktif feminine pastel SakuKuliah
/// Didesain presisi agar responsif, tanpa overflow, dan bebas terpotong di semua jenis layar HP
class SplashOnboardingScreen extends StatefulWidget {
  final VoidCallback onFinishOnboarding;

  const SplashOnboardingScreen({
    super.key,
    required this.onFinishOnboarding,
  });

  @override
  State<SplashOnboardingScreen> createState() => _SplashOnboardingScreenState();
}

class _SplashOnboardingScreenState extends State<SplashOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            // Mode ringkas jika layar HP mungil (< 680px)
            final isCompact = screenHeight < 680;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: screenHeight),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    isCompact ? 8 : 14,
                    20,
                    isCompact ? 16 : 28, // Ruang lega agar tombol bawah tidak mepet home bar HP
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bagian Atas: Header Brand & Emblem
                      Column(
                        children: [
                          _buildBrandHeader(isCompact),
                          SizedBox(height: isCompact ? 10 : 14),

                          // Bagian Tengah: Carousel Slide Interaktif
                          SizedBox(
                            height: isCompact ? 245 : 265,
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: _onPageChanged,
                              children: [
                                _buildSlideSchedule(isCompact),
                                _buildSlideTasks(isCompact),
                                _buildSlideGpa(isCompact),
                              ],
                            ),
                          ),

                          SizedBox(height: isCompact ? 8 : 12),

                          // Indikator Titik Halaman
                          _buildPaginationDots(),

                          SizedBox(height: isCompact ? 10 : 14),

                          // Banner Kepercayaan Offline
                          _buildOfflineTrustCard(),
                        ],
                      ),

                      // Bagian Bawah: Tombol Aksi Mulai & Lewati
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PastelButton(
                              text: 'Mulai Sekarang',
                              width: double.infinity,
                              height: 48,
                              trailingIcon: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                FirstTimeSetupSheet.show(
                                  context,
                                  onComplete: widget.onFinishOnboarding,
                                );
                              },
                            ),
                            const SizedBox(height: 6),
                            PastelButton(
                              text: 'Lewati Pengenalan',
                              type: PastelButtonType.ghost,
                              height: 38,
                              onPressed: widget.onFinishOnboarding,
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Header Brand SakuKuliah dengan Emblem Manis Bergradasi Pastel
  Widget _buildBrandHeader(bool isCompact) {
    final emblemSize = isCompact ? 54.0 : 66.0;

    return Column(
      children: [
        // SakuKuliah Emblem Icon dengan Soft Ambient Halo
        Stack(
          alignment: Alignment.center,
          children: [
            // Ambient Soft Halo
            Container(
              width: emblemSize + 22,
              height: emblemSize + 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryContainer.withValues(alpha: 0.35),
              ),
            ),
            // Official Squircle Logo
            Container(
              width: emblemSize,
              height: emblemSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(emblemSize * 0.28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1AD98BAE),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(emblemSize * 0.28),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isCompact ? 6 : 8),

        // App Name
        Text(
          AppConstants.appName,
          style: AppTypography.headlineLgMobile.copyWith(
            fontSize: isCompact ? 21 : 23,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),

        // Tagline
        Text(
          AppConstants.appTagline,
          style: AppTypography.bodyMd.copyWith(
            fontSize: isCompact ? 12 : 13,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        SizedBox(height: isCompact ? 6 : 8),

        // Offline Badge
        StatusBadge.offlineTrust(),
      ],
    );
  }

  // Slide 1: Jadwal Kuliah & Ruangan
  Widget _buildSlideSchedule(bool isCompact) {
    return _buildSlideCard(
      accentColor: AppColors.primaryContainer,
      illustration: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    '08:00 - 10:30 WIB',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 9,
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'R. Lab 302',
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 9.5,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Interaksi Manusia & Komputer',
              style: AppTypography.headlineSm.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Icon(Icons.person_outline, size: 12, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    'Dr. Retno Wulandari, M.Kom',
                    style: AppTypography.bodySm.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      badgeText: 'Pengingat kelas aktif tanpa kuota',
      badgeIcon: Icons.schedule_rounded,
      badgeColor: AppColors.primary,
      title: 'Atur Jadwal Kuliah & Ruangan',
      description:
          'Jadwal kuliah mingguan rapi, kode ruangan akurat, dan pengingat kelas otomatis tepat waktu.',
      isCompact: isCompact,
    );
  }

  // Slide 2: Tugas & Deadline Prioritas
  Widget _buildSlideTasks(bool isCompact) {
    return _buildSlideCard(
      accentColor: AppColors.tertiaryContainer,
      illustration: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'Besok, 23:59',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 9,
                      color: AppColors.onErrorContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.flag_rounded, size: 15, color: AppColors.primary),
              ],
            ),
            const SizedBox(height: 5),
            Text(
              'Proposal Skripsi Bab 1-3',
              style: AppTypography.headlineSm.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Metodologi Riset',
                  style: AppTypography.bodySm.copyWith(fontSize: 10),
                ),
                Text(
                  'Prioritas Tinggi',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.primary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      badgeText: 'Bebas cemas deadline menumpuk',
      badgeIcon: Icons.check_circle_outline_rounded,
      badgeColor: AppColors.tertiary,
      title: 'Pantau Tugas & Prioritas',
      description:
          'Kelola tugas kuliah dengan status teratur, estimasi waktu, serta pengingat tenggat yang presisi.',
      isCompact: isCompact,
    );
  }

  // Slide 3: Kalkulator IPK & Pantau SKS
  Widget _buildSlideGpa(bool isCompact) {
    return _buildSlideCard(
      accentColor: AppColors.primary,
      illustration: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // IPK Stat Box
          Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'PREDIKSI IPK',
                  style: AppTypography.labelSm.copyWith(fontSize: 8, letterSpacing: 0.3),
                ),
                Text(
                  '3.88',
                  style: AppTypography.displayLg.copyWith(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Cumlaude',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // SKS Counter Box
          Container(
            width: 96,
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'TOTAL SKS',
                  style: AppTypography.labelSm.copyWith(fontSize: 8, letterSpacing: 0.3),
                ),
                Text(
                  '118',
                  style: AppTypography.displayLg.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'dari 144 SKS',
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 8.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      badgeText: 'Simulasi nilai lokal otomatis',
      badgeIcon: Icons.calculate_outlined,
      badgeColor: AppColors.primary,
      title: 'Kalkulator IPK & Pantau SKS',
      description:
          'Simulasi target nilai semester, kelola KRS mandiri, serta rekap kehadiran kuliah tanpa batas.',
      isCompact: isCompact,
    );
  }

  // Komponen Kartu Carousel yang Bebas Overflow & Rapi
  Widget _buildSlideCard({
    required Color accentColor,
    required Widget illustration,
    required String badgeText,
    required IconData badgeIcon,
    required Color badgeColor,
    required String title,
    required String description,
    required bool isCompact,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14D98BAE),
            blurRadius: 16,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Garis aksen warna pastel di atas kartu
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 4,
            child: Container(color: accentColor),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14, isCompact ? 10 : 12, 14, isCompact ? 10 : 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Area Ilustrasi Mockup Kartu
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      illustration,
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(badgeIcon, size: 12, color: badgeColor),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 9,
                              color: badgeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: isCompact ? 6 : 8),

                // Judul Slide
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTypography.headlineSm.copyWith(
                    fontSize: isCompact ? 14.5 : 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Deskripsi Slide
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd.copyWith(
                    fontSize: isCompact ? 11 : 11.5,
                    height: 1.3,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Titik Navigasi Halaman Carousel
  Widget _buildPaginationDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final bool isActive = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          height: 5,
          width: isActive ? 20 : 5,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(9999),
          ),
        );
      }),
    );
  }

  // Kartu Jaminan Offline (100% Privat)
  Widget _buildOfflineTrustCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 3,
                ),
              ],
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 15,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppConstants.offlinePledge,
              style: AppTypography.bodySm.copyWith(
                fontSize: 10.5,
                color: AppColors.onSurfaceVariant,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
