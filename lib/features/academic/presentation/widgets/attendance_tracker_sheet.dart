import 'package:flutter/material.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_card.dart';

/// Bottom Sheet Pelacak Presensi & Kalkulator Jatah Bolos Kuliah (Aturan 75% UAS)
class AttendanceTrackerSheet extends StatefulWidget {
  const AttendanceTrackerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AttendanceTrackerSheet(),
    );
  }

  @override
  State<AttendanceTrackerSheet> createState() => _AttendanceTrackerSheetState();
}

class _AttendanceTrackerSheetState extends State<AttendanceTrackerSheet> {
  final SakuKuliahState _appState = SakuKuliahState.instance;

  // Local state for attendance records per course
  // In a real session, this is tracked per course: {code: {hadir: int, izin: int, alpa: int}}
  late Map<String, Map<String, int>> _attendanceData;

  @override
  void initState() {
    super.initState();
    _initAttendanceData();
  }

  void _initAttendanceData() {
    final courses = _appState.krsCourses;
    _attendanceData = {};

    if (courses.isNotEmpty) {
      for (int i = 0; i < courses.length; i++) {
        final c = courses[i];
        // Give realistic default based on index
        final hadir = 12 + (i % 3);
        final izin = (i % 2);
        final alpa = (i == 1) ? 1 : 0;
        _attendanceData[c.courseCode] = {
          'hadir': hadir.clamp(0, 16),
          'izin': izin.clamp(0, 16),
          'alpa': alpa.clamp(0, 16),
        };
      }
    } else {
      // Default courses if KRS hasn't been imported yet
      _attendanceData = {
        'TI-301': {'hadir': 13, 'izin': 1, 'alpa': 0},
        'TI-302': {'hadir': 14, 'izin': 0, 'alpa': 0},
        'TI-303': {'hadir': 12, 'izin': 1, 'alpa': 1},
        'TI-304': {'hadir': 13, 'izin': 0, 'alpa': 1},
        'TI-305': {'hadir': 14, 'izin': 0, 'alpa': 0},
      };
    }
  }

  void _increment(String code, String type) {
    setState(() {
      final current = _attendanceData[code] ?? {'hadir': 12, 'izin': 0, 'alpa': 0};
      final total = (current['hadir'] ?? 0) + (current['izin'] ?? 0) + (current['alpa'] ?? 0);
      if (total < 16) {
        current[type] = (current[type] ?? 0) + 1;
        _attendanceData[code] = current;
      }
    });
  }

  void _decrement(String code, String type) {
    setState(() {
      final current = _attendanceData[code] ?? {'hadir': 12, 'izin': 0, 'alpa': 0};
      if ((current[type] ?? 0) > 0) {
        current[type] = (current[type] ?? 0) - 1;
        _attendanceData[code] = current;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courses = _appState.krsCourses;

    // Calculate overall stats
    int totalHadir = 0;
    int totalMeetings = 0;
    _attendanceData.forEach((_, val) {
      final h = val['hadir'] ?? 0;
      final i = val['izin'] ?? 0;
      final a = val['alpa'] ?? 0;
      totalHadir += h;
      totalMeetings += (h + i + a);
    });

    final overallRate = totalMeetings > 0 ? (totalHadir / totalMeetings) * 100 : 92.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header Bar & Handle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.fact_check_rounded,
                            size: 18,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pelacak Presensi & Jatah Absen',
                              style: AppTypography.headlineSm.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Aturan Wajib Hadir Min. 75% untuk Ikut UAS',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0x22F4DCE4)),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Attendance Highlight Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE8F5E9),
                          Color(0xFFF1F8E9),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFA5D6A7), width: 1.2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${overallRate.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Presensi Keseluruhan',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1B5E20),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                overallRate >= 75
                                    ? 'Aman! Kamu memenuhi syarat minimal 75% kehadiran untuk mengikuti seluruh ujian UAS 🌸✨'
                                    : 'Perhatian! Kehadiran di bawah 75%, segera ikuti kelas pengganti ⚠️',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF33691E),
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Rule Explanation Pill
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Keterangan: 1 Semester = 16 pertemuan. Batas maksimal tidak hadir (izin/alpa) adalah 4 kali per mata kuliah.',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Daftar Mata Kuliah Semester Ini',
                    style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Course Attendance Cards
                  if (courses.isNotEmpty)
                    ...courses.map((course) {
                      final data = _attendanceData[course.courseCode] ?? {'hadir': course.attendancePresent, 'izin': 0, 'alpa': 0};
                      return _buildCourseAttendanceCard(
                        title: course.courseName,
                        code: course.courseCode,
                        sks: course.sks,
                        lecturer: 'Dosen Pengampu',
                        hadir: data['hadir'] ?? 0,
                        izin: data['izin'] ?? 0,
                        alpa: data['alpa'] ?? 0,
                      );
                    })
                  else
                    PastelCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.fact_check_rounded, size: 36, color: AppColors.primaryContainer),
                            const SizedBox(height: 8),
                            Text(
                              'Belum ada mata kuliah 🌸',
                              style: AppTypography.headlineSm.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Daftar presensi akan otomatis muncul di sini setelah kamu menambahkan jadwal kelas atau scan KRS.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseAttendanceCard({
    required String title,
    required String code,
    required int sks,
    required String lecturer,
    required int hadir,
    required int izin,
    required int alpa,
  }) {
    const int totalPertemuan = 16;
    final int totalTidakHadir = izin + alpa;
    final int sisaBolosAman = 4 - totalTidakHadir;
    final double persentase = (hadir / totalPertemuan) * 100;

    // Status safety color
    Color statusBgColor;
    Color statusTextColor;
    String statusText;
    IconData statusIcon;

    if (sisaBolosAman >= 2) {
      statusBgColor = const Color(0xFFE8F5E9);
      statusTextColor = const Color(0xFF2E7D32);
      statusText = 'Aman (Bisa izin $sisaBolosAman x lagi)';
      statusIcon = Icons.check_circle_rounded;
    } else if (sisaBolosAman == 1) {
      statusBgColor = const Color(0xFFFFF9C4);
      statusTextColor = const Color(0xFFF57F17);
      statusText = 'Waspada! Sisa 1x jatah absen';
      statusIcon = Icons.warning_rounded;
    } else {
      statusBgColor = const Color(0xFFFFEBEE);
      statusTextColor = const Color(0xFFC62828);
      statusText = 'Bahaya! Jangan absen lagi untuk ikut UAS';
      statusIcon = Icons.dangerous_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PastelCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Code, SKS & Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    code,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$sks SKS',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 12, color: statusTextColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              title,
              style: AppTypography.headlineSm.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (lecturer.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                lecturer,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 10),

            // Progress Bar of 16 Meetings
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: LinearProgressIndicator(
                      value: (hadir / totalPertemuan).clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: const Color(0x33F4DCE4),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        persentase >= 75 ? AppColors.primary : const Color(0xFFE57373),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${persentase.toStringAsFixed(0)}% ($hadir/$totalPertemuan)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Attendance Counters (+ / -)
            Row(
              children: [
                Expanded(
                  child: _buildCounterPill(
                    label: 'Hadir',
                    count: hadir,
                    color: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                    onIncrement: () => _increment(code, 'hadir'),
                    onDecrement: () => _decrement(code, 'hadir'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCounterPill(
                    label: 'Izin',
                    count: izin,
                    color: const Color(0xFFF57F17),
                    bgColor: const Color(0xFFFFF9C4),
                    onIncrement: () => _increment(code, 'izin'),
                    onDecrement: () => _decrement(code, 'izin'),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildCounterPill(
                    label: 'Alpa',
                    count: alpa,
                    color: const Color(0xFFC62828),
                    bgColor: const Color(0xFFFFEBEE),
                    onIncrement: () => _increment(code, 'alpa'),
                    onDecrement: () => _decrement(code, 'alpa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterPill({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              '$label: $count',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onDecrement,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.remove, size: 11, color: color),
                ),
              ),
              const SizedBox(width: 3),
              InkWell(
                onTap: onIncrement,
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(Icons.add, size: 11, color: color),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

