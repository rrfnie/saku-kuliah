import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/file_download_helper.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/fade_slide_entry.dart';
import '../../../core/widgets/pastel_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/student_profile_model.dart';
import '../../academic/presentation/widgets/attendance_tracker_sheet.dart';
import '../../academic/presentation/widgets/ipk_simulator_sheet.dart';
import '../../academic/presentation/widgets/scan_krs_khs_sheet.dart';
import '../../calendar/presentation/academic_calendar_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../tasks/presentation/widgets/pomodoro_timer_sheet.dart';
import '../../wallet/presentation/wallet_screen.dart';
import 'widgets/edit_profile_sheet.dart';
import 'widgets/student_id_card_widget.dart';
import 'widgets/theme_selector_card.dart';
import 'user_guide_screen.dart';
import '../../vault/presentation/student_vault_screen.dart';

/// Halaman Profil Mahasiswa dan Pengaturan Fitur Offline dengan State Reaktif
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;
  bool _classReminderEnabled = true;
  bool _taskReminderEnabled = true;

  void _openEditProfile(StudentProfileModel profile) {
    EditProfileSheet.show(
      context,
      currentProfile: profile,
      onSave: (updated) {
        _appState.updateStudentProfile(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil & Foto berhasil diperbarui! 🌸✨')),
        );
      },
    );
  }

  Future<void> _handleBackupData() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.file_download_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Cadangkan Data (JSON)',
                style: AppTypography.headlineSm.copyWith(fontSize: 16),
              ),
            ],
          ),
          content: Text(
            'Seluruh jadwal kuliah, daftar tugas, nilai semester (KRS/KHS), catatan, dan profil mahasiswa akan diekspor menjadi berkas file JSON cadangan dan otomatis diunduh ke perangkat kamu 🌸',
            style: AppTypography.bodyMd,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              icon: const Icon(Icons.download_rounded, size: 18),
              label: const Text('Unduh JSON'),
              onPressed: () async {
                Navigator.pop(ctx);
                try {
                  final json = _appState.exportBackupJson();
                  final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
                  final fileName = 'sakukuliah_backup_$dateStr.json';

                  // Unduh file langsung ke storage / browser
                  await FileDownloadHelper.download(json, fileName);
                  // Juga salin ke clipboard untuk kemudahan pengguna
                  await Clipboard.setData(ClipboardData(text: json));

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.primary,
                        content: Text('File $fileName berhasil diunduh & teks disalin ke clipboard! 🌸✨'),
                        duration: const Duration(seconds: 4),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal mengunduh file: $e'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleRestoreData() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomContext) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.settings_backup_restore_rounded, color: AppColors.onSecondaryContainer, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Pulihkan Data Cadangan (Restore)',
                    style: AppTypography.headlineSm.copyWith(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Pilih berkas JSON hasil backup dari penyimpanan HP/Laptop, atau tempel teks JSON langsung:',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              // Pilihan 1: Pilih File JSON
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.cardBorder),
                ),
                tileColor: AppColors.surfaceContainerLow,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.upload_file_rounded, color: AppColors.onPrimaryContainer),
                ),
                title: Text(
                  'Pilih File JSON (.json)',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Buka berkas sakukuliah_backup_*.json dari perangkat',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                onTap: () async {
                  Navigator.pop(bottomContext);
                  try {
                    final files = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['json', 'txt'],
                    );
                    if (files.isNotEmpty) {
                      final picked = files.first;
                      String jsonContent = '';
                      try {
                        jsonContent = await picked.xFile.readAsString();
                      } catch (_) {
                        final bytes = await picked.xFile.readAsBytes();
                        jsonContent = utf8.decode(bytes);
                      }
                      if (jsonContent.trim().isNotEmpty) {
                        final success = _appState.restoreBackupJson(jsonContent);
                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.primary,
                                content: const Text('Data backup berhasil dipulihkan seluruhnya! 🌸✨'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Format berkas JSON tidak sesuai atau rusak.'),
                              ),
                            );
                          }
                        }
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Terjadi kesalahan saat membaca file: $e')),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 12),
              // Pilihan 2: Tempel Teks JSON
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.cardBorder),
                ),
                tileColor: AppColors.surfaceContainerLow,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.paste_rounded, color: AppColors.onSecondaryContainer),
                ),
                title: Text(
                  'Tempel Teks JSON (Paste)',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tempel teks JSON dari clipboard jika menyalin sebelumnya',
                  style: AppTypography.bodySm.copyWith(fontSize: 11),
                ),
                trailing: Icon(Icons.chevron_right_rounded, color: AppColors.primary),
                onTap: () {
                  Navigator.pop(bottomContext);
                  _showPasteJsonDialog();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showPasteJsonDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (pasteDialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Tempel Teks JSON', style: AppTypography.headlineSm.copyWith(fontSize: 16)),
          content: TextField(
            controller: controller,
            maxLines: 8,
            decoration: InputDecoration(
              hintText: 'Paste kode JSON di sini...',
              hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(pasteDialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                final text = controller.text.trim();
                Navigator.pop(pasteDialogContext);
                if (text.isNotEmpty) {
                  final success = _appState.restoreBackupJson(text);
                  if (mounted) {
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: AppColors.primary,
                          content: const Text('Data backup berhasil dipulihkan seluruhnya! 🌸✨'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Format teks JSON tidak valid.'),
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Pulihkan'),
            ),
          ],
        );
      },
    );
  }

  void _handleClearAllData() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.delete_sweep_rounded, color: Colors.red.shade700, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Kosongkan Data?'),
          ],
        ),
        content: const Text(
          'Seluruh jadwal kelas, tugas, catatan, riwayat nilai IPK, dan transaksi akan dikosongkan kembali seperti aplikasi baru pertama kali di-install.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              await _appState.clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Color(0xFFC62828),
                    content: Text('Seluruh data berhasil dikosongkan. Mulai bersih! 🌸✨'),
                  ),
                );
              }
            },
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final profile = _appState.studentProfile;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Profil & Pengaturan Offline'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Identity Header Card
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 60),
                    child: _buildProfileCard(profile),
                  ),

                  const SizedBox(height: 16),

                  // Quick Stats (IPK, Predikat, SKS)
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 120),
                    child: Builder(
                      builder: (context) {
                        final ipk = profile.cumulativeIpk;
                        final String predicateText;
                        final String predicateLabel;
                        if (ipk >= 3.51) {
                          predicateText = 'Cumlaude';
                          predicateLabel = 'Kandidat';
                        } else if (ipk >= 3.00) {
                          predicateText = 'Sgt Memuaskan';
                          predicateLabel = 'Predikat';
                        } else if (ipk >= 2.75) {
                          predicateText = 'Memuaskan';
                          predicateLabel = 'Predikat';
                        } else if (ipk > 0) {
                          predicateText = 'Cukup';
                          predicateLabel = 'Predikat';
                        } else {
                          predicateText = '-';
                          predicateLabel = 'Belum Ada';
                        }

                        return Row(
                          children: [
                            _buildStatBadge('⭐', profile.cumulativeIpk.toStringAsFixed(2), 'IPK Kumulatif'),
                            const SizedBox(width: 8),
                            _buildStatBadge('🎓', predicateText, predicateLabel),
                            const SizedBox(width: 8),
                            _buildStatBadge('📚', '${profile.completedSks}', 'SKS Selesai'),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Kartu Tanda Mahasiswa (KTM Digital) Pastel
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 180),
                    child: StudentIdCardWidget(
                      profile: profile,
                      onEditProfile: () => _openEditProfile(profile),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Tema & Mode Gelap / Terang (Baru ✨)
                  const FadeSlideEntry(
                    delay: Duration(milliseconds: 210),
                    child: ThemeSelectorCard(),
                  ),

                  const SizedBox(height: 22),

                  // Fitur Pintar Mahasiswa
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Fitur Pintar Mahasiswa',
                        style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  PastelCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Brankas Dokumen Mahasiswa (Vault)
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const StudentVaultScreen()),
                            );
                          },
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.folder_special_rounded, color: AppColors.primary),
                          ),
                          title: Text(
                            'Brankas Dokumen Mahasiswa (Vault) 🗄️',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Simpan scan KTP, KTM, Transkrip & Sertifikat (100% Offline & Salin NIK/NIM).',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Pelacak Presensi & Batas Bolos
                        ListTile(
                          onTap: () => AttendanceTrackerSheet.show(context),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.fact_check_rounded, color: AppColors.onSecondaryContainer),
                          ),
                          title: Text(
                            'Pelacak Presensi & Batas Bolos (75%)',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Kalkulator sisa jatah absen aman agar tidak terancam gagal ikut UAS.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Mode Ambis Belajar (Pomodoro)
                        ListTile(
                          onTap: () => PomodoroTimerSheet.show(context),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.hourglass_top_rounded, color: AppColors.onTertiaryContainer),
                          ),
                          title: Text(
                            'Mode Ambis Belajar (Pomodoro Pastel)',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Timer fokus 25 menit belajar + 5 menit rehat untuk nugas & belajar.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Simulasi IPK
                        ListTile(
                          onTap: () => IpkSimulatorSheet.show(context),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.calculate_rounded, color: AppColors.onPrimaryContainer),
                          ),
                          title: Text(
                            'Simulasi Target & Prediksi IPK',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Hitung proyeksi IPK kumulatif jika dapat nilai tertentu di semester ini.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Kalender Akademik
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AcademicCalendarScreen()),
                            );
                          },
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.calendar_month_rounded, color: AppColors.onSecondaryContainer),
                          ),
                          title: Text(
                            'Kalender Akademik & Hari Libur',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Jadwal UTS, UAS, KRS, dan agenda kegiatan semester 2026/2027.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Catatan Kuliah
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const NotesScreen()),
                            );
                          },
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.auto_stories_rounded, color: AppColors.onTertiaryContainer),
                          ),
                          title: Text(
                            'Catatan & Rangkuman Materi Kuliah',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Kumpulan ringkasan materi, catatan dosen, dan materi offline.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Dompet Pastel Mahasiswa
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WalletScreen()),
                            );
                          },
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.onPrimaryContainer),
                          ),
                          title: Text(
                            'Dompet Pastel & Uang Saku Mahasiswa 👛',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Atur jatah jajan harian aman, tagihan UKT, kas kelas & uang saku.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Section 1: Offline Data & Backup Management
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.folder_special_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'Penyimpanan & Cadangan Data',
                            style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          'Offline First',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSecondaryContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  PastelCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Scan KRS / KHS Row
                        ListTile(
                          onTap: () => ScanKrsKhsSheet.show(context),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.document_scanner_rounded, color: AppColors.onPrimaryContainer),
                          ),
                          title: Text(
                            'Scan & Impor KRS / KHS',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Ekstraksi jadwal kuliah & nilai langsung dari foto atau PDF SIAKAD.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Backup Row
                        ListTile(
                          onTap: _handleBackupData,
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.file_download_rounded, color: AppColors.onPrimaryContainer),
                          ),
                          title: Text(
                            'Cadangkan Data (Backup JSON)',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Ekspor seluruh jadwal, tugas & nilai ke penyimpanan HP tanpa kuota internet.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Restore Row
                        ListTile(
                          onTap: _handleRestoreData,
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.file_upload_rounded, color: AppColors.onSecondaryContainer),
                          ),
                          title: Text(
                            'Pulihkan Data (Restore)',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Muat file JSON cadangan untuk memulihkan jadwal semester sebelumnya.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Reset / Kosongkan Data
                        ListTile(
                          onTap: _handleClearAllData,
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.delete_sweep_rounded, color: Colors.red.shade700),
                          ),
                          title: Text(
                            'Kosongkan Seluruh Data',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                          subtitle: Text(
                            'Hapus semua data kembali ke kondisi bersih seperti baru di-install.',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: Colors.red.shade300),
                        ),
                        Divider(height: 1, color: AppColors.dividerColor),
                        // Storage Usage Info
                        Container(
                          padding: const EdgeInsets.all(14),
                          color: AppColors.surfaceContainerLow.withValues(alpha: 0.5),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.storage_rounded, size: 18, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Status Penyimpanan Lokal',
                                          style: AppTypography.labelSm.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '3.4 MB',
                                          style: AppTypography.labelSm.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(9999),
                                      child: LinearProgressIndicator(
                                        value: 0.14,
                                        minHeight: 4,
                                        backgroundColor: AppColors.surfaceContainer,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '100% tersimpan aman di internal storage HP kamu',
                                      style: AppTypography.labelSm.copyWith(
                                        fontSize: 9.5,
                                        color: AppColors.onSurfaceVariant,
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
                  ),
                  const SizedBox(height: 20),

                  // Section 2: App Preferences
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Preferensi Aplikasi',
                        style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  PastelCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        // Toggle Class Reminder
                        SwitchListTile(
                          value: _classReminderEnabled,
                          activeColor: AppColors.primary,
                          title: Text(
                            'Pengingat Kuliah (Lokal)',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '15 menit sebelum kelas dimulai',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          secondary: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.notifications_active_rounded, size: 18, color: AppColors.onSecondaryContainer),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _classReminderEnabled = val;
                            });
                          },
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        // Toggle Task Reminder
                        SwitchListTile(
                          value: _taskReminderEnabled,
                          activeColor: AppColors.primary,
                          title: Text(
                            'Pengingat Deadline Tugas',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Pemberitahuan otomatis (H-1)',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          secondary: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.tertiaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.alarm_rounded, size: 18, color: AppColors.onTertiaryContainer),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _taskReminderEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // Section 3: Tentang & Panduan
                  Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Tentang SakuKuliah',
                        style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  PastelCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const UserGuideScreen(),
                              ),
                            );
                          },
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.auto_stories_rounded, size: 18, color: AppColors.onPrimaryContainer),
                          ),
                          title: Text(
                            'Panduan Fitur & Pengenalan',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Pelajari cara maksimalin fitur jadwal, tugas, dan IPK',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                          trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.onSurfaceVariant),
                        ),
                        Divider(height: 1, indent: 64, color: AppColors.dividerColor),
                        ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.verified_user_rounded, size: 18, color: AppColors.onSecondaryContainer),
                          ),
                          title: Text(
                            'Versi Aplikasi & Privasi',
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'v1.0.0 • 100% Offline • Bebas Pelacak & Iklan',
                            style: AppTypography.bodySm.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileCard(StudentProfileModel profile) {
    return PastelCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppAvatar(
            avatarBase64: profile.avatarBase64,
            avatarPreset: profile.avatarPreset,
            name: profile.name,
            size: 62,
            borderWidth: 2.5,
            showEditBadge: true,
            onTap: () => _openEditProfile(profile),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        profile.name.trim().isEmpty ? 'Nama Belum Diatur' : profile.name,
                        style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    StatusBadge(
                      label: profile.name.trim().isEmpty ? 'Belum Diisi' : 'Aktif',
                      backgroundColor: profile.name.trim().isEmpty ? AppColors.surfaceContainerHigh : AppColors.secondaryContainer,
                      textColor: profile.name.trim().isEmpty ? AppColors.onSurfaceVariant : AppColors.onSecondaryContainer,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      fontSize: 9.5,
                    ),
                  ],
                ),
                Text(
                  profile.nim.trim().isEmpty && profile.major.trim().isEmpty
                      ? 'Ketuk ikon pensil untuk atur NIM & prodi'
                      : '${profile.nim.isEmpty ? '-' : profile.nim} • ${profile.major.isEmpty ? '-' : profile.major}',
                  style: AppTypography.bodySm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
                if (profile.university.trim().isNotEmpty)
                  Text(
                    profile.university,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Edit Profil',
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            onPressed: () => _openEditProfile(profile),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String emoji, String value, String label) {
    return Expanded(
      child: PastelCard(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 2),
            Text(
              value,
              style: AppTypography.headlineSm.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontSize: 9,
                color: AppColors.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
