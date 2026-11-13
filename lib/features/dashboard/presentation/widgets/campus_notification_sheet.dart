import 'package:flutter/material.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_card.dart';
import '../../../calendar/presentation/academic_calendar_screen.dart';
import '../../../wallet/presentation/wallet_screen.dart';

/// Modal Bottom Sheet Pusat Pengingat & Notifikasi Kampus Mahasiswa (100% Offline)
class CampusNotificationSheet extends StatelessWidget {
  final VoidCallback? onNavigateToTasks;

  const CampusNotificationSheet({super.key, this.onNavigateToTasks});

  static Future<void> show(BuildContext context, {VoidCallback? onNavigateToTasks}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CampusNotificationSheet(onNavigateToTasks: onNavigateToTasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = SakuKuliahState.instance;
    final exams = state.academicEvents;
    final pendingTasks = state.tasks.where((t) => !t.isCompleted).toList();
    final unpaidBills = state.campusBills.where((b) => !b.isPaid).toList();
    final todayDayOfWeek = (DateTime.now().weekday - 1) % 7;
    final todaySchedules = state.schedules.where((s) => s.dayOfWeek == todayDayOfWeek).toList();

    final totalAlerts = exams.length + pendingTasks.length + unpaidBills.length;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pusat Notifikasi & Pengingat 🔔',
                          style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '$totalAlerts pengingat aktif kampus kamu',
                          style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0x22F4DCE4)),

          // Scrollable Notifications List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              children: [
                // 1. Pengingat Ujian Terdekat (UTS / UAS / Praktikum)
                if (exams.isNotEmpty) ...[
                  _buildSectionHeader('📝 JADWAL UJIAN MENDATANG', '${exams.length} Ujian'),
                  const SizedBox(height: 8),
                  ...exams.take(3).map((exam) {
                    return _buildNotificationTile(
                      context,
                      icon: Icons.event_note_rounded,
                      iconBg: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                      title: exam.title,
                      subtitle: 'Tanggal: ${exam.eventDate}${exam.startTime != null ? ' • ${exam.startTime}' : ''} ${exam.location != null ? ' • ${exam.location}' : ''}',
                      timeBadge: exam.eventType,
                      badgeColor: AppColors.primary,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AcademicCalendarScreen()),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 14),
                ],

                // 2. Pengingat Deadline Tugas Kuliah
                if (pendingTasks.isNotEmpty) ...[
                  _buildSectionHeader('⏳ DEADLINE TUGAS KULIAH', '${pendingTasks.length} Belum Selesai'),
                  const SizedBox(height: 8),
                  ...pendingTasks.take(3).map((task) {
                    final isUrgent = task.priority == 'Tinggi' || task.priority == 'Mendesak';
                    return _buildNotificationTile(
                      context,
                      icon: Icons.assignment_late_rounded,
                      iconBg: isUrgent ? AppColors.errorContainer : AppColors.secondaryContainer,
                      iconColor: isUrgent ? AppColors.error : AppColors.secondary,
                      title: task.title,
                      subtitle: '${task.courseName} • Batas: ${task.dueDate} (${task.dueTime})',
                      timeBadge: isUrgent ? 'Mendesak' : 'Aktif',
                      badgeColor: isUrgent ? AppColors.error : AppColors.secondary,
                      onTap: () {
                        Navigator.pop(context);
                        onNavigateToTasks?.call();
                      },
                    );
                  }),
                  const SizedBox(height: 14),
                ],

                // 3. Pengingat Tagihan Kampus & Kas
                if (unpaidBills.isNotEmpty) ...[
                  _buildSectionHeader('💸 TAGIHAN & KAS KELAS', '${unpaidBills.length} Belum Lunas'),
                  const SizedBox(height: 8),
                  ...unpaidBills.map((bill) {
                    return _buildNotificationTile(
                      context,
                      icon: Icons.receipt_long_rounded,
                      iconBg: AppColors.primaryContainer,
                      iconColor: AppColors.primary,
                      title: bill.title,
                      subtitle: 'Jatuh tempo: ${bill.dueDate} • Rp ${bill.amount.toInt()}',
                      timeBadge: 'Belum Lunas',
                      badgeColor: AppColors.error,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WalletScreen()),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 14),
                ],

                // 4. Jadwal Kuliah Hari Ini
                if (todaySchedules.isNotEmpty) ...[
                  _buildSectionHeader('📚 KELAS HARI INI', '${todaySchedules.length} Matkul'),
                  const SizedBox(height: 8),
                  ...todaySchedules.map((sch) {
                    return _buildNotificationTile(
                      context,
                      icon: Icons.school_rounded,
                      iconBg: AppColors.secondaryContainer,
                      iconColor: AppColors.secondary,
                      title: sch.courseName,
                      subtitle: '${sch.startTime} - ${sch.endTime} • Ruang ${sch.room}',
                      timeBadge: '${sch.sks} SKS',
                      badgeColor: AppColors.secondary,
                    );
                  }),
                  const SizedBox(height: 14),
                ],

                // Empty state if nothing active
                if (totalAlerts == 0)
                  PastelCard(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 40, color: AppColors.success),
                          const SizedBox(height: 10),
                          Text(
                            'Semua Tugas & Ujian Bersih! 🎉',
                            style: AppTypography.headlineSm.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tidak ada pengingat mendesak saat ini. Waktunya santai atau self-reward! 🌸✨',
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                // Offline Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.offline_pin_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notifikasi pintar ini diolah 100% lokal dari jadwal & tugas di HP kamu.',
                          style: AppTypography.bodySm.copyWith(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String countLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.labelSm.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Text(
            countLabel,
            style: AppTypography.labelSm.copyWith(fontSize: 9.5, color: AppColors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationTile(
    BuildContext context, {
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String timeBadge,
    required Color badgeColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PastelCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 19, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          timeBadge,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.outline),
            ],
          ],
        ),
      ),
    );
  }
}
