import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_count_text.dart';
import '../../../core/widgets/fade_slide_entry.dart';
import '../../../core/widgets/pastel_button.dart';
import '../../../core/widgets/pastel_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/course_krs_model.dart';
import 'widgets/attendance_tracker_sheet.dart';
import 'widgets/ipk_simulator_sheet.dart';
import 'widgets/scan_krs_khs_sheet.dart';
import 'widgets/semester_history_sheet.dart';

/// Halaman Akademik dan Kalkulator / Simulasi IPK dengan State Reaktif
class AcademicScreen extends StatefulWidget {
  const AcademicScreen({super.key});

  @override
  State<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends State<AcademicScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;

  void _openIpkSimulator() {
    IpkSimulatorSheet.show(
      context,
      onApplied: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final profile = _appState.studentProfile;
        final courses = _appState.krsCourses;
        final totalSks = courses.fold<int>(0, (sum, c) => sum + c.sks);
        final ips = _appState.calculatePredictedIps();
        final progress = profile.totalSks > 0 ? (profile.completedSks / profile.totalSks) : 0.0;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Akademik & Nilai'),
            actions: [
              IconButton(
                tooltip: 'Scan KRS / KHS',
                icon: Icon(Icons.document_scanner_rounded, color: AppColors.primary),
                onPressed: () => ScanKrsKhsSheet.show(context),
              ),
              IconButton(
                tooltip: 'Riwayat KHS & Transkrip',
                icon: Icon(Icons.history_edu_rounded, color: AppColors.primary),
                onPressed: () => SemesterHistorySheet.show(context),
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Semester Selector Dropdown Pill & Riwayat KHS Button (Responsive & Adaptive)
                  Row(
                    children: [
                      // Jenjang, Semester & Tahun Akademik Pill
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.school_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${profile.degreeLevel.startsWith("D3") ? "D3" : (profile.degreeLevel.startsWith("S1") ? "S1" : profile.degreeLevel)} • Sem ${profile.currentSemester} • ${profile.academicYear}',
                                  style: AppTypography.labelMd.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 11.5,
                                    color: AppColors.onSurface,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Tombol Riwayat KHS
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => SemesterHistorySheet.show(context),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.history_edu_rounded, size: 14, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  'Riwayat KHS 📜',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Hero Academic KPI Card
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 60),
                    child: _buildHeroAcademicCard(
                      ipk: profile.cumulativeIpk,
                      ips: ips,
                      completedSks: profile.completedSks,
                      totalSks: profile.totalSks,
                      progress: progress,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // IPK Simulator Button / Interactive Banner
                  PastelCard(
                    onTap: _openIpkSimulator,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.calculate_rounded,
                            size: 22,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Simulasi & Kalkulator IPK',
                                style: AppTypography.labelLg.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Rancang target nilai & uji skenario kelulusan',
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.chevron_right, size: 20, color: AppColors.primary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Presensi Kuliah Metric Card
                  PastelCard(
                    onTap: () => AttendanceTrackerSheet.show(context),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.fact_check_rounded,
                            size: 20,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Rekap Presensi Kuliah',
                                    style: AppTypography.labelMd.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Builder(
                                    builder: (context) {
                                      final avgAttendance = courses.isEmpty
                                          ? 0.0
                                          : (courses.fold<double>(0.0, (sum, c) => sum + c.attendancePercentage) / courses.length);
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: courses.isEmpty
                                              ? AppColors.surfaceContainerHigh
                                              : (avgAttendance >= 75.0 ? AppColors.secondaryFixed : AppColors.errorContainer),
                                          borderRadius: BorderRadius.circular(9999),
                                        ),
                                        child: Text(
                                          courses.isEmpty ? '0 Matkul' : '${avgAttendance.toStringAsFixed(0)}%',
                                          style: AppTypography.labelSm.copyWith(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: courses.isEmpty
                                                ? AppColors.onSurfaceVariant
                                                : (avgAttendance >= 75.0 ? AppColors.onSecondaryFixedVariant : AppColors.error),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                courses.isEmpty
                                    ? 'Belum ada data absensi kuliah'
                                    : 'Pantauan batas 75% kehadiran ujian akhir 🎯',
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 11,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 20, color: AppColors.secondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Course Grade Management (KRS Aktif)
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Mata Kuliah Semester ${profile.currentSemester}',
                                style: AppTypography.headlineSm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(9999),
                              ),
                              child: Text(
                                '${courses.length} Matkul',
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 10,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$totalSks SKS Total',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (courses.isEmpty)
                    PastelCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.menu_book_rounded, size: 36, color: AppColors.primaryContainer),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada mata kuliah semester ini 🌸',
                              style: AppTypography.headlineSm.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Scan KRS otomatis atau tambahkan mata kuliah untuk memantau target nilai dan presensi perkuliahan.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 14),
                            PastelButton(
                              text: 'Scan Dokumen KRS / KHS 📄',
                              leadingIcon: const Icon(Icons.document_scanner_rounded, size: 18, color: Colors.white),
                              onPressed: () => ScanKrsKhsSheet.show(context),
                              type: PastelButtonType.primary,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...courses.map((CourseKrsModel course) {
                    final hasWarning = course.isAttendanceWarning;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: PastelCard(
                        accentColor: hasWarning ? AppColors.tertiary : AppColors.primary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        course.courseName,
                                        style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${course.courseCode} • ${course.sks} SKS',
                                        style: AppTypography.bodySm.copyWith(
                                          fontSize: 11,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryFixed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Target: ${course.targetGrade} (${course.gradePoint.toStringAsFixed(2)})',
                                    style: AppTypography.labelSm.copyWith(
                                      color: AppColors.onPrimaryFixed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(
                                        hasWarning ? Icons.warning_amber_rounded : Icons.co_present_rounded,
                                        size: 15,
                                        color: hasWarning ? AppColors.error : AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Kehadiran: ${course.attendancePercentage.toStringAsFixed(0)}% (${course.attendancePresent}/${course.attendanceTotal})',
                                          style: AppTypography.bodySm.copyWith(
                                            fontSize: 11,
                                            color: hasWarning ? AppColors.error : AppColors.onSurfaceVariant,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                hasWarning
                                    ? StatusBadge.urgent(label: 'Butuh 1x hadir lagi')
                                    : StatusBadge(
                                        label: 'Aman',
                                        backgroundColor: AppColors.surfaceContainer,
                                        textColor: AppColors.onSurfaceVariant,
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeroAcademicCard({
    required double ipk,
    required double ips,
    required int completedSks,
    required int totalSks,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryFixed,
            AppColors.secondaryContainer,
            AppColors.surfaceContainerHigh,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(217, 139, 174, 0.18),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ipk >= 3.50)
                    StatusBadge.cumlaude(label: 'Dengan Pujian (Cumlaude)')
                  else if (ipk >= 3.00)
                    StatusBadge(
                      label: 'Sangat Memuaskan',
                      backgroundColor: AppColors.secondaryContainer,
                      textColor: AppColors.onSecondaryContainer,
                    )
                  else if (ipk > 0)
                    StatusBadge(
                      label: 'Memuaskan',
                      backgroundColor: AppColors.surfaceContainerHigh,
                      textColor: AppColors.onSurfaceVariant,
                    )
                  else
                    StatusBadge(
                      label: 'Mulai Semester Ini 🌱',
                      backgroundColor: AppColors.surfaceContainerLow,
                      textColor: AppColors.primary,
                    ),
                  const SizedBox(height: 6),
                  Text(
                    'Indeks Prestasi Kumulatif',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      AnimatedCountText(
                        value: ipk,
                        fractionDigits: 2,
                        style: AppTypography.displayLg.copyWith(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '/ 4.00',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(
                        value: (ipk / 4.0).clamp(0.0, 1.0),
                        strokeWidth: 4,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    Text(
                      '${((ipk / 4.0).clamp(0.0, 1.0) * 100).toInt()}%',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trending_up, size: 15, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            'IPS Terakhir',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ips.toStringAsFixed(2),
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ips > 0 ? 'Target aktif semester ini' : 'Belum ada nilai aktif',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9.5,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline, size: 15, color: AppColors.tertiary),
                          const SizedBox(width: 4),
                          Text(
                            'SKS Lulus',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$completedSks / $totalSks',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}% perjalanan',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 9.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
