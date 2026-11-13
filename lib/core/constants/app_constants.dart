/// Konstanta aplikasi SakuKuliah
class AppConstants {
  AppConstants._();

  static const String appName = 'SakuKuliah';
  static const String appTagline = 'Teman Pintar Perjalanan Kuliahmu';
  static const String offlinePledge =
      'Data tersimpan aman di memori perangkat Anda, tanpa server luar.';

  // Default User Initial Info (Fresh Install Bersih)
  static const String defaultUserName = 'Mahasiswa Baru';
  static const String defaultNim = '2310511001';
  static const String defaultMajor = 'Teknik Informatika';
  static const String defaultFaculty = '';
  static const String defaultUniversity = 'Politeknik Sekayu';
  static const int defaultSemester = 1;
  static const String defaultAcademicYear = '2026/2027 (Ganjil)';
  static const String defaultDegreeLevel = 'D3';
  static const double defaultIpk = 0.00;
  static const int defaultSksCompleted = 0;
  static const int defaultSksTotal = 114; // Default D3 (6 semester = ~114 SKS)
  static const int defaultSksTotalD3 = 114; // Default D3
  static const int defaultSksTotalS1 = 144; // Default S1 / D4 (8 semester = ~144 SKS)
  static const double defaultAttendancePercentage = 100.0;

  // Nama-nama hari dalam seminggu
  static const List<String> daysOfWeek = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> daysShort = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];
}

