import 'package:flutter/material.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../../../core/widgets/pastel_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../models/semester_record_model.dart';
import 'scan_krs_khs_sheet.dart';

/// Modal Lembar Riwayat KHS & Transkrip Semester Mahasiswa (Mendukung D3 & S1)
class SemesterHistorySheet extends StatefulWidget {
  const SemesterHistorySheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SemesterHistorySheet(),
    );
  }

  @override
  State<SemesterHistorySheet> createState() => _SemesterHistorySheetState();
}

class _SemesterHistorySheetState extends State<SemesterHistorySheet> {
  final SakuKuliahState _appState = SakuKuliahState.instance;

  void _showEditSemesterDialog(SemesterRecordModel record) {
    final sksController = TextEditingController(text: record.sks.toString());
    final ipsController = TextEditingController(text: record.ips.toStringAsFixed(2));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          scrollable: true,
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Edit Nilai Semester ${record.semesterNumber}',
                style: AppTypography.headlineSm.copyWith(fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perbarui jumlah SKS dan IPS untuk semester ini:',
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text('Jumlah SKS', style: AppTypography.labelMd),
                const SizedBox(height: 6),
                TextField(
                  controller: sksController,
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Misal: 22',
                    prefixIcon: Icon(Icons.class_outlined, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                Text('IPS (Indeks Prestasi Semester)', style: AppTypography.labelMd),
                const SizedBox(height: 6),
                TextField(
                  controller: ipsController,
                  textInputAction: TextInputAction.done,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Misal: 3.85',
                    prefixIcon: Icon(Icons.trending_up, size: 18),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                final sks = int.tryParse(sksController.text.trim()) ?? record.sks;
                final ips = double.tryParse(ipsController.text.trim()) ?? record.ips;
                _appState.updateSemesterRecord(record.semesterNumber, sks, ips);
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showQuickInputStatsDialog() {
    final profile = _appState.studentProfile;
    final ipkController = TextEditingController(text: profile.cumulativeIpk.toStringAsFixed(2));
    final sksController = TextEditingController(text: profile.completedSks.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          scrollable: true,
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bolt_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Isi Cepat IPK & SKS Lalu',
                style: AppTypography.headlineSm.copyWith(fontSize: 16),
              ),
            ],
          ),
          content: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cocok jika kamu tidak ingin mengisi semester 1-4 satu per satu. Cukup masukkan total dari KHS/Transkrip terakhir:',
                  style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                Text('IPK Sampai Semester Lalu', style: AppTypography.labelMd),
                const SizedBox(height: 6),
                TextField(
                  controller: ipkController,
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Misal: 3.82',
                    prefixIcon: Icon(Icons.star_outline_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Total SKS yang Sudah Lulus', style: AppTypography.labelMd),
                const SizedBox(height: 6),
                TextField(
                  controller: sksController,
                  textInputAction: TextInputAction.done,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    hintText: 'Misal: 88',
                    prefixIcon: Icon(Icons.check_circle_outline, size: 18),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                final ipk = double.tryParse(ipkController.text.trim()) ?? profile.cumulativeIpk;
                final sks = int.tryParse(sksController.text.trim()) ?? profile.completedSks;
                _appState.updateQuickPreviousStats(ipk: ipk, sks: sks);
                Navigator.pop(ctx);
                setState(() {});
              },
              child: const Text('Terapkan Langsung 🌸'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final profile = _appState.studentProfile;
        final history = _appState.semesterHistory;
        final currentSemester = profile.currentSemester;
        final isD3 = profile.degreeLevel == 'D3';
        final totalSemesters = isD3 ? 6 : 8;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Grab Handle
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryContainer.withValues(alpha: 0.6),
                            ),
                            child: Icon(
                              Icons.history_edu_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Riwayat KHS & Transkrip 📜✨',
                                style: AppTypography.headlineSm.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Nilai semester lalu & kalkulasi kelulusan',
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
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pilihan Jenjang Kuliah (D3 vs S1)
                  Text(
                    'Jenjang Program Kuliah',
                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _appState.updateDegreeLevel('D3');
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: isD3
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isD3 ? AppColors.primary : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '🎓 Program D3',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isD3 ? FontWeight.bold : FontWeight.w500,
                                        color: isD3 ? AppColors.primary : AppColors.onSurface,
                                      ),
                                    ),
                                    if (isD3) ...[
                                      const SizedBox(width: 4),
                                      Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '6 Semester • ~114 SKS',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: isD3 ? AppColors.primary : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _appState.updateDegreeLevel('S1');
                            setState(() {});
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: BoxDecoration(
                              color: !isD3
                                  ? AppColors.primaryContainer
                                  : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: !isD3 ? AppColors.primary : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '🎓 Program S1 / D4',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: !isD3 ? FontWeight.bold : FontWeight.w500,
                                        color: !isD3 ? AppColors.primary : AppColors.onSurface,
                                      ),
                                    ),
                                    if (!isD3) ...[
                                      const SizedBox(width: 4),
                                      Icon(Icons.check_circle, size: 14, color: AppColors.primary),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '8 Semester • ~144 SKS',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: !isD3 ? AppColors.primary : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Hero Ringkasan Transkrip Kumulatif
                  Container(
                    padding: const EdgeInsets.all(16),
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
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IPK Kumulatif (Semester 1–${currentSemester - 1})',
                                  style: AppTypography.labelSm.copyWith(
                                    color: AppColors.onSecondaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${profile.cumulativeIpk.toStringAsFixed(2)} / 4.00',
                                  style: AppTypography.headlineLgMobile.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                    fontSize: 26,
                                  ),
                                ),
                              ],
                            ),
                            StatusBadge.cumlaude(label: 'Cum Laude ✨'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: (profile.degreeProgressPercentage / 100).clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.5),
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'SKS Lulus: ${profile.completedSks} dari ${profile.totalSks} SKS (${profile.degreeProgressPercentage.toStringAsFixed(1)}%)',
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                            ),
                            Text(
                              isD3
                                  ? (currentSemester == 5
                                      ? 'Tinggal 1 semester lagi lulus! 🎓'
                                      : 'Menuju Tugas Akhir D3')
                                  : 'Semester $currentSemester dari 8',
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Tombol Cepat: Input Langsung IPK Lalu
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary, width: 1.2),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: _showQuickInputStatsDialog,
                    icon: const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text(
                      'Mode Cepat: Masukkan Langsung Total IPK & SKS Lalu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Daftar Semester (Semester 1 s.d. Total Semester)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rincian Nilai Tiap Semester',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap ✏️ untuk edit',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Kartu-kartu semester
                  ...List.generate(totalSemesters, (index) {
                    final semNum = index + 1;
                    final isPast = semNum < currentSemester;
                    final isCurrent = semNum == currentSemester;

                    final recordMatch = history.where((r) => r.semesterNumber == semNum);
                    final record = recordMatch.isNotEmpty
                        ? recordMatch.first
                        : SemesterRecordModel(
                            semesterNumber: semNum,
                            academicYear: 'Semester $semNum',
                            sks: isPast ? 22 : 20,
                            ips: isPast ? 3.80 : 0.0,
                            isCompleted: isPast,
                          );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PastelCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCurrent
                                    ? AppColors.primaryContainer
                                    : (isPast
                                        ? const Color(0xFFE8F5E9)
                                        : AppColors.surfaceContainerHigh),
                              ),
                              child: Center(
                                child: Text(
                                  '$semNum',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: isCurrent
                                        ? AppColors.primary
                                        : (isPast
                                            ? const Color(0xFF2E7D32)
                                            : AppColors.onSurfaceVariant),
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
                                    children: [
                                      Text(
                                        'Semester $semNum',
                                        style: AppTypography.labelLg.copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      if (isCurrent)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.secondaryContainer,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            'Semester Ini 🟡',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.onSecondaryContainer,
                                            ),
                                          ),
                                        )
                                      else if (isPast)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F5E9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Tuntas 🟢',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2E7D32),
                                            ),
                                          ),
                                        )
                                      else
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceContainerHigh,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            isD3 && semNum == 6
                                                ? 'Tugas Akhir / Magang'
                                                : 'Mendatang ⚪',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              color: AppColors.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isPast
                                        ? '${record.sks} SKS • IPS: ${record.ips.toStringAsFixed(2)}'
                                        : (isCurrent
                                            ? '${_appState.krsCourses.fold<int>(0, (s, c) => s + c.sks)} SKS • Estimasi IPS: ${_appState.calculatePredictedIps().toStringAsFixed(2)}'
                                            : 'Rencana ~20 SKS'),
                                    style: AppTypography.bodySm.copyWith(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isPast)
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                color: AppColors.primary,
                                tooltip: 'Edit Nilai',
                                onPressed: () => _showEditSemesterDialog(record),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Scan / Import Button
                  PastelButton(
                    text: 'Scan Transkrip KHS dari SIAKAD 📄',
                    type: PastelButtonType.secondary,
                    width: double.infinity,
                    height: 46,
                    leadingIcon: const Icon(Icons.document_scanner_rounded, size: 18),
                    onPressed: () {
                      Navigator.pop(context);
                      ScanKrsKhsSheet.show(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
