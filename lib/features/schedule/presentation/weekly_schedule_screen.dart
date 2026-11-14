import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pastel_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/schedule_model.dart';
import '../../academic/presentation/widgets/scan_krs_khs_sheet.dart';
import '../../calendar/presentation/academic_calendar_screen.dart';
import 'widgets/add_schedule_sheet.dart';

/// Halaman Jadwal Kuliah Mingguan dengan Selector Hari Horizontal
class WeeklyScheduleScreen extends StatefulWidget {
  final int initialViewMode;

  const WeeklyScheduleScreen({super.key, this.initialViewMode = 0});

  @override
  State<WeeklyScheduleScreen> createState() => _WeeklyScheduleScreenState();
}

class _WeeklyScheduleScreenState extends State<WeeklyScheduleScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;
  late int _selectedDayIndex; // 0 = Senin, 1 = Selasa, dst.
  late int _viewMode; // 0 = Jadwal Mingguan, 1 = Kalender Akademik
  late List<Map<String, dynamic>> _days;

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialViewMode;
    final now = DateTime.now();
    _selectedDayIndex = (now.weekday - 1).clamp(0, 6);

    // Hitung tanggal dinamis minggu ini (Senin - Minggu)
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    _days = List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return {
        'day': dayLabels[i],
        'date': date.day.toString(),
        'isToday': date.day == now.day && date.month == now.month,
      };
    });
  }

  String _monthName(int m) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final daySchedules = _appState.schedules
            .where((ScheduleModel s) => s.dayOfWeek == _selectedDayIndex)
            .toList();
        final int totalSksDay = daySchedules.fold<int>(0, (int sum, ScheduleModel s) => sum + s.sks);

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(_viewMode == 0 ? 'Jadwal Kuliah Mingguan' : 'Kalender Akademik'),
            actions: [
              IconButton(
                tooltip: _viewMode == 0 ? 'Buka Kalender Akademik' : 'Buka Jadwal Mingguan',
                icon: Icon(
                  _viewMode == 0 ? Icons.calendar_month_rounded : Icons.calendar_view_week_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _viewMode = _viewMode == 0 ? 1 : 0;
                  });
                },
              ),
              IconButton(
                tooltip: 'Scan KRS',
                icon: Icon(Icons.document_scanner_rounded, color: AppColors.primary),
                onPressed: () => ScanKrsKhsSheet.show(context),
              ),
              if (_viewMode == 0)
                IconButton(
                  tooltip: 'Tambah Manual',
                  icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                  onPressed: () {
                    AddScheduleSheet.show(context, onSave: (schedule) {
                      _appState.addSchedule(schedule);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Jadwal kuliah berhasil disimpan! 🌸')),
                      );
                    });
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              // Segmented Tab Switcher: Jadwal Mingguan vs Kalender Akademik
              Container(
                margin: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _viewMode = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _viewMode == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: _viewMode == 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_view_week_rounded,
                                size: 15,
                                color: _viewMode == 0 ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Jadwal Mingguan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _viewMode == 0 ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _viewMode = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _viewMode == 1 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: _viewMode == 1
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 15,
                                color: _viewMode == 1 ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Kalender Akademik',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _viewMode == 1 ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // View content
              Expanded(
                child: _viewMode == 1
                    ? const AcademicCalendarScreen(isEmbedded: true)
                    : SafeArea(
                        top: false,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Semester & SKS Info Strip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_days[_selectedDayIndex]['day']}, ${_days[_selectedDayIndex]['date']} ${_monthName(DateTime.now().month)} ${DateTime.now().year}',
                        style: AppTypography.labelMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '$totalSksDay SKS Hari Ini',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSecondaryFixed,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Horizontal Day Selector
                  SizedBox(
                    height: 78,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final item = _days[index];
                        final isSelected = _selectedDayIndex == index;
                        final count = _appState.schedules
                            .where((ScheduleModel s) => s.dayOfWeek == index)
                            .length;
                        final isHoliday = index >= 5;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDayIndex = index;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 58,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['day'] as String,
                                  style: AppTypography.labelSm.copyWith(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : AppColors.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['date'] as String,
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : AppColors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : AppColors.secondaryContainer,
                                    borderRadius: BorderRadius.circular(9999),
                                  ),
                                  child: Text(
                                    isHoliday && count == 0 ? 'Libur' : '$count Matkul',
                                    style: AppTypography.labelSm.copyWith(
                                      fontSize: 8.5,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.onSecondaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Schedule Timeline for Selected Day
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Jadwal ${AppConstants.daysOfWeek[_selectedDayIndex]}',
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${daySchedules.length} Kelas',
                        style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (daySchedules.isEmpty)
                    PastelCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.beach_access_rounded, size: 36, color: AppColors.primaryContainer),
                            const SizedBox(height: 8),
                            Text(
                              'Tidak ada jadwal kuliah hari ini ✨',
                              style: AppTypography.headlineSm.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tekan tombol + di atas untuk menambahkan jadwal kelas baru.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...daySchedules.map((ScheduleModel schedule) {
                      final isFirst = daySchedules.indexOf(schedule) == 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: PastelCard(
                          accentColor: isFirst ? AppColors.primaryContainer : AppColors.secondary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      StatusBadge.sks(schedule.sks),
                                      const SizedBox(width: 6),
                                      StatusBadge(
                                        label: schedule.category,
                                        backgroundColor: AppColors.tertiaryFixed,
                                        textColor: AppColors.onTertiaryFixedVariant,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                                        tooltip: 'Edit Jadwal',
                                        onPressed: () {
                                          AddScheduleSheet.show(
                                            context,
                                            initialSchedule: schedule,
                                            onSave: (updated) {
                                              _appState.updateSchedule(updated);
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Jadwal kuliah berhasil diperbarui! 🌸')),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                        tooltip: 'Hapus Jadwal',
                                        onPressed: () {
                                          _appState.deleteSchedule(schedule.id!);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Jadwal berhasil dihapus')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.schedule, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${schedule.startTime} - ${schedule.endTime} WIB',
                                    style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(width: 14),
                                  Icon(Icons.meeting_room_outlined, size: 15, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    schedule.room,
                                    style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.w600),
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
        ),
      ],
    ),
  );
},
);
}
}
