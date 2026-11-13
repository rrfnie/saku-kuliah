/// 🗓️ Data Hari Libur Nasional Indonesia (Hard-coded, 100% Offline)
/// Mencakup tahun 2026 s/d 2028 — otomatis tampil di kalender sebagai tanggal merah
class NationalHolidays {
  NationalHolidays._();

  /// Map berisi: 'YYYY-MM-DD' → nama hari libur
  static const Map<String, String> _holidays = {
    // ═══════════════════════════════════════════════════
    // 2026
    // ═══════════════════════════════════════════════════
    '2026-01-01': 'Tahun Baru 2026',
    '2026-01-16': 'Isra Miraj Nabi Muhammad SAW',
    '2026-02-17': 'Tahun Baru Imlek 2577',
    '2026-03-19': 'Idul Fitri 1447 H (Hari 1)',
    '2026-03-20': 'Idul Fitri 1447 H (Hari 2)',
    '2026-03-21': 'Cuti Bersama Idul Fitri',
    '2026-03-23': 'Hari Suci Nyepi (Tahun Baru Saka 1948)',
    '2026-04-03': 'Wafat Yesus Kristus',
    '2026-05-01': 'Hari Buruh Internasional',
    '2026-05-14': 'Kenaikan Yesus Kristus',
    '2026-05-27': 'Idul Adha 1447 H',
    '2026-05-30': 'Hari Raya Waisak 2570',
    '2026-06-01': 'Hari Lahir Pancasila',
    '2026-06-16': 'Tahun Baru Islam 1448 H',
    '2026-08-17': 'Hari Kemerdekaan RI',
    '2026-08-25': 'Maulid Nabi Muhammad SAW',
    '2026-12-25': 'Hari Raya Natal',

    // ═══════════════════════════════════════════════════
    // 2027
    // ═══════════════════════════════════════════════════
    '2027-01-01': 'Tahun Baru 2027',
    '2027-01-05': 'Isra Miraj Nabi Muhammad SAW',
    '2027-02-06': 'Tahun Baru Imlek 2578',
    '2027-03-08': 'Idul Fitri 1448 H (Hari 1)',
    '2027-03-09': 'Idul Fitri 1448 H (Hari 2)',
    '2027-03-12': 'Hari Suci Nyepi (Tahun Baru Saka 1949)',
    '2027-03-26': 'Wafat Yesus Kristus',
    '2027-05-01': 'Hari Buruh Internasional',
    '2027-05-04': 'Kenaikan Yesus Kristus',
    '2027-05-17': 'Idul Adha 1448 H',
    '2027-05-20': 'Hari Raya Waisak 2571',
    '2027-06-01': 'Hari Lahir Pancasila',
    '2027-06-06': 'Tahun Baru Islam 1449 H',
    '2027-08-15': 'Maulid Nabi Muhammad SAW',
    '2027-08-17': 'Hari Kemerdekaan RI',
    '2027-12-25': 'Hari Raya Natal',
    '2027-12-26': 'Cuti Bersama Natal',

    // ═══════════════════════════════════════════════════
    // 2028
    // ═══════════════════════════════════════════════════
    '2028-01-01': 'Tahun Baru 2028',
    '2028-01-26': 'Tahun Baru Imlek 2579',
    '2028-02-25': 'Isra Miraj Nabi Muhammad SAW',
    '2028-02-26': 'Idul Fitri 1449 H (Hari 1)',
    '2028-02-27': 'Idul Fitri 1449 H (Hari 2)',
    '2028-02-28': 'Cuti Bersama Idul Fitri',
    '2028-03-01': 'Hari Suci Nyepi (Tahun Baru Saka 1950)',
    '2028-04-14': 'Wafat Yesus Kristus',
    '2028-05-01': 'Hari Buruh Internasional',
    '2028-05-05': 'Idul Adha 1449 H',
    '2028-05-18': 'Kenaikan Yesus Kristus',
    '2028-05-26': 'Tahun Baru Islam 1450 H',
    '2028-06-01': 'Hari Lahir Pancasila',
    '2028-06-04': 'Hari Raya Waisak 2572',
    '2028-08-04': 'Maulid Nabi Muhammad SAW',
    '2028-08-17': 'Hari Kemerdekaan RI',
    '2028-12-25': 'Hari Raya Natal',
    '2028-12-26': 'Cuti Bersama Natal',
  };

  /// Ambil nama libur dari tanggal 'YYYY-MM-DD'. Null jika bukan hari libur.
  static String? getHolidayName(String dateStr) => _holidays[dateStr];

  /// Cek apakah tanggal ini hari libur nasional
  static bool isHoliday(String dateStr) => _holidays.containsKey(dateStr);

  /// Cek apakah tanggal ini hari Minggu
  static bool isSunday(DateTime date) => date.weekday == DateTime.sunday;

  /// Cek apakah tanggal ini hari libur (Minggu ATAU libur nasional)
  static bool isRedDay(DateTime date) {
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return isSunday(date) || isHoliday(dateStr);
  }

  /// Ambil semua libur nasional pada bulan & tahun tertentu
  static Map<String, String> getHolidaysInMonth(int year, int month) {
    final prefix = '$year-${month.toString().padLeft(2, '0')}-';
    return Map.fromEntries(
      _holidays.entries.where((e) => e.key.startsWith(prefix)),
    );
  }
}

