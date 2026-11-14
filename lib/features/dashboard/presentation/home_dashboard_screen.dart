import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/animated_count_text.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/fade_slide_entry.dart';
import '../../../core/widgets/pastel_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../academic/presentation/widgets/attendance_tracker_sheet.dart';
import '../../academic/presentation/widgets/ipk_simulator_sheet.dart';
import '../../academic/presentation/widgets/scan_krs_khs_sheet.dart';
import '../../calendar/models/academic_event_model.dart';
import '../../calendar/presentation/academic_calendar_screen.dart';
import '../../calendar/presentation/widgets/add_exam_event_sheet.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../notes/presentation/widgets/add_note_sheet.dart';
import '../../profile/models/student_profile_model.dart';
import '../../schedule/models/schedule_model.dart';
import '../../schedule/presentation/widgets/add_schedule_sheet.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/presentation/widgets/add_task_sheet.dart';
import '../../tasks/presentation/widgets/pomodoro_timer_sheet.dart';
import '../../wallet/presentation/wallet_screen.dart';
import '../../vault/presentation/student_vault_screen.dart';
import 'widgets/campus_notification_sheet.dart';

/// Halaman Home Dashboard resmi SakuKuliah dengan State Reaktif
class HomeDashboardScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSchedule;
  final VoidCallback? onNavigateToTasks;
  final VoidCallback? onNavigateToAcademic;
  final VoidCallback? onNavigateToNotes;
  final VoidCallback? onNavigateToProfile;

  const HomeDashboardScreen({
    super.key,
    this.onNavigateToSchedule,
    this.onNavigateToTasks,
    this.onNavigateToAcademic,
    this.onNavigateToNotes,
    this.onNavigateToProfile,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;
  late DateTime _currentTime;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final now = DateTime.now();
        // Hanya update tampilan saat menit atau tanggal berganti agar hemat daya & tidak kelap-kelip
        if (now.minute != _currentTime.minute || now.day != _currentTime.day) {
          setState(() {
            _currentTime = now;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  String _getGreeting() {
    final hour = _currentTime.hour;
    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _getFormattedDate() {
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final dayName = days[(_currentTime.weekday - 1).clamp(0, 6)];
    final day = _currentTime.day;
    final monthName = months[(_currentTime.month - 1).clamp(0, 11)];
    final year = _currentTime.year;
    return '$dayName, $day $monthName $year';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final profile = _appState.studentProfile;
        final todayDayOfWeek = (_currentTime.weekday - 1) % 7;
        final todaySchedules = _appState.schedules.where((ScheduleModel s) => s.dayOfWeek == todayDayOfWeek).toList();
        final pendingTasks = _appState.tasks.where((TaskModel t) => !t.isCompleted).toList();
        final urgentTasks = pendingTasks.where((TaskModel t) => t.priority == 'Tinggi').toList();
        final sksSemester = _appState.krsCourses.fold<int>(0, (sum, c) => sum + c.sks);
        final activeCoursesCount = _appState.krsCourses.length;
        final attendanceRate = _appState.krsCourses.isNotEmpty
            ? _appState.krsCourses
                    .map((c) => c.attendanceTotal > 0 ? (c.attendancePresent / c.attendanceTotal) * 100 : 100.0)
                    .reduce((a, b) => a + b) /
                _appState.krsCourses.length
            : 0.0;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Header Bar
                  _buildTopHeader(profile),

                  const SizedBox(height: 16),

                  // 2. Greeting Hero Banner
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 60),
                    child: _buildGreetingHero(profile.name, profile.currentSemester, profile.major),
                  ),

                  const SizedBox(height: 16),

                  // 3. Quick-Stats 3 Metric Cards
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 120),
                    child: _buildQuickStats(
                      sksSemester: sksSemester,
                      activeCoursesCount: activeCoursesCount,
                      pendingTasksCount: pendingTasks.length,
                      urgentTasksCount: urgentTasks.length,
                      attendanceRate: attendanceRate,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. Quick Action Pill Row
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 180),
                    child: _buildQuickActionRow(context),
                  ),

                  const SizedBox(height: 18),

                  // 5. Academic Highlights / IPK Milestone Banner
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 240),
                    child: _buildIpkMilestoneBanner(
                      ipk: profile.cumulativeIpk,
                      completedSks: profile.completedSks,
                      totalSks: profile.totalSks,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 5b. Upcoming Exams (UTS & UAS Countdown Banner)
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 270),
                    child: _buildUpcomingExamsSection(context, _appState.academicEvents),
                  ),

                  const SizedBox(height: 22),

                  // 6. Today's Class Schedule Section
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 300),
                    child: _buildTodayScheduleSection(todaySchedules),
                  ),

                  const SizedBox(height: 22),

                  // 7. Urgent Tasks Section
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 360),
                    child: _buildUrgentTasksSection(pendingTasks),
                  ),

                  const SizedBox(height: 18),

                  // 7b. Dompet Pastel & Uang Saku Mahasiswa
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 390),
                    child: _buildWalletSummaryCard(context),
                  ),

                  const SizedBox(height: 18),

                  // 8. Warm Micro-encouragement Footer Card
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 420),
                    child: _buildEncouragementCard(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 1. Top Header Bar
  Widget _buildTopHeader(StudentProfileModel profile) {
    final hour = _currentTime.hour.toString().padLeft(2, '0');
    final minute = _currentTime.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // SakuKuliah Cute Mini Logo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time_filled_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    timeStr,
                    style: AppTypography.labelMd.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_done_rounded, size: 12, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    'Offline Ready',
                    style: AppTypography.labelSm.copyWith(
                      fontSize: 10,
                      color: AppColors.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                CampusNotificationSheet.show(
                  context,
                  onNavigateToTasks: widget.onNavigateToTasks,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerLowest,
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  if ((_appState.academicEvents.length +
                          _appState.tasks.where((t) => !t.isCompleted).length +
                          _appState.campusBills.where((b) => !b.isPaid).length) >
                      0)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '${_appState.academicEvents.length + _appState.tasks.where((t) => !t.isCompleted).length + _appState.campusBills.where((b) => !b.isPaid).length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppAvatar(
              avatarBase64: profile.avatarBase64,
              avatarPreset: profile.avatarPreset,
              name: profile.name,
              size: 36,
              borderWidth: 2,
              onTap: widget.onNavigateToProfile,
            ),
          ],
        ),
      ],
    );
  }

  // 2. Greeting Hero Banner
  Widget _buildGreetingHero(String name, int semester, String major) {
    final hasName = name.trim().isNotEmpty;
    final hasMajor = major.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today_rounded, size: 11, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _getFormattedDate(),
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          hasName ? '${_getGreeting()}, $name! ✨' : '${_getGreeting()}! ✨',
          style: AppTypography.headlineLgMobile.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hasMajor ? 'Semester $semester • $major' : 'Semester $semester • Profil belum diatur',
          style: AppTypography.bodyMd.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // 3. Quick-Stats 3 Metric Cards
  Widget _buildQuickStats({
    required int sksSemester,
    required int activeCoursesCount,
    required int pendingTasksCount,
    required int urgentTasksCount,
    required double attendanceRate,
  }) {
    return Row(
      children: [
        // Metric 1: SKS
        Expanded(
          child: PastelCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: AppColors.onPrimaryFixedVariant,
                      ),
                    ),
                    Text(
                      'Sem ${_appState.studentProfile.currentSemester}',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$sksSemester SKS',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$activeCoursesCount Matkul Aktif',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Metric 2: Tugas Pending
        Expanded(
          child: PastelCard(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.pending_actions_rounded,
                        size: 16,
                        color: AppColors.onSecondaryFixedVariant,
                      ),
                    ),
                    Text(
                      '$urgentTasksCount Urgen',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '$pendingTasksCount Tugas',
                  style: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Belum tuntas',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Metric 3: Presensi
        Expanded(
          child: InkWell(
            onTap: () => AttendanceTrackerSheet.show(context),
            borderRadius: BorderRadius.circular(16),
            child: PastelCard(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryFixed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.onTertiaryFixedVariant,
                        ),
                      ),
                      Text(
                        activeCoursesCount == 0 ? '0 Matkul' : '>75%',
                        style: AppTypography.labelSm.copyWith(
                          color: activeCoursesCount == 0 ? AppColors.onSurfaceVariant : AppColors.tertiary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activeCoursesCount == 0 ? '-' : '${attendanceRate.toStringAsFixed(1)}%',
                    style: AppTypography.headlineSm.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    activeCoursesCount == 0 ? 'Belum ada matkul' : 'Cek Absen 75% 🔍',
                    style: AppTypography.labelSm.copyWith(
                      color: activeCoursesCount == 0 ? AppColors.onSurfaceVariant : AppColors.primary,
                      fontWeight: activeCoursesCount == 0 ? FontWeight.normal : FontWeight.bold,
                      fontSize: 10,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 4. Quick Action Grid Menu (8 Fitur Pintar Pas 1 Layar Tanpa Terpotong)
  Widget _buildQuickActionRow(BuildContext context) {
    final actions = [
      _QuickActionItem(
        label: 'Dompet',
        icon: Icons.account_balance_wallet_rounded,
        bgColor: AppColors.primaryContainer,
        iconColor: AppColors.onPrimaryContainer,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const WalletScreen()),
          );
        },
      ),
      _QuickActionItem(
        label: 'Jadwal Ujian',
        icon: Icons.event_available_rounded,
        bgColor: AppColors.secondaryContainer,
        iconColor: AppColors.onSecondaryContainer,
        onTap: () => AddExamEventSheet.show(context),
      ),
      _QuickActionItem(
        label: 'Mode Ambis',
        icon: Icons.hourglass_top_rounded,
        bgColor: AppColors.tertiaryContainer,
        iconColor: AppColors.onTertiaryContainer,
        onTap: () => PomodoroTimerSheet.show(context),
      ),
      _QuickActionItem(
        label: 'Scan KRS/KHS',
        icon: Icons.document_scanner_rounded,
        bgColor: AppColors.primaryFixed,
        iconColor: AppColors.onPrimaryFixedVariant,
        onTap: () => ScanKrsKhsSheet.show(context),
      ),
      _QuickActionItem(
        label: 'Brankas',
        icon: Icons.folder_special_rounded,
        bgColor: AppColors.secondaryContainer,
        iconColor: AppColors.onSecondaryContainer,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StudentVaultScreen()),
          );
        },
      ),
      _QuickActionItem(
        label: 'Kalender',
        icon: Icons.calendar_month_rounded,
        bgColor: AppColors.secondaryFixed,
        iconColor: AppColors.onSecondaryFixedVariant,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AcademicCalendarScreen()),
          );
        },
      ),
      _QuickActionItem(
        label: 'Catatan',
        icon: Icons.auto_stories_rounded,
        bgColor: AppColors.surfaceContainerHigh,
        iconColor: AppColors.primary,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotesScreen()),
          );
        },
      ),
      _QuickActionItem(
        label: 'Simulasi IPK',
        icon: Icons.calculate_rounded,
        bgColor: AppColors.primaryContainer,
        iconColor: AppColors.primary,
        onTap: () => IpkSimulatorSheet.show(context),
      ),
      _QuickActionItem(
        label: 'Presensi 75%',
        icon: Icons.fact_check_rounded,
        bgColor: AppColors.secondaryContainer,
        iconColor: AppColors.secondary,
        onTap: () => AttendanceTrackerSheet.show(context),
      ),
    ];

    return PastelCard(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.onPrimaryContainer),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Fitur & Akses Cepat Mahasiswa',
                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '8 Fitur',
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 9.5,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12,
              crossAxisSpacing: 6,
              childAspectRatio: 0.88,
            ),
            itemCount: actions.length,
            itemBuilder: (context, i) {
              final item = actions[i];
              return QuickActionTile(
                label: item.label,
                icon: item.icon,
                bgColor: item.bgColor,
                iconColor: item.iconColor,
                onTap: item.onTap,
              );
            },
          ),
        ],
      ),
    );
  }

  // 5. Academic Highlights / IPK Milestone Banner
  Widget _buildIpkMilestoneBanner({
    required double ipk,
    required int completedSks,
    required int totalSks,
  }) {
    final progress = totalSks > 0 ? (completedSks / totalSks) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryFixed,
            AppColors.secondaryFixed,
            AppColors.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(217, 139, 174, 0.18),
            blurRadius: 20,
            offset: Offset(0, 6),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        ipk >= 3.50
                            ? 'Cumlaude Track'
                            : (ipk > 0 ? 'Target Terjaga' : 'Mulai Semester Ini 🌱'),
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Semester ${_appState.studentProfile.currentSemester}',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onPrimaryFixedVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimatedCountText(
                      value: ipk,
                      fractionDigits: 2,
                      style: AppTypography.displayLg.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryFixed,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'IPK Kumulatif',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onPrimaryFixedVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withValues(alpha: 0.6),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$completedSks dari $totalSks Total SKS Selesai (${(progress * 100).toInt()}%)',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onPrimaryFixedVariant,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 4,
                    backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                Icon(
                  Icons.military_tech_rounded,
                  size: 24,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5b. Upcoming Exams (UTS & UAS Countdown Banner)
  Widget _buildUpcomingExamsSection(BuildContext context, List<AcademicEventModel> events) {
    final now = DateTime.now();
    final upcoming = events.where((e) {
      final d = DateTime.tryParse(e.eventDate);
      if (d == null) return false;
      return d.isAfter(now.subtract(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    if (upcoming.isEmpty) return const SizedBox.shrink();

    final nextExam = upcoming.first;
    final nextDate = DateTime.tryParse(nextExam.eventDate);
    int daysLeft = 0;
    if (nextDate != null) {
      daysLeft = nextDate.difference(DateTime(now.year, now.month, now.day)).inDays;
    }

    final isUts = nextExam.eventType.toUpperCase() == 'UTS';
    final isUas = nextExam.eventType.toUpperCase() == 'UAS';

    return PastelCard(
      accentColor: isUts ? AppColors.primary : (isUas ? AppColors.tertiary : AppColors.secondary),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isUts ? AppColors.primaryContainer : AppColors.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '🔥 JADWAL ${nextExam.eventType.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: isUts ? AppColors.onPrimaryContainer : AppColors.onTertiaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    daysLeft == 0 ? 'Hari Ini! 🔥' : (daysLeft == 1 ? 'Besok! ⏳' : 'Tinggal $daysLeft Hari Lagi ⏳'),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AcademicCalendarScreen()),
                  );
                },
                child: Text('Lihat Semua >', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nextExam.title,
            style: AppTypography.headlineSm.copyWith(fontSize: 14.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 12.5, color: AppColors.onSurfaceVariant),
              const SizedBox(width: 5),
              Text(
                nextExam.eventDate,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 10),
              if (nextExam.startTime != null && nextExam.startTime!.isNotEmpty) ...[
                Icon(Icons.access_time_rounded, size: 12.5, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 5),
                Text(
                  '${nextExam.startTime} WIB',
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 10),
              ],
              if (nextExam.location != null && nextExam.location!.isNotEmpty) ...[
                Icon(Icons.room_outlined, size: 12.5, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    nextExam.location!,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 6. Today's Class Schedule Section
  Widget _buildTodayScheduleSection(List<ScheduleModel> todaySchedules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Jadwal Kuliah Hari Ini',
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => widget.onNavigateToSchedule?.call(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Lihat Semua',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (todaySchedules.isEmpty)
          PastelCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Tidak ada jadwal kuliah hari ini. Waktunya istirahat! 🌸',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          ...todaySchedules.map((ScheduleModel schedule) {
            final isFirst = todaySchedules.indexOf(schedule) == 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PastelCard(
                accentColor: isFirst ? AppColors.primary : AppColors.secondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isFirst) ...[
                          StatusBadge.ongoing(label: 'Segera Dimulai'),
                          const SizedBox(width: 6),
                        ],
                        StatusBadge.sks(schedule.sks),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.courseName,
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dosen: ${schedule.lecturer}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                '${schedule.startTime} - ${schedule.endTime} WIB',
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                schedule.room,
                                style: AppTypography.labelSm.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
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
    );
  }

  // 7. Urgent Tasks Section
  Widget _buildUrgentTasksSection(List<TaskModel> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      'Tugas Mendekati Deadline',
                      style: AppTypography.headlineSm.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '${tasks.length} Pending',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onErrorContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => widget.onNavigateToTasks?.call(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Kelola',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (tasks.isEmpty)
          PastelCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                _appState.studentProfile.name.trim().isNotEmpty
                    ? 'Semua tugas telah selesai. Kerja bagus, ${_appState.studentProfile.name.trim().split(' ').first}! 💖'
                    : 'Semua tugas telah selesai. Kerja bagus! 💖',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          ...tasks.take(2).map((TaskModel task) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: PastelCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _appState.toggleTaskCompletion(task.id!),
                      child: AnimatedScale(
                        scale: task.isCompleted ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(top: 2),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: task.isCompleted ? AppColors.primary : AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: task.isCompleted ? AppColors.primary : AppColors.outlineVariant,
                              width: 1.2,
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: task.isCompleted
                                ? const Icon(Icons.check_rounded, key: ValueKey('checked'), size: 16, color: Colors.white)
                                : const SizedBox.shrink(key: ValueKey('unchecked')),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  task.courseName,
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 10,
                                    color: AppColors.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              task.priority == 'Tinggi'
                                  ? StatusBadge.urgent(label: 'Tinggi')
                                  : StatusBadge.mediumPriority(label: 'Sedang'),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.title,
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              color: task.isCompleted ? AppColors.outline : AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.alarm,
                                size: 14,
                                color: task.priority == 'Tinggi' ? AppColors.error : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${task.dueDate} • ${task.dueTime}',
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 11,
                                  color: task.priority == 'Tinggi' ? AppColors.error : AppColors.onSurfaceVariant,
                                  fontWeight: task.priority == 'Tinggi' ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
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
    );
  }

  // 7b. Dompet Pastel & Uang Saku Mahasiswa Card
  Widget _buildWalletSummaryCard(BuildContext context) {
    final balance = _appState.totalBalance;
    final safeDaily = _appState.safeToSpendDaily;
    final pendingBills = _appState.pendingBillsCount;

    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return PastelCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WalletScreen()),
        );
      },
      accentColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, size: 16, color: AppColors.onSecondaryContainer),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Dompet Pastel & Uang Saku 👛',
                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Buka Saku',
                    style: AppTypography.labelSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 10.5,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.primary),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sisa Saldo Saku',
                      style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatter.format(balance),
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: balance >= 0 ? AppColors.onSurface : AppColors.error,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(height: 28, width: 1, color: AppColors.cardBorder),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jatah Jajan Aman',
                      style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _appState.monthlyBudget <= 0 ? 'Belum diatur' : '${formatter.format(safeDaily)} /hr',
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: _appState.monthlyBudget <= 0 ? 13 : 14.5,
                        fontWeight: FontWeight.w800,
                        color: _appState.monthlyBudget <= 0 ? AppColors.onSurfaceVariant : AppColors.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (pendingBills > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Ada $pendingBills tagihan kampus / kas kelas yang belum lunas.',
                      style: AppTypography.bodySm.copyWith(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 8. Warm Micro-encouragement Footer Card
  Widget _buildEncouragementCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite_rounded,
              size: 20,
              color: AppColors.onTertiaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Semangat belajarnya hari ini!',
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Satu per satu tugas selesai, langkahmu makin dekat ke kelulusan.',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  _QuickActionItem({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
}

/// Tile tombol aksi cepat bergaya grid pastel beranimasi tactile spring bounce
class QuickActionTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.onTap,
  });

  @override
  State<QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<QuickActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        if (mounted) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (mounted) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (mounted) setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: widget.bgColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.bgColor.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 22,
                  color: widget.iconColor,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSm.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
                height: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
