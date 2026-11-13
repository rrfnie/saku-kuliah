import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_card.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Panduan Fitur & Pengenalan',
          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          physics: const BouncingScrollPhysics(),
          children: [
            // Hero Welcome Card
            PastelCard(
              backgroundColor: AppColors.primaryContainer,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🌸', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo Mahasiswa Hebat! ✨',
                          style: AppTypography.headlineSm.copyWith(
                            color: AppColors.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SakuKuliah dirancang khusus untuk mempermudah hidup perkuliahanmu jadi lebih santai, teratur, dan produktif tanpa ribet.',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onPrimaryContainer.withValues(alpha: 0.85),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section Header
            Row(
              children: [
                const Icon(Icons.stars_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Panduan Penggunaan Fitur',
                  style: AppTypography.labelLg.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Guide 1: Jadwal Kuliah & Ruangan
            _buildGuideCard(
              emoji: '📅',
              title: '1. Jadwal Kuliah & Ruangan',
              subtitle: 'Kelola jadwal kuliah mingguan dengan mudah',
              steps: [
                'Buka tab "Jadwal" di navigasi bawah untuk melihat jadwal kuliah harian.',
                'Ketuk tombol "+ Tambah Jadwal" untuk memasukkan matkul, jam mulai-selesai, ruangan, dosen pengampu, dan kategori (Teori / Praktikum).',
                'Pilih hari (Senin - Sabtu) atau gunakan filter tab di bagian atas untuk melihat jadwal hari tertentu.',
                'Kamu juga bisa menambahkan jadwal ujian (UTS/UAS) langsung dari tombol shortcut di beranda.',
              ],
              accentColor: AppColors.primary,
              tagLabel: 'Inti Kuliah',
              tagColor: AppColors.primaryContainer,
              tagTextColor: AppColors.onPrimaryContainer,
            ),
            const SizedBox(height: 14),

            // Guide 2: Scan KRS & KHS
            _buildGuideCard(
              emoji: '📄',
              title: '2. Scan & Impor KRS / KHS',
              subtitle: 'Impor puluhan matkul tanpa ketik manual satu per satu',
              steps: [
                'Masuk ke tab "Akademik", lalu ketuk tombol "Scan Dokumen KRS / KHS".',
                'Pilih berkas PDF KRS kampus dari perangkatmu. Sistem akan otomatis mengekstrak tabel matkul, kode, dan SKS.',
                'Gunakan fitur andalan "Tempel Teks SIAKAD": Buka website portal/SIAKAD kampusmu, blok & copy tabel matkul, lalu paste di aplikasi ini. Seketika semua matkul akan terisi rapi!',
                'Periksa hasil ekstraksi, centang matkul yang ingin dimasukkan, lalu klik "Simpan ke Jadwal & Matkul".',
              ],
              accentColor: AppColors.secondary,
              tagLabel: 'Super Praktis',
              tagColor: AppColors.secondaryContainer,
              tagTextColor: AppColors.onSecondaryContainer,
            ),
            const SizedBox(height: 14),

            // Guide 3: Target & Kalkulator IPK
            _buildGuideCard(
              emoji: '🎯',
              title: '3. Target & Kalkulator IPK',
              subtitle: 'Simulasi dan pantau perkembangan nilai akademikmu',
              steps: [
                'Di tab "Akademik", kamu bisa melihat ringkasan IPK saat ini, total SKS yang telah ditempuh, dan predikat kelulusan.',
                'Gunakan tombol "Target & Kalkulator IPK" untuk menentukan target IPK impianmu (misal: 3.85 Cumlaude).',
                'Kalkulator akan menghitung nilai minimal yang harus kamu raih di tiap mata kuliah semester ini agar targetmu tercapai.',
                'Lihat grafik perkembangan nilai dari semester ke semester untuk memotivasi belajarmu!',
              ],
              accentColor: AppColors.tertiary,
              tagLabel: 'Akademik',
              tagColor: AppColors.tertiaryContainer,
              tagTextColor: AppColors.onTertiaryContainer,
            ),
            const SizedBox(height: 14),

            // Guide 4: Presensi & Batas Aman Absen
            _buildGuideCard(
              emoji: '🛡️',
              title: '4. Presensi & Batas Aman Absen',
              subtitle: 'Jaga kehadiran minimal 75% agar aman ikut ujian akhir',
              steps: [
                'Setiap matkul memiliki pelacak absensi otomatis berbasis aturan kehadiran standar kampus (minimal 75%).',
                'Cukup ketuk tombol "+" pada Hadir, Izin, atau Alpa setelah selesai mengikuti sesi perkuliahan.',
                'Kartu absensi akan menampilkan status pintar: "Aman (Bisa izin X kali lagi)" atau peringatan jika kuota izinmu sudah menipis.',
                'Dengan pantauan ini, kamu nggak perlu khawatir kena pencekalan (tidak boleh ikut UTS/UAS) akibat kebanyakan alpa.',
              ],
              accentColor: const Color(0xFF2E7D32),
              tagLabel: 'Pencegah Masalah',
              tagColor: const Color(0xFFE8F5E9),
              tagTextColor: const Color(0xFF1B5E20),
            ),
            const SizedBox(height: 14),

            // Guide 5: Manajemen Tugas & Deadline
            _buildGuideCard(
              emoji: '⏰',
              title: '5. Tugas & Deadline Kuliah',
              subtitle: 'Ucapkan selamat tinggal pada tugas dadakan yang terlewat',
              steps: [
                'Buka tab "Tugas" untuk melihat daftar tugas yang diurutkan berdasarkan batas waktu terdekat.',
                'Tentukan kategori tugas (Tugas Individu, Kelompok, Laporan Praktikum, Kuis, Makalah, atau Skripsi).',
                'Tandai tingkat prioritas (Tinggi, Sedang, Rendah) agar kamu tahu tugas mana yang harus diselesaikan terlebih dahulu.',
                'Setelah tugas selesai dikerjakan, cukup centang kotak selesai untuk memindahkannya ke riwayat tuntas.',
              ],
              accentColor: const Color(0xFFE65100),
              tagLabel: 'Anti-Ketinggalan',
              tagColor: const Color(0xFFFFF3E0),
              tagTextColor: const Color(0xFFBF360C),
            ),
            const SizedBox(height: 14),

            // Guide 6: Dompet Mahasiswa & Uang Saku
            _buildGuideCard(
              emoji: '👛',
              title: '6. Dompet Mahasiswa & Uang Saku',
              subtitle: 'Kelola keuangan harian dan jangan lupa bayar tagihan kampus',
              steps: [
                'Buka tab "Dompet" atau klik tombol "Dompet Pastel" di beranda.',
                'Catat pemasukan bulanan (uang saku ortu, beasiswa, atau hasil freelance) dan pengeluaran harian (makan, transportasi, print tugas).',
                'Gunakan fitur "Tagihan Kampus" untuk mencatat tenggat waktu pembayaran UKT, uang kas kelas, praktikum, atau wisuda.',
                'Pantau sisa saldo dompet agar pengeluaran akhir bulan tetap aman dan terkendali.',
              ],
              accentColor: const Color(0xFF880E4F),
              tagLabel: 'Finansial Mahasiswa',
              tagColor: const Color(0xFFFCE4EC),
              tagTextColor: const Color(0xFF880E4F),
            ),
            const SizedBox(height: 14),

            // Guide 7: Catatan Kuliah & Skripsi
            _buildGuideCard(
              emoji: '📝',
              title: '7. Catatan Kuliah & Skripsi',
              subtitle: 'Simpan rangkuman materi dan progres bimbingan tugas akhir',
              steps: [
                'Gunakan menu "Catatan Kuliah" untuk menulis rangkuman poin penting materi dosen saat kelas berlangsung.',
                'Bagi pejuang semester akhir, manfaatkan bagian "Skripsi & Proyek Akhir" untuk mencatat ide judul, rumusan masalah, revisi dosen pembimbing, dan tanggal sidang.',
                'Semua catatan tersimpan rapi dan dapat dicari kapan saja lewat kolom pencarian.',
              ],
              accentColor: AppColors.primary,
              tagLabel: 'Rangkuman & Riset',
              tagColor: AppColors.primaryContainer,
              tagTextColor: AppColors.onPrimaryContainer,
            ),
            const SizedBox(height: 14),

            // Guide 8: Brankas Dokumen Mahasiswa (Vault)
            _buildGuideCard(
              emoji: '🗄️',
              title: '8. Brankas Dokumen Mahasiswa (Vault)',
              subtitle: 'Simpan aman KTP, KTM, Transkrip & Sertifikat (100% Offline)',
              steps: [
                'Buka "Brankas Dokumen" lewat tombol shortcut di Beranda atau menu Profil.',
                'Unggah berkas pentingmu (PDF, JPG, PNG) seperti scan KTP, KTM, Transkrip Nilai Sementara, Bukti Bayar UKT, dan Sertifikat TOEFL.',
                'Isi nomor identitas (NIK KTP, NIM, dsb.) untuk menggunakan fitur "1-Klik Salin", memudahkan pengisian form online beasiswa atau magang.',
                'Seluruh berkas disimpan privat di memori lokal HP-mu tanpa pernah diunggah ke internet.',
              ],
              accentColor: AppColors.secondary,
              tagLabel: 'Sangat Penting',
              tagColor: AppColors.secondaryContainer,
              tagTextColor: AppColors.onSecondaryContainer,
            ),
            const SizedBox(height: 14),

            // Guide 9: Cadangkan & Pulihkan Data (100% Offline)
            _buildGuideCard(
              emoji: '🔒',
              title: '9. Keamanan & Cadangkan Data',
              subtitle: '100% Offline, tanpa iklan, dan bebas simpan kapan saja',
              steps: [
                'Seluruh datamu tersimpan langsung di dalam memori perangkatmu sendiri, sehingga aplikasi tetap berjalan lancar tanpa kuota internet.',
                'Masuk ke tab "Profil" lalu pilih "Cadangkan Data (Backup)" untuk mengunduh berkas cadangan JSON.',
                'Simpan berkas cadangan tersebut di Google Drive atau kirim ke WhatsApp agar datamu bisa dipulihkan kembali saat ganti perangkat dengan fitur "Pulihkan Data (Restore)".',
                'Jika ingin memulai dari awal, kamu bisa memilih "Kosongkan Seluruh Data" di menu Profil.',
              ],
              accentColor: const Color(0xFF1565C0),
              tagLabel: '100% Privasi Aman',
              tagColor: const Color(0xFFE3F2FD),
              tagTextColor: const Color(0xFF0D47A1),
            ),
            const SizedBox(height: 24),

            // Closing Cheerful Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x33F4DCE4)),
              ),
              child: Column(
                children: [
                  const Text('🎀', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    'Selamat Menempuh Perkuliahan! 🎓✨',
                    style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nikmati setiap proses belajarmu bersama SakuKuliah. Tetap semangat, jaga kesehatan, dan raih prestasi terbaikmu ya!',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard({
    required String emoji,
    required String title,
    required String subtitle,
    required List<String> steps,
    required Color accentColor,
    required String tagLabel,
    required Color tagColor,
    required Color tagTextColor,
  }) {
    return PastelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.labelLg.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tagLabel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: tagTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0x18F4DCE4)),
          const SizedBox(height: 12),
          Column(
            children: List.generate(steps.length, (idx) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${idx + 1}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        steps[idx],
                        style: AppTypography.bodySm.copyWith(
                          color: AppColors.onSurface,
                          height: 1.35,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
