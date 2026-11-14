import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../models/course_krs_model.dart';
import '../../models/semester_record_model.dart';

/// 🧠 Academic Intelligence — Smart Analytics untuk Mahasiswa SakuKuliah
/// Fitur: Predikat Tracker, Trend IPK Chart, Smart Warning, Target Nilai Pintar
class AcademicIntelligenceSheet extends StatefulWidget {
  const AcademicIntelligenceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AcademicIntelligenceSheet(),
    );
  }

  @override
  State<AcademicIntelligenceSheet> createState() => _AcademicIntelligenceSheetState();
}

class _AcademicIntelligenceSheetState extends State<AcademicIntelligenceSheet>
    with SingleTickerProviderStateMixin {
  final SakuKuliahState _appState = SakuKuliahState.instance;
  late TabController _tabController;

  // Tab untuk simulasi target nilai: target IPK yang diinginkan
  double _targetIpkInput = 3.50;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _targetIpkInput = _appState.studentProfile.targetIpk.clamp(2.00, 4.00);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Kalkulasi Predikat ─────────────────────────────────────────
  String _getPredikat(double ipk) {
    if (ipk >= 3.51) return 'Dengan Pujian (Cumlaude)';
    if (ipk >= 3.00) return 'Sangat Memuaskan';
    if (ipk >= 2.75) return 'Memuaskan';
    if (ipk >= 2.00) return 'Cukup';
    return 'Perlu Usaha Lebih';
  }

  Color _getPredikatColor(double ipk) {
    if (ipk >= 3.51) return const Color(0xFFB5538C);
    if (ipk >= 3.00) return AppColors.primary;
    if (ipk >= 2.75) return AppColors.tertiary;
    if (ipk >= 2.00) return AppColors.onSurfaceVariant;
    return AppColors.error;
  }

  // ── Smart Warning: matkul rawan gagal/rugi ────────────────────
  List<Map<String, dynamic>> _getSmartWarnings(List<CourseKrsModel> courses) {
    final List<Map<String, dynamic>> warnings = [];
    for (final c in courses) {
      // Warning 1: Absen hampir batas
      if (c.attendanceTotal > 0 && c.attendancePercentage < 80 && c.attendancePercentage >= 75) {
        warnings.add({
          'course': c,
          'type': 'attendance_near',
          'message': 'Kehadiran hampir batas 75%! (${c.attendancePercentage.toStringAsFixed(0)}%)',
          'severity': 'warning',
          'icon': Icons.warning_amber_rounded,
        });
      }
      // Warning 2: Absen sudah di bawah batas (kritis!)
      if (c.attendanceTotal > 0 && c.attendancePercentage < 75) {
        warnings.add({
          'course': c,
          'type': 'attendance_critical',
          'message': 'KRITIS! Absen di bawah 75% — Terancam tidak bisa UAS!',
          'severity': 'critical',
          'icon': Icons.dangerous_rounded,
        });
      }
      // Warning 3: Nilai target rendah (D atau E)
      if (c.gradePoint < 2.0) {
        warnings.add({
          'course': c,
          'type': 'low_grade',
          'message': 'Target nilai ${c.targetGrade} sangat rendah — Pertimbangkan mengulang!',
          'severity': 'warning',
          'icon': Icons.trending_down_rounded,
        });
      }
    }
    return warnings;
  }

  // ── Kalkulasi IPS rata-rata yg dibutuhkan ─────────────────────
  double _calcRequiredIpsThisSemester() {
    final profile = _appState.studentProfile;
    final courses = _appState.krsCourses;
    if (courses.isEmpty) return _targetIpkInput;

    final semSks = courses.fold<int>(0, (s, c) => s + c.sks);
    final completedSks = profile.completedSks;
    final currentIpk = profile.cumulativeIpk;

    // Formula: (targetIPK * (completedSks + semSks) - currentIPK * completedSks) / semSks
    if (semSks == 0) return _targetIpkInput;
    final required = (_targetIpkInput * (completedSks + semSks) - currentIpk * completedSks) / semSks;
    return required.clamp(0.0, 4.0);
  }

  // ── Mapping IPS required ke grade minimum ────────────────────
  String _ipsToGrade(double ips) {
    if (ips >= 4.00) return 'A (semua matkul)';
    if (ips >= 3.70) return 'A- rata-rata';
    if (ips >= 3.30) return 'B+ rata-rata';
    if (ips >= 3.00) return 'B rata-rata';
    if (ips >= 2.70) return 'B- rata-rata';
    if (ips >= 2.30) return 'C+ rata-rata';
    if (ips >= 2.00) return 'C rata-rata';
    return 'C minimum';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final profile = _appState.studentProfile;
        final courses = _appState.krsCourses;
        final history = _appState.semesterHistory;
        final currentIpk = profile.cumulativeIpk;
        final warnings = _getSmartWarnings(courses);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle bar
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.tertiary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Intelligence 🧠',
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Analitik cerdas perjalanan akademikmu',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (warnings.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.errorContainer,
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          '${warnings.length} Peringatan',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.error,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.onSurfaceVariant,
                  labelStyle: AppTypography.labelSm.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  unselectedLabelStyle: AppTypography.labelSm.copyWith(fontSize: 11),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: '🏆 Predikat'),
                    Tab(text: '📊 Trend IPK'),
                    Tab(text: '🎯 Target'),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // ── Tab 1: Predikat Tracker & Smart Warnings ──
                    _buildPredikatTab(currentIpk, profile.targetIpk, warnings, courses),

                    // ── Tab 2: Trend IPK Chart ──
                    _buildTrendTab(history, currentIpk, profile.currentSemester),

                    // ── Tab 3: Target Nilai Pintar ──
                    _buildTargetTab(courses, currentIpk, profile),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // TAB 1 — Predikat Tracker & Smart Warnings
  // ════════════════════════════════════════════════════════════════
  Widget _buildPredikatTab(
    double currentIpk,
    double targetIpk,
    List<Map<String, dynamic>> warnings,
    List<CourseKrsModel> courses,
  ) {
    final predikat = _getPredikat(currentIpk);
    final predikatColor = _getPredikatColor(currentIpk);

    // Milestone predikat
    final milestones = [
      {'label': 'Cukup', 'threshold': 2.00, 'emoji': '📗'},
      {'label': 'Memuaskan', 'threshold': 2.75, 'emoji': '📘'},
      {'label': 'Sgt Memuaskan', 'threshold': 3.00, 'emoji': '📙'},
      {'label': 'Cumlaude', 'threshold': 3.51, 'emoji': '🏆'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Predikat Hero Card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  predikatColor.withValues(alpha: 0.15),
                  AppColors.primaryFixed.withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: predikatColor.withValues(alpha: 0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('🎓', style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Predikat Saat Ini',
                            style: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            predikat,
                            style: AppTypography.headlineSm.copyWith(
                              fontWeight: FontWeight.bold,
                              color: predikatColor,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currentIpk.toStringAsFixed(2),
                          style: AppTypography.displayLg.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: predikatColor,
                          ),
                        ),
                        Text(
                          '/ 4.00 IPK',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Progress bar menuju predikat berikutnya
                _buildPredikatProgressBar(currentIpk),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Milestone Road Map ───────────────────────────────
          PastelCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.route_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Peta Jalan Predikat',
                      style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...milestones.map((m) {
                  final threshold = m['threshold'] as double;
                  final reached = currentIpk >= threshold;
                  final gap = (threshold - currentIpk).clamp(0.0, 4.0);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: reached
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHigh,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: reached
                                ? Icon(Icons.check_rounded, size: 16, color: AppColors.primary)
                                : Text(
                                    m['emoji'] as String,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${m['label']} (IPK ≥ ${threshold.toStringAsFixed(2)})',
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: reached ? AppColors.primary : AppColors.onSurface,
                                  fontSize: 11.5,
                                ),
                              ),
                              if (!reached)
                                Text(
                                  'Butuh +${gap.toStringAsFixed(2)} lagi dari IPK sekarang',
                                  style: AppTypography.bodySm.copyWith(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (reached)
                          StatusBadge(
                            label: '✓ Tercapai',
                            backgroundColor: AppColors.successContainer,
                            textColor: AppColors.onSuccess,
                          )
                        else if (gap < 0.3)
                          StatusBadge(
                            label: 'Hampir!',
                            backgroundColor: AppColors.warningContainer,
                            textColor: AppColors.onWarning,
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Smart Warnings ──────────────────────────────────
          if (warnings.isEmpty) ...[
            PastelCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.successContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.shield_rounded, color: AppColors.onSuccess, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semua Aman! 🌸',
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSuccess,
                          ),
                        ),
                        Text(
                          courses.isEmpty
                              ? 'Tambahkan mata kuliah untuk mulai analisis'
                              : 'Tidak ada peringatan akademik saat ini. Pertahankan!',
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.error),
                const SizedBox(width: 6),
                Text(
                  'Peringatan Akademik (${warnings.length})',
                  style: AppTypography.labelMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...warnings.map((w) {
              final course = w['course'] as CourseKrsModel;
              final isCritical = w['severity'] == 'critical';
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isCritical
                        ? AppColors.errorContainer
                        : AppColors.warningContainer,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCritical
                          ? AppColors.error.withValues(alpha: 0.3)
                          : AppColors.warning.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        w['icon'] as IconData,
                        size: 20,
                        color: isCritical ? AppColors.error : AppColors.onWarning,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              course.courseName,
                              style: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              w['message'] as String,
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 10.5,
                                color: isCritical ? AppColors.error : AppColors.onWarning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPredikatProgressBar(double ipk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress ke 4.00',
              style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
            Text(
              '${(ipk / 4.0 * 100).toStringAsFixed(1)}%',
              style: AppTypography.labelSm.copyWith(
                fontWeight: FontWeight.bold,
                color: _getPredikatColor(ipk),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalWidth = constraints.maxWidth;
                return Stack(
                  children: [
                    // Background track
                    Container(
                      width: totalWidth,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Colored fill up to IPK
                    Container(
                      width: totalWidth * (ipk / 4.0).clamp(0.0, 1.0),
                      height: 10,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.error,
                            AppColors.warning,
                            AppColors.primary,
                            const Color(0xFFB5538C),
                          ],
                          stops: const [0.0, 0.4, 0.7, 1.0],
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('0.00', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.onSurfaceVariant)),
            Text('2.00', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.onSurfaceVariant)),
            Text('3.00', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.onSurfaceVariant)),
            Text('3.51', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.onSurfaceVariant)),
            Text('4.00', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.onSurfaceVariant)),
          ],
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // TAB 2 — Trend IPK Chart (Pure Flutter, No Package!)
  // ════════════════════════════════════════════════════════════════
  Widget _buildTrendTab(
    List<SemesterRecordModel> history,
    double currentIpk,
    int currentSemester,
  ) {
    // Susun data chart: riwayat + semester sekarang
    final List<_ChartPoint> points = [];
    for (final h in history) {
      points.add(_ChartPoint(h.semesterNumber, h.ips, false));
    }
    // Tambah semester aktif dari KRS jika ada nilainya
    final activeIps = _appState.calculatePredictedIps();
    if (activeIps > 0) {
      points.add(_ChartPoint(currentSemester, activeIps, true));
    } else if (history.isEmpty) {
      // Empty state
    }
    points.sort((a, b) => a.semester.compareTo(b.semester));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Chart Card ───────────────────────────────────────
          PastelCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Grafik IPS per Semester',
                      style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        'IPK: ${currentIpk.toStringAsFixed(2)}',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (points.isEmpty)
                  SizedBox(
                    height: 160,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart_rounded, size: 42, color: AppColors.surfaceContainerHigh),
                          const SizedBox(height: 8),
                          Text(
                            'Belum ada data riwayat nilai 📊',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          Text(
                            'Tambah data KHS di menu Riwayat Semester',
                            style: AppTypography.bodySm.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 180,
                    child: _IpsLineChart(points: points),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── IPK Trend Statistics ─────────────────────────────
          if (points.length >= 2) ...[
            PastelCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.analytics_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Statistik Akademik',
                        style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildStatRow(
                    '📈 IPS Tertinggi',
                    points.map((p) => p.ips).reduce(math.max).toStringAsFixed(2),
                  ),
                  _buildStatRow(
                    '📉 IPS Terendah',
                    points.map((p) => p.ips).reduce(math.min).toStringAsFixed(2),
                  ),
                  _buildStatRow(
                    '📊 Rata-rata IPS',
                    (points.map((p) => p.ips).reduce((a, b) => a + b) / points.length)
                        .toStringAsFixed(2),
                  ),
                  _buildStatRow(
                    '🔢 Total Semester',
                    '${points.length} Semester',
                  ),
                  () {
                    final trend = points.last.ips - points[points.length >= 2 ? points.length - 2 : 0].ips;
                    return _buildStatRow(
                      '${trend >= 0 ? "🚀" : "⚠️"} Trend Terakhir',
                      '${trend >= 0 ? "+" : ""}${trend.toStringAsFixed(2)} dari semester lalu',
                      valueColor: trend >= 0 ? AppColors.success : AppColors.error,
                    );
                  }(),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── Riwayat Per Semester ─────────────────────────────
          if (history.isNotEmpty) ...[
            Text(
              'Riwayat IPS per Semester',
              style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...history.map((h) {
              final predikat = _getPredikat(h.ips);
              final pColor = _getPredikatColor(h.ips);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PastelCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: pColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'S${h.semesterNumber}',
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.bold,
                              color: pColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Semester ${h.semesterNumber} — ${h.academicYear}',
                              style: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                              ),
                            ),
                            Text(
                              '${h.sks} SKS • $predikat',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        h.ips.toStringAsFixed(2),
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: pColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(fontSize: 12),
          ),
          Text(
            value,
            style: AppTypography.labelSm.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: valueColor ?? AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // TAB 3 — Target Nilai Pintar
  // ════════════════════════════════════════════════════════════════
  Widget _buildTargetTab(
    List<CourseKrsModel> courses,
    double currentIpk,
    dynamic profile,
  ) {
    final requiredIps = _calcRequiredIpsThisSemester();
    final gradeNeeded = _ipsToGrade(requiredIps);
    final semSks = courses.fold<int>(0, (s, c) => s + c.sks);
    final isAchievable = requiredIps <= 4.0;
    final isCumlaude = _targetIpkInput >= 3.51;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Target IPK Slider ────────────────────────────────
          PastelCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.my_location_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'Target IPK Saya',
                      style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCumlaude ? AppColors.primaryContainer : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _targetIpkInput.toStringAsFixed(2),
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isCumlaude ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getPredikat(_targetIpkInput),
                  style: AppTypography.bodySm.copyWith(
                    color: _getPredikatColor(_targetIpkInput),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.surfaceContainerHigh,
                    thumbColor: AppColors.primary,
                    overlayColor: AppColors.primary.withValues(alpha: 0.15),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: _targetIpkInput,
                    min: 2.00,
                    max: 4.00,
                    divisions: 200,
                    onChanged: (val) => setState(() => _targetIpkInput = val),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('2.00 (Cukup)', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.onSurfaceVariant)),
                    Text('4.00 (Sempurna)', style: AppTypography.labelSm.copyWith(fontSize: 9, color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Hasil Kalkulasi ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isAchievable
                    ? [AppColors.primaryFixed, AppColors.secondaryContainer]
                    : [AppColors.errorContainer, AppColors.warningContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isAchievable
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.error.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isAchievable ? Icons.lightbulb_rounded : Icons.warning_rounded,
                      size: 18,
                      color: isAchievable ? AppColors.primary : AppColors.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAchievable ? 'Rekomendasi Nilai Semester Ini' : 'Target Sangat Sulit Dicapai!',
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isAchievable ? AppColors.primary : AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (semSks == 0) ...[
                  Text(
                    'Tambahkan mata kuliah KRS terlebih dahulu untuk melihat rekomendasi nilai.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                  ),
                ] else ...[
                  _buildInfoRow('IPK Sekarang', currentIpk.toStringAsFixed(2)),
                  _buildInfoRow('Target IPK', _targetIpkInput.toStringAsFixed(2)),
                  _buildInfoRow('SKS Semester Ini', '$semSks SKS'),
                  Divider(height: 16, color: AppColors.dividerColor),
                  _buildInfoRow(
                    'IPS yang Harus Dicapai',
                    requiredIps <= 4.0 ? requiredIps.toStringAsFixed(2) : '>4.00',
                    highlight: true,
                  ),
                  _buildInfoRow(
                    'Nilai Rata-rata Minimal',
                    gradeNeeded,
                    highlight: true,
                  ),
                  if (!isAchievable) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '⚠️ Target ini tidak bisa dicapai dalam 1 semester. '
                        'Turunkan target atau tingkatkan lebih bertahap.',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Per-Matkul Breakdown ────────────────────────────
          if (courses.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.list_alt_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Rincian per Mata Kuliah',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Target nilai berikut untuk mencapai IPS ${requiredIps.clamp(0.0, 4.0).toStringAsFixed(2)} '
              '(minimal rata-rata $gradeNeeded):',
              style: AppTypography.bodySm.copyWith(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...courses.map((c) {
              // Hitung nilai minimal yg direkomendasikan berdasarkan IPS yg diperlukan
              final minGrade = _recommendGradeForCourse(requiredIps.clamp(0.0, 4.0), c.gradePoint);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: PastelCard(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.courseName,
                              style: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${c.sks} SKS • Target saat ini: ${c.targetGrade}',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isAchievable ? AppColors.primaryContainer : AppColors.warningContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Min: $minGrade',
                              style: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                                color: isAchievable ? AppColors.primary : AppColors.onWarning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  String _recommendGradeForCourse(double requiredIps, double currentGradePoint) {
    // Pilih grade letter yg paling mendekati required IPS
    if (requiredIps >= 4.0) return 'A';
    if (requiredIps >= 3.7) return 'A-';
    if (requiredIps >= 3.3) return 'B+';
    if (requiredIps >= 3.0) return 'B';
    if (requiredIps >= 2.7) return 'B-';
    if (requiredIps >= 2.3) return 'C+';
    if (requiredIps >= 2.0) return 'C';
    return 'C minimum';
  }

  Widget _buildInfoRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodySm.copyWith(fontSize: 12),
          ),
          Text(
            value,
            style: AppTypography.labelSm.copyWith(
              fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
              fontSize: highlight ? 13 : 12,
              color: highlight ? AppColors.primary : AppColors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data point untuk chart ─────────────────────────────────────────
class _ChartPoint {
  final int semester;
  final double ips;
  final bool isActive;
  _ChartPoint(this.semester, this.ips, this.isActive);
}

// ── Line Chart Widget (Pure Flutter, No Package) ───────────────────
class _IpsLineChart extends StatelessWidget {
  final List<_ChartPoint> points;
  const _IpsLineChart({required this.points});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _LineChartPainter(points),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<_ChartPoint> points;
  _LineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    const paddingLeft = 36.0;
    const paddingBottom = 28.0;
    const paddingTop = 12.0;
    const paddingRight = 12.0;

    final chartW = size.width - paddingLeft - paddingRight;
    final chartH = size.height - paddingBottom - paddingTop;

    // Grid horizontal lines (0, 1, 2, 3, 4)
    final gridPaint = Paint()
      ..color = AppColors.outlineVariant.withValues(alpha: 0.5)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final labelStyle = TextStyle(
      color: AppColors.onSurfaceVariant,
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );

    for (int i = 0; i <= 4; i++) {
      final y = paddingTop + chartH - (i / 4.0) * chartH;
      canvas.drawLine(Offset(paddingLeft, y), Offset(size.width - paddingRight, y), gridPaint);

      // Y label
      final span = TextSpan(text: i.toStringAsFixed(0), style: labelStyle);
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(paddingLeft - tp.width - 4, y - tp.height / 2));
    }

    // Map points to canvas coords
    final int minSem = points.first.semester;
    final int maxSem = points.last.semester;
    final int semRange = (maxSem - minSem).clamp(1, 99);

    List<Offset> offsets = points.map((p) {
      final x = paddingLeft + ((p.semester - minSem) / semRange) * chartW;
      final y = paddingTop + chartH - (p.ips / 4.0) * chartH;
      return Offset(x, y);
    }).toList();

    // Area fill gradient
    if (offsets.length >= 2) {
      final fillPath = Path();
      fillPath.moveTo(offsets.first.dx, paddingTop + chartH);
      for (final o in offsets) {
        fillPath.lineTo(o.dx, o.dy);
      }
      fillPath.lineTo(offsets.last.dx, paddingTop + chartH);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withValues(alpha: 0.22),
            AppColors.primary.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, paddingTop, size.width, chartH))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, fillPaint);

      // Line
      final linePaint = Paint()
        ..color = AppColors.primary
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final linePath = Path();
      linePath.moveTo(offsets.first.dx, offsets.first.dy);
      for (int i = 1; i < offsets.length; i++) {
        // Smooth curve
        final prev = offsets[i - 1];
        final curr = offsets[i];
        final midX = (prev.dx + curr.dx) / 2;
        linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
      }
      canvas.drawPath(linePath, linePaint);
    }

    // Data points & X labels
    for (int i = 0; i < points.length; i++) {
      final o = offsets[i];
      final p = points[i];

      // Dot
      final dotPaint = Paint()
        ..color = p.isActive ? AppColors.tertiary : AppColors.primary
        ..style = PaintingStyle.fill;
      canvas.drawCircle(o, 5, dotPaint);

      final dotBorder = Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(o, 5, dotBorder);

      // IPS label above dot
      final ipsLabel = TextSpan(
        text: p.ips.toStringAsFixed(2),
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      );
      final ipsTP = TextPainter(text: ipsLabel, textDirection: TextDirection.ltr)..layout();
      ipsTP.paint(canvas, Offset(o.dx - ipsTP.width / 2, o.dy - ipsTP.height - 4));

      // Sem X label below chart
      final semLabel = TextSpan(
        text: 'S${p.semester}',
        style: TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 9,
        ),
      );
      final semTP = TextPainter(text: semLabel, textDirection: TextDirection.ltr)..layout();
      semTP.paint(canvas, Offset(o.dx - semTP.width / 2, size.height - paddingBottom + 4));
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) =>
      oldDelegate.points != points;
}

