# 🌸 SakuKuliah - Teman Pintar Perjalanan Kuliahmu (Offline Academic Planner)

Aplikasi mobile perencana akademik offline-first bernuansa **Feminine Pastel** yang dirancang khusus untuk mahasiswa Indonesia dalam mengelola jadwal kuliah, tugas & deadline, simulasi IPK, kalender akademik, catatan perkuliahan, hingga keuangan harian kampus tanpa memerlukan kuota internet.

---

## 📂 Arsitektur & Struktur Folder (Feature-First Clean Architecture)

Proyek ini menggunakan arsitektur **Feature-First (Package-by-Feature)** yang rapi, modular, dan mudah dikembangkan oleh tim developer:

```text
lib/
├── core/                               # Komponen global & pondasi aplikasi
│   ├── constants/                      # Nilai konstanta aplikasi (AppConstants)
│   ├── database/                       # Helper database SQLite lokal
│   ├── state/                          # State management terpusat (SakuKuliahState)
│   ├── storage/                        # SharedPreferences & manajemen offline
│   ├── theme/                          # Design system (AppColors, AppTheme, AppTypography)
│   ├── utils/                          # Helper download berkas (Web & Mobile)
│   └── widgets/                        # Widget umum (PastelCard, PastelButton, StatusBadge, dll.)
│
├── features/                           # Modul fitur-fitur aplikasi (mandiri & terisolasi)
│   ├── academic/                       # Modul Akademik & Presensi
│   │   ├── models/                     # Model data KRS & riwayat semester
│   │   └── presentation/               # Layar akademik & bottom sheets (Presensi, Simulasi IPK, Scan KRS/KHS)
│   ├── calendar/                       # Modul Kalender & Jadwal Ujian
│   │   ├── models/                     # Model event akademik & tanggal ujian (UTS/UAS)
│   │   └── presentation/               # Layar kalender bulanan & form tambah ujian
│   ├── dashboard/                      # Modul Beranda (Home Dashboard)
│   │   └── presentation/               # Metrik ringkas, Quick Action Grid 4x2, Notifikasi Kampus
│   ├── navigation/                     # Navigasi utama tab bawah (MainNavigationScaffold)
│   ├── notes/                          # Modul Catatan Kuliah & Materi
│   │   ├── models/                     # Model catatan materi & ringkasan
│   │   └── presentation/               # Layar catatan, baca lebar (detail), edit, dan hapus
│   ├── onboarding/                     # Modul Splash Screen & Setup Awal
│   │   └── presentation/               # Splash loading animatif & onboarding carousel
│   ├── profile/                        # Modul Profil Mahasiswa & KTM Digital
│   │   ├── models/                     # Model profil mahasiswa
│   │   └── presentation/               # Layar profil, KTM card resmi, backup/restore JSON
│   ├── schedule/                       # Modul Jadwal Kuliah Mingguan
│   │   ├── models/                     # Model jadwal kelas mingguan
│   │   └── presentation/               # Layar jadwal harian & form tambah jadwal
│   ├── tasks/                          # Modul Tugas Kuliah & Deadline
│   │   ├── models/                     # Model tugas kuliah & subtugas
│   │   └── presentation/               # Layar tugas, filter deadline, & Pomodoro Timer
│   ├── vault/                          # Modul Brankas Dokumen Mahasiswa (Student Document Vault)
│   │   ├── models/                     # Model dokumen (KTP, KTM, Transkrip, Sertifikat)
│   │   └── presentation/               # Layar brankas, pencarian, preview, & 1-klik salin nomor
│   └── wallet/                         # Modul Dompet Pastel Mahasiswa (100% Offline)
│       ├── models/                     # Model transaksi harian & tagihan kampus (UKT/Kas)
│       └── presentation/               # Saldo aman, riwayat pengeluaran, & catatan tagihan
│
└── main.dart                           # Entry point aplikasi, rute, dan pengaturan tema
```

---

## ✨ Fitur-Fitur Utama SakuKuliah

1. **🏠 Home Dashboard Cerdas**
   - Header profil terverifikasi, status offline, dan lonceng notifikasi kampus aktif.
   - 3 Metrik utama: SKS Aktif, Tugas Belum Tuntas, dan Ringkasan Presensi.
   - **Quick Actions Grid 4x2:** 8 akses instan (Jadwal, Tugas, Catatan, Presensi, Dompet, Kalender, Simulasi IPK, Timer).
   - Widget ringkasan sisa anggaran harian "Aman Belanja Hari Ini".

2. **📅 Jadwal Kuliah & Ujian (UTS/UAS)**
   - Timeline jadwal mingguan per hari (Senin–Minggu) dengan aksen warna kategori.
   - Kalender akademik interaktif dengan penanda ujian UTS/UAS, deadline tugas, dan hari libur.

3. **✅ Manajemen Tugas & Pomodoro Focus**
   - Filter tugas: Mendesak, Minggu Ini, Selesai.
   - Timer fokus Pomodoro pastel dengan suara dan pengingat istirahat.

4. **🎓 Pelacak Akademik & Presensi**
   - **Pelacak Presensi (75% Rule):** Penghitung otomatis Hadir, Izin, dan Alpa dengan peringatan jatah absen aman agar tidak dicekal UAS.
   - **Simulasi Target IPK:** Kalkulator interaktif proyeksi IPK kumulatif.
   - **Scan KRS & KHS:** Scanner dokumen pintar untuk mencatat mata kuliah otomatis.

5. **📝 Catatan Kuliah & Materi Lengkap**
   - Pencarian materi instan dan filter per mata kuliah.
   - **Modal Baca Lebar (Note Detail):** Membaca catatan panjang dengan nyaman, seleksi teks, salin ke clipboard, edit catatan, dan hapus.

6. **👛 Dompet Pastel Mahasiswa (100% Offline)**
   - Catat pemasukan (kiriman ortu, beasiswa) & pengeluaran (makan, print, kos, kas).
   - Pilihan nominal cepat (+10rb, +20rb, +50rb).
   - Pengingat tagihan kampus (UKT, Kas Kelas) dengan status lunas/belum.
   - Batas anggaran bulanan & kalkulator belanja harian aman.

7. **💳 KTM Digital & Cadangan Data Offline**
   - Kartu Tanda Mahasiswa (KTM) digital elegan dengan logo resmi aplikasi.
   - **Cadangan Data Mandiri:** Ekspor seluruh data ke file `.json` dan impor kembali kapan saja tanpa server/cloud.

8. **🗄️ Brankas Dokumen Mahasiswa (Student Document Vault)**
   - Simpan berkas penting perkuliahan: KTP, KTM, Transkrip Nilai Sementara, Bukti Bayar UKT, dan Sertifikat TOEFL/Prestasi (PDF/Gambar).
   - **1-Klik Salin Nomor:** Salin NIK, NIM, atau nomor dokumen instan untuk pendaftaran beasiswa dan magang.
   - **Privasi 100% Offline:** Berkas tersimpan di penyimpanan lokal HP pengguna tanpa lalu lintas ke server publik.

---

## 🛠️ Panduan Pengembangan (Untuk Developer)

### Menambahkan Fitur Baru:
Untuk menjaga struktur tetap rapi, buat folder baru di dalam `lib/features/<nama_fitur>/` dengan format standar:
1. `models/` $\rightarrow$ Simpan model data `*model.dart` dengan method `toMap()`, `fromMap()`, dan `copyWith()`.
2. `presentation/` $\rightarrow$ Simpan halaman utama `<nama_fitur>_screen.dart`.
3. `presentation/widgets/` $\rightarrow$ Simpan dialog, bottom sheet, atau widget khusus fitur tersebut.
4. Hubungkan state ke `lib/core/state/app_state.dart` agar reaktif dan tersimpan otomatis ke `SharedPreferences`.

### Menjalankan Aplikasi:
```bash
# Unduh paket dependensi
flutter pub get

# Jalankan di Chrome (Web)
flutter run -d chrome

# Jalankan di Perangkat Android / Emulator
flutter run -d android

# Build APK super ringan (Split per arsitektur CPU)
flutter build apk --split-per-abi
```

---

## 🎨 Palet Warna & Desain
- **Primary Rose:** `#805063` & `#F4B8CD`
- **Surface Warm:** `#FFF8FA` & `#FEF7FF`
- **Background Container:** `#FCE4EC` & `#EFE8F0`
- **Typography:** *Epilogue* (Judul & Angka Metrik) dan *Inter* (Isi Teks & Label)


