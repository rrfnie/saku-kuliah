import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/data/national_holidays.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pastel_card.dart';
import '../models/academic_event_model.dart';
import 'widgets/add_exam_event_sheet.dart';

/// Halaman Kalender Akademik & Jadwal Ujian (UTS, UAS, Praktikum, Libur)
class AcademicCalendarScreen extends StatefulWidget {
  final bool isEmbedded;

  const AcademicCalendarScreen({super.key, this.isEmbedded = false});

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;

  late DateTime _currentMonth;
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDay = now.day;
  }

  String _monthName(int m) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  String _dayName(int w) {
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return days[(w - 1).clamp(0, 6)];
  }

  Color _getEventTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'UTS':
        return AppColors.primary;
      case 'UAS':
        return AppColors.tertiary;
      case 'UJIAN PRAKTIKUM':
      case 'PRAKTIKUM':
        return AppColors.secondary;
      case 'KUIS':
        return const Color(0xFFB06000);
      case 'LIBUR':
        return const Color(0xFF2E7D32);
      default:
        return AppColors.primary;
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'UTS':
        return Icons.edit_note_rounded;
      case 'UAS':
        return Icons.school_rounded;
      case 'UJIAN PRAKTIKUM':
      case 'PRAKTIKUM':
        return Icons.terminal_rounded;
      case 'KUIS':
        return Icons.quiz_outlined;
      case 'LIBUR':
        return Icons.beach_access_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  String _formatDateStr(DateTime d) {
    return DateFormat('yyyy-MM-dd').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _appState,
      builder: (context, _) {
        final now = DateTime.now();
        final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
        final clampedSelectedDay = _selectedDay.clamp(1, daysInMonth);

        final selectedDate = DateTime(_currentMonth.year, _currentMonth.month, clampedSelectedDay);
        final selectedDateStr = _formatDateStr(selectedDate);

        final isCurrentSelectedToday = clampedSelectedDay == now.day &&
            _currentMonth.month == now.month &&
            _currentMonth.year == now.year;

        // Events on selected day
        final eventsOnDay = _appState.academicEvents.where((e) => e.eventDate == selectedDateStr).toList();

        // All upcoming exam events (UTS / UAS / Praktikum)
        final upcomingExams = _appState.academicEvents.where((e) {
          final eventD = DateTime.tryParse(e.eventDate);
          if (eventD == null) return false;
          return eventD.isAfter(now.subtract(const Duration(days: 1)));
        }).toList()
          ..sort((a, b) => a.eventDate.compareTo(b.eventDate));

        final body = SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Action Banner: + Tambah Jadwal UTS / UAS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF8B4969),
                        Color(0xFFA5668B),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x228B4969),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Agenda UTS, UAS & Ujian 🎓',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${upcomingExams.length} agenda ujian mendatang tercatat',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text(
                          'Tambah',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        onPressed: () {
                          AddExamEventSheet.show(context, initialDate: selectedDate);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Month Selector Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            _currentMonth.month >= 7 && _currentMonth.month <= 12
                                ? 'Semester Ganjil'
                                : 'Semester Genap',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left, color: AppColors.primary),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right, color: AppColors.primary),
                          onPressed: () {
                            setState(() {
                              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Calendar Grid Card
                PastelCard(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      // Day of Week Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: ['S', 'S', 'R', 'K', 'J', 'S', 'M'].map((day) {
                          return SizedBox(
                            width: 36,
                            child: Center(
                              child: Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                      // Dynamic Calendar Grid
                      _buildDynamicCalendarGrid(daysInMonth),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ── Info Libur Bulan Ini ──────────────────────────
                Builder(builder: (context) {
                  final holidaysThisMonth = NationalHolidays.getHolidaysInMonth(
                    _currentMonth.year,
                    _currentMonth.month,
                  );
                  if (holidaysThisMonth.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🔴', style: TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(
                            'Libur Nasional Bulan Ini (${holidaysThisMonth.length})',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.error,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...holidaysThisMonth.entries.map((entry) {
                        final parts = entry.key.split('-');
                        final day = int.parse(parts[2]);
                        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), day);
                        const dayNames = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
                        final dayName = dayNames[date.weekday - 1];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDay = day),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.errorContainer.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.errorContainer,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$day',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.value,
                                        style: AppTypography.labelSm.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        '$dayName, ${entry.key}',
                                        style: AppTypography.bodySm.copyWith(
                                          fontSize: 10,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.beach_access_rounded, size: 16, color: AppColors.error),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 10),
                    ],
                  );
                }),

                // Legend Pills Horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLegendItem(AppColors.primary, 'UTS'),
                      const SizedBox(width: 6),
                      _buildLegendItem(AppColors.tertiary, 'UAS'),
                      const SizedBox(width: 6),
                      _buildLegendItem(AppColors.secondary, 'Praktikum'),
                      const SizedBox(width: 6),
                      _buildLegendItem(const Color(0xFFB06000), 'Kuis / Ujian'),
                      const SizedBox(width: 6),
                      _buildLegendItem(const Color(0xFF2E7D32), 'Libur Kampus'),
                      const SizedBox(width: 6),
                      _buildLegendItem(AppColors.error, 'Libur Nasional 🔴'),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Agenda Header for Selected Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_dayName(selectedDate.weekday)}, $clampedSelectedDay ${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 15, color: AppColors.primary),
                      label: const Text(
                        'Tambah Ujian',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      onPressed: () {
                        AddExamEventSheet.show(context, initialDate: selectedDate);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ── Banner Libur Nasional pada hari yang dipilih ──
                Builder(builder: (context) {
                  final holidayName = NationalHolidays.getHolidayName(selectedDateStr);
                  final isSundaySelected = selectedDate.weekday == DateTime.sunday;
                  final isRedSelected = holidayName != null || isSundaySelected;
                  if (!isRedSelected) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Text('🔴', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                holidayName ?? 'Hari Minggu',
                                style: AppTypography.labelMd.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                'Hari Libur${holidayName != null ? " Nasional" : ""} — Tidak ada perkuliahan 🌸',
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 10.5,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.beach_access_rounded, size: 22, color: AppColors.error),
                      ],
                    ),
                  );
                }),

                // Agenda List on Selected Day
                if (eventsOnDay.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0x33D98BAE)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.event_available_outlined, size: 36, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada ujian atau agenda di tanggal ini 🌸',
                          style: AppTypography.labelMd.copyWith(color: AppColors.onSurfaceVariant),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: AppColors.onPrimaryContainer,
                            elevation: 0,
                            shape: const StadiumBorder(),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('+ Tambah UTS / UAS di Tanggal Ini'),
                          onPressed: () {
                            AddExamEventSheet.show(context, initialDate: selectedDate);
                          },
                        ),
                      ],
                    ),
                  )
                else
                  ...eventsOnDay.map((e) => _buildExamCard(e)),

                const SizedBox(height: 22),

                // All Upcoming Exams / UTS / UAS Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Semua Jadwal Ujian Mendatang (${upcomingExams.length})',
                      style: AppTypography.headlineSm.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Semester ${_appState.studentProfile.currentSemester}',
                      style: AppTypography.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (upcomingExams.isEmpty)
                  PastelCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Belum ada jadwal ujian semester ini. Tekan tombol Tambah untuk mencatat UTS / UAS yaa! 🌸',
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...upcomingExams.map((e) => _buildExamCard(e, showDateBadge: true)),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );

        if (widget.isEmbedded) {
          return body;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Kalender Akademik & Ujian'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                tooltip: 'Tambah Jadwal Ujian',
                onPressed: () => AddExamEventSheet.show(context, initialDate: selectedDate),
              ),
            ],
          ),
          body: body,
        );
      },
    );
  }

  Widget _buildExamCard(AcademicEventModel e, {bool showDateBadge = false}) {
    final typeColor = _getEventTypeColor(e.eventType);
    final typeIcon = _getEventTypeIcon(e.eventType);

    // Hitung countdown hari
    final eventDate = DateTime.tryParse(e.eventDate);
    String countdownStr = '';
    if (eventDate != null) {
      final now = DateTime.now();
      final diff = eventDate.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (diff == 0) {
        countdownStr = 'Hari Ini! 🔥';
      } else if (diff == 1) {
        countdownStr = 'Besok! ⏳';
      } else if (diff > 1) {
        countdownStr = 'H-$diff Hari ⏳';
      } else {
        countdownStr = 'Selesai ✓';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PastelCard(
        accentColor: typeColor,
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(typeIcon, size: 22, color: typeColor),
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
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          e.eventType.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (countdownStr.isNotEmpty)
                        Text(
                          countdownStr,
                          style: TextStyle(
                            color: countdownStr.contains('Hari Ini') || countdownStr.contains('Besok')
                                ? AppColors.error
                                : AppColors.primary,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    e.title,
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (showDateBadge) ...[
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          e.eventDate,
                          style: AppTypography.bodySm.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (e.startTime != null && e.startTime!.isNotEmpty) ...[
                        const Icon(Icons.access_time, size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${e.startTime} - ${e.endTime ?? ''} WIB',
                          style: AppTypography.bodySm.copyWith(fontSize: 10.5),
                        ),
                      ],
                    ],
                  ),
                  if (e.location != null && e.location!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.room_outlined, size: 12, color: AppColors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            e.location!,
                            style: AppTypography.bodySm.copyWith(fontSize: 10.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (e.notes != null && e.notes!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '💡 ${e.notes!}',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              tooltip: 'Hapus Agenda',
              onPressed: () {
                if (e.id != null) {
                  _appState.deleteAcademicEvent(e.id!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Agenda "${e.title}" berhasil dihapus 🌸'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSecondaryContainer,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicCalendarGrid(int daysInMonth) {
    final now = DateTime.now();

    // Hitung offset: Desember 2026 mulai Selasa → offset = 1 (Mon=0, Tue=1, ...)
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final startOffset = firstDay.weekday - 1; // Mon=0, Tue=1, ..., Sun=6

    final totalRows = ((startOffset + daysInMonth) / 7).ceil();

    return Table(
      defaultColumnWidth: const FlexColumnWidth(),
      children: List.generate(totalRows, (row) {
        return TableRow(
          children: List.generate(7, (col) {
            final dayNumber = row * 7 + col - startOffset + 1;

            // Sel kosong sebelum tanggal 1 atau sesudah akhir bulan
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox(height: 44);
            }

            final thisDate = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
            final dateStr = _formatDateStr(thisDate);

            final isToday = dayNumber == now.day &&
                _currentMonth.month == now.month &&
                _currentMonth.year == now.year;
            final isSelected = _selectedDay == dayNumber;

            // Hari libur nasional & Minggu (tanggal merah)
            final isHoliday = NationalHolidays.isHoliday(dateStr);
            final isSunday = thisDate.weekday == DateTime.sunday;
            final isRedDay = isHoliday || isSunday;

            // Event dot
            final dayEvents = _appState.academicEvents
                .where((e) => e.eventDate == dateStr)
                .toList();
            Color? dotColor;
            if (dayEvents.isNotEmpty) {
              dotColor = _getEventTypeColor(dayEvents.first.eventType);
            }

            // Warna teks tanggal
            Color textColor;
            if (isToday) {
              textColor = AppColors.primary;
            } else if (isSelected && !isRedDay) {
              textColor = AppColors.primary;
            } else if (isRedDay) {
              textColor = AppColors.error;
            } else {
              textColor = AppColors.onSurface;
            }

            return GestureDetector(
              onTap: () => setState(() => _selectedDay = dayNumber),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 1),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: isToday
                        ? AppColors.primaryContainer
                        : isSelected
                            ? AppColors.secondaryContainer
                            : isHoliday
                                ? AppColors.errorContainer.withValues(alpha: 0.3)
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday
                        ? Border.all(color: AppColors.primary, width: 1.2)
                        : isHoliday && !isSelected && !isToday
                            ? Border.all(
                                color: AppColors.error.withValues(alpha: 0.2),
                                width: 0.8)
                            : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday || isSelected || isRedDay
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (dotColor != null)
                        Container(
                          width: 5.5,
                          height: 5.5,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        )
                      else if (isHoliday)
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5.5),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }

}
