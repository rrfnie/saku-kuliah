import 'dart:async';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../../../core/widgets/pastel_card.dart';
import '../../../schedule/models/schedule_model.dart';
import '../../models/course_krs_model.dart';

/// Modal Bottom Sheet Pintar untuk Scan & Impor Otomatis KRS & KHS (100% Offline & Editable)
class ScanKrsKhsSheet extends StatefulWidget {
  const ScanKrsKhsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ScanKrsKhsSheet(),
    );
  }

  @override
  State<ScanKrsKhsSheet> createState() => _ScanKrsKhsSheetState();
}

class _ScanKrsKhsSheetState extends State<ScanKrsKhsSheet> {
  final SakuKuliahState _appState = SakuKuliahState.instance;

  // 0: Scan KRS (Jadwal & Kuliah), 1: Scan KHS (Nilai & IPK)
  int _selectedMode = 0;
  int _selectedKhsSemester = 5;

  @override
  void initState() {
    super.initState();
    _selectedKhsSemester = _appState.studentProfile.currentSemester;
  }

  // Status Pemindaian
  bool _isScanning = false;
  String _scanningStatus = '';
  bool _hasResult = false;
  String _loadedFileName = '';

  final List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  // Hasil Ekstraksi KRS & KHS (Awalnya kosong, diisi dari hasil berkas asli)
  List<Map<String, dynamic>> _scannedKrsItems = [];
  List<Map<String, dynamic>> _scannedKhsItems = [];

  static const List<String> _krsBlacklist = [
    'kementerian', 'universitas', 'institut', 'sekolah tinggi', 'politeknik',
    'fakultas', 'program studi', 'prodi', 'jurusan', 'kartu rencana studi', 'krs',
    'kartu hasil studi', 'khs', 'semester', 'tahun akademik', 'tahun ajaran',
    'nama mahasiswa', 'nama mhs', 'nomor induk', 'nim', 'dosen pembimbing',
    'dosen pa', 'tanda tangan', 'total sks', 'halaman', 'tanggal cetak',
    'pejabat', 'pengesahan', 'sks tempuh', 'ip semester', 'ips', 'ipk',
    'kode mk', 'nama mk', 'mata kuliah', 'matakuliah', 'waktu', 'ruang',
    'jadwal', 'kelas', 'bobot', 'nilai', 'predikat', 'keterangan', 'status',
  ];

  bool _isReadableText(String text) {
    final trimmed = text.trim();
    if (trimmed.length < 3) return false;
    final invalidChars = RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F÷ÆÕÚÈëµ©¬~^]');
    if (invalidChars.hasMatch(trimmed)) return false;

    final readableMatches = RegExp(r'[a-zA-Z0-9\s\-\.\,\/\&\(\)\:\x27\x22]').allMatches(trimmed).length;
    return (readableMatches / trimmed.length) >= 0.75;
  }

  /// Ekstraksi teks asli dari berkas PDF menggunakan Syncfusion PDF Extractor (100% Offline)
  String _extractTextFromPdfBytes(Uint8List bytes) {
    try {
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final String text = extractor.extractText();
      document.dispose();
      return text;
    } catch (_) {
      return '';
    }
  }

  /// Intelligent Parser Teks Tabel KRS dari SIAKAD / Dokumen PDF
  List<Map<String, dynamic>> _parseKrsText(String rawText) {
    final List<Map<String, dynamic>> parsed = [];
    final lines = rawText.split('\n');

    final dayMap = {
      'senin': 0, 'sen': 0, 'monday': 0, 'mon': 0,
      'selasa': 1, 'sel': 1, 'tuesday': 1, 'tue': 1,
      'rabu': 2, 'rab': 2, 'wednesday': 2, 'wed': 2,
      'kamis': 3, 'kam': 3, 'thursday': 3, 'thu': 3,
      'jumat': 4, 'jum': 4, 'jum\'at': 4, 'friday': 4, 'fri': 4,
      'sabtu': 5, 'sab': 5, 'saturday': 5, 'sat': 5,
      'minggu': 6, 'min': 6, 'sunday': 6, 'sun': 6,
    };

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.length < 4) continue;
      if (!_isReadableText(line)) continue;

      final lower = line.toLowerCase();
      if (_krsBlacklist.any((keyword) => lower.contains(keyword))) continue;

      // 1. Deteksi Kode MK (IF3102, TIK101, etc.)
      String code = 'MK${parsed.length + 1}';
      final codeRegex = RegExp(r'\b([A-Za-z]{2,5}\s*[-_]?\s*\d{2,4}[A-Za-z]?)\b');
      final codeMatch = codeRegex.firstMatch(line);
      if (codeMatch != null) {
        code = codeMatch.group(1)!.replaceAll(' ', '').toUpperCase();
      }

      // 2. Deteksi Hari
      int dayIndex = 0;
      String dayName = 'Senin';
      for (final entry in dayMap.entries) {
        final regex = RegExp(r'\b' + entry.key + r'\b', caseSensitive: false);
        if (regex.hasMatch(line)) {
          dayIndex = entry.value;
          dayName = _dayNames[dayIndex];
          break;
        }
      }

      // 3. Deteksi Jam (contoh: 08:00 - 10:30 atau 08.00-10.30)
      final timeRegex = RegExp(r'(\d{1,2}[:.]\d{2})\s*[-–to]\s*(\d{1,2}[:.]\d{2})');
      final timeMatch = timeRegex.firstMatch(line);
      String timeStr = '08:00 - 10:30';
      if (timeMatch != null) {
        final start = timeMatch.group(1)!.replaceAll('.', ':').padLeft(5, '0');
        final end = timeMatch.group(2)!.replaceAll('.', ':').padLeft(5, '0');
        timeStr = '$start - $end';
      }

      // 4. Deteksi SKS
      final sksRegex = RegExp(r'\b([1-6])\s*(?:sks|credit|cr)?\b', caseSensitive: false);
      final sksMatch = sksRegex.firstMatch(line);
      int sks = 3;
      if (sksMatch != null) {
        sks = int.tryParse(sksMatch.group(1)!) ?? 3;
      }

      // 5. Deteksi Ruangan
      final roomRegex = RegExp(r'(Lab\s*[\w\.\-]+|R\.\s*[\w\.\-]+|Ruang\s*[\w\.\-]+|Gedung\s*[\w\.\-]+)', caseSensitive: false);
      final roomMatch = roomRegex.firstMatch(line);
      String roomStr = roomMatch != null ? roomMatch.group(0)! : 'R. Kuliah';

      // 6. Bersihkan Nama Mata Kuliah
      String courseName = line;
      if (codeMatch != null) courseName = courseName.replaceFirst(codeMatch.group(0)!, '');
      if (timeMatch != null) courseName = courseName.replaceFirst(timeMatch.group(0)!, '');
      if (roomMatch != null) courseName = courseName.replaceFirst(roomMatch.group(0)!, '');
      courseName = courseName.replaceAll(RegExp(r'\b(senin|selasa|rabu|kamis|jumat|sabtu|minggu)\b', caseSensitive: false), '');
      courseName = courseName.replaceAll(RegExp(r'\b[1-6]\s*(?:sks|credit|cr)?\b', caseSensitive: false), '');
      courseName = courseName.replaceAll(RegExp(r'^[0-9.\-*\t\s|]+'), '').replaceAll(RegExp(r'[\t,;|]+'), ' ').trim();

      if (courseName.length < 3 || !_isReadableText(courseName)) continue;
      if (_krsBlacklist.any((keyword) => courseName.toLowerCase().contains(keyword))) continue;

      parsed.add({
        'selected': true,
        'code': code,
        'name': courseName,
        'sks': sks,
        'dayIndex': dayIndex,
        'dayName': dayName,
        'time': timeStr,
        'room': roomStr,
        'lecturer': 'Dosen Pengampu',
        'category': sks >= 3 ? 'Kuliah Inti' : 'Teori',
        'accent': '#805063',
      });
    }

    return parsed;
  }

  /// Intelligent Parser Teks Tabel KHS (Nilai, SKS & Bobot) dari SIAKAD
  List<Map<String, dynamic>> _parseKhsText(String rawText) {
    final List<Map<String, dynamic>> parsed = [];
    final lines = rawText.split('\n');

    final Map<String, double> gradePointMap = {
      'A': 4.00,
      'A-': 3.70,
      'B+': 3.30,
      'B': 3.00,
      'B-': 2.70,
      'C+': 2.30,
      'C': 2.00,
      'D': 1.00,
      'E': 0.00,
    };

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty || line.length < 4) continue;
      if (!_isReadableText(line)) continue;

      final lower = line.toLowerCase();
      if (_krsBlacklist.any((keyword) => lower.contains(keyword))) continue;

      // 1. Deteksi Nilai Huruf
      String grade = 'A';
      double point = 4.00;
      final gradeRegex = RegExp(r'\b([A-E][+-]?)\b');
      final gradeMatches = gradeRegex.allMatches(line).toList();
      for (final m in gradeMatches.reversed) {
        final val = m.group(1)!;
        if (gradePointMap.containsKey(val)) {
          grade = val;
          point = gradePointMap[grade]!;
          break;
        }
      }

      // 2. Deteksi SKS
      int sks = 3;
      final sksRegex = RegExp(r'\b([1-6])\s*(?:sks|credit|s)?\b', caseSensitive: false);
      final sksMatch = sksRegex.firstMatch(line);
      if (sksMatch != null) {
        sks = int.tryParse(sksMatch.group(1)!) ?? 3;
      }

      // 3. Deteksi Kode MK (IF3102, TIK101, etc.)
      String code = 'MK${parsed.length + 1}';
      final codeRegex = RegExp(r'\b([A-Za-z]{2,5}\s*[-_]?\s*\d{2,4}[A-Za-z]?)\b');
      final codeMatch = codeRegex.firstMatch(line);
      if (codeMatch != null) {
        code = codeMatch.group(1)!.replaceAll(' ', '').toUpperCase();
      }

      // 4. Bersihkan Nama Mata Kuliah
      String courseName = line;
      if (codeMatch != null) courseName = courseName.replaceFirst(codeMatch.group(0)!, '');
      courseName = courseName.replaceAll(RegExp(r'\b([A-E][+-]?)\b'), '');
      courseName = courseName.replaceAll(RegExp(r'\b[0-4](?:\.\d{1,2})?\b'), '');
      courseName = courseName.replaceAll(RegExp(r'\b[1-6]\s*(?:sks|credit)?\b', caseSensitive: false), '');
      courseName = courseName.replaceAll(RegExp(r'^[0-9.\-*\t\s|]+'), '').replaceAll(RegExp(r'[\t,;|]+'), ' ').trim();

      if (courseName.length < 3 || !_isReadableText(courseName)) continue;
      if (_krsBlacklist.any((keyword) => courseName.toLowerCase().contains(keyword))) continue;

      parsed.add({
        'selected': true,
        'code': code,
        'name': courseName,
        'sks': sks,
        'grade': grade,
        'point': point,
      });
    }

    return parsed;
  }

  void _startScanning(String sourceLabel, {List<Map<String, dynamic>>? parsedItems}) {
    setState(() {
      _isScanning = true;
      _hasResult = false;
      _loadedFileName = sourceLabel;
      _scanningStatus = 'Membuka berkas $sourceLabel... 📄';
    });

    Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _scanningStatus = _selectedMode == 0
              ? 'Menganalisis teks mata kuliah, jadwal & ruangan... 🔍'
              : 'Menganalisis tabel nilai KHS & bobot SKS... 🔍';
        });
      }
    });

    Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _scanningStatus = 'Menyusun daftar hasil pemindaian... ✨';
        });
      }
    });

    Timer(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          if (parsedItems != null) {
            if (_selectedMode == 0) {
              _scannedKrsItems = List.from(parsedItems);
            } else {
              _scannedKhsItems = List.from(parsedItems);
            }
          } else {
            if (_selectedMode == 0) {
              _scannedKrsItems = [];
            } else {
              _scannedKhsItems = [];
            }
          }
          _isScanning = false;
          _hasResult = true;
        });
      }
    });
  }

  Future<void> _pickDocumentFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'csv', 'html', 'json'],
      );
      if (files.isNotEmpty) {
        final file = files.first;
        List<Map<String, dynamic>> parsed = [];
        String extractedText = '';

        final isPdf = file.name.toLowerCase().endsWith('.pdf');
        if (isPdf) {
          try {
            final bytes = await file.xFile.readAsBytes();
            extractedText = _extractTextFromPdfBytes(bytes);
          } catch (_) {}
        } else {
          try {
            extractedText = await file.xFile.readAsString();
          } catch (_) {}
        }

        if (extractedText.trim().isNotEmpty) {
          parsed = _selectedMode == 0 ? _parseKrsText(extractedText) : _parseKhsText(extractedText);
        }

        _startScanning(file.name, parsedItems: parsed);
      }
    } catch (_) {
      _startScanning(_selectedMode == 0 ? 'Dokumen KRS' : 'Dokumen KHS', parsedItems: []);
    }
  }

  Future<void> _pickImageFile() async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (files.isNotEmpty) {
        final fileName = files.first.name;
        // Gambar foto bitmap tidak memiliki teks stream secara offline, hasil diset kosong dan user dipandu
        _startScanning(fileName, parsedItems: []);
      }
    } catch (_) {
      _startScanning(_selectedMode == 0 ? 'Foto KRS' : 'Foto KHS', parsedItems: []);
    }
  }

  void _pasteTextDialog() {
    final textController = TextEditingController();
    final isKrs = _selectedMode == 0;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.paste_rounded, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              isKrs ? 'Tempel Teks KRS dari SIAKAD' : 'Tempel Teks KHS dari SIAKAD',
              style: AppTypography.headlineSm.copyWith(fontSize: 16),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isKrs
                  ? 'Salin tabel jadwal KRS dari portal kampusmu, lalu tempel di bawah ini:'
                  : 'Salin tabel nilai KHS dari portal kampusmu, lalu tempel di bawah ini:',
              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: textController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: isKrs
                    ? 'Contoh tabel SIAKAD:\n1\tTI-301\tPemrograman Web\t3\tSenin\t08:00 - 10:30\tLab Komputer\tDr. Sarah\n2\tTI-302\tKecerdasan Buatan\t3\tRabu\t13:00 - 15:30\tR. Teori 201\tProf. Bambang'
                    : 'Contoh tabel KHS:\n1\tTI-301\tPemrograman Web\t3\tA\t4.00\n2\tTI-302\tKecerdasan Buatan\t3\tA-\t3.70',
              ),
            ),
          ],
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
              final raw = textController.text.trim();
              Navigator.pop(ctx);
              if (raw.isNotEmpty) {
                final parsed = isKrs ? _parseKrsText(raw) : _parseKhsText(raw);
                _startScanning(isKrs ? 'Teks Salinan KRS' : 'Teks Salinan KHS', parsedItems: parsed);
              }
            },
            child: const Text('Proses Teks ✨'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk Mengedit Item Hasil Scan
  void _editKrsItemDialog(int index) {
    final item = _scannedKrsItems[index];
    final nameCtrl = TextEditingController(text: item['name'] as String);
    final roomCtrl = TextEditingController(text: item['room'] as String);
    final timeCtrl = TextEditingController(text: item['time'] as String);
    final lecturerCtrl = TextEditingController(text: item['lecturer'] as String);
    int selectedDay = item['dayIndex'] as int;
    int selectedSks = item['sks'] as int;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Mata Kuliah',
            style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Mata Kuliah', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Nama MK')),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hari Kuliah', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<int>(
                            value: selectedDay,
                            decoration: const InputDecoration(),
                            items: List.generate(_dayNames.length, (i) {
                              return DropdownMenuItem(value: i, child: Text(_dayNames[i]));
                            }),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedDay = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SKS', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<int>(
                            value: selectedSks,
                            decoration: const InputDecoration(),
                            items: [1, 2, 3, 4, 6].map((s) {
                              return DropdownMenuItem(value: s, child: Text('$s SKS'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedSks = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jam Kuliah', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          TextField(controller: timeCtrl, decoration: const InputDecoration(hintText: '08:00 - 10:30')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ruangan', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          TextField(controller: roomCtrl, decoration: const InputDecoration(hintText: 'Lab 201')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text('Dosen Pengampu', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                TextField(controller: lecturerCtrl, decoration: const InputDecoration(hintText: 'Nama Dosen')),
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
                setState(() {
                  _scannedKrsItems[index] = {
                    ...item,
                    'name': nameCtrl.text.trim().isEmpty ? item['name'] : nameCtrl.text.trim(),
                    'room': roomCtrl.text.trim().isEmpty ? item['room'] : roomCtrl.text.trim(),
                    'time': timeCtrl.text.trim().isEmpty ? item['time'] : timeCtrl.text.trim(),
                    'lecturer': lecturerCtrl.text.trim().isEmpty ? item['lecturer'] : lecturerCtrl.text.trim(),
                    'dayIndex': selectedDay,
                    'dayName': _dayNames[selectedDay],
                    'sks': selectedSks,
                  };
                });
                Navigator.pop(ctx);
              },
              child: const Text('Simpan Perubahan 🌸'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog untuk Menambah Mata Kuliah Baru Manual
  void _addKrsItemDialog() {
    final nameCtrl = TextEditingController();
    final roomCtrl = TextEditingController(text: 'R. Teori 101');
    final timeCtrl = TextEditingController(text: '08:00 - 10:30');
    final lecturerCtrl = TextEditingController(text: 'Dosen Pengampu');
    int selectedDay = 0;
    int selectedSks = 3;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '+ Tambah Mata Kuliah',
            style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Mata Kuliah', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Contoh: Pemrograman Web')),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hari', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<int>(
                            value: selectedDay,
                            decoration: const InputDecoration(),
                            items: List.generate(_dayNames.length, (i) {
                              return DropdownMenuItem(value: i, child: Text(_dayNames[i]));
                            }),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedDay = val);
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SKS', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<int>(
                            value: selectedSks,
                            decoration: const InputDecoration(),
                            items: [1, 2, 3, 4, 6].map((s) {
                              return DropdownMenuItem(value: s, child: Text('$s SKS'));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedSks = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jam', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          TextField(controller: timeCtrl, decoration: const InputDecoration(hintText: '08:00 - 10:30')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ruangan', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          TextField(controller: roomCtrl, decoration: const InputDecoration(hintText: 'Lab 201')),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text('Dosen', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                TextField(controller: lecturerCtrl, decoration: const InputDecoration(hintText: 'Nama Dosen')),
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
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _scannedKrsItems.add({
                      'selected': true,
                      'code': 'MK${_scannedKrsItems.length + 1}',
                      'name': name,
                      'sks': selectedSks,
                      'dayIndex': selectedDay,
                      'dayName': _dayNames[selectedDay],
                      'time': timeCtrl.text.trim().isEmpty ? '08:00 - 10:30' : timeCtrl.text.trim(),
                      'room': roomCtrl.text.trim().isEmpty ? 'R. Kuliah' : roomCtrl.text.trim(),
                      'lecturer': lecturerCtrl.text.trim().isEmpty ? 'Dosen' : lecturerCtrl.text.trim(),
                      'category': selectedSks >= 3 ? 'Kuliah Inti' : 'Teori',
                      'accent': '#805063',
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Tambah 🌸'),
            ),
          ],
        ),
      ),
    );
  }

  void _importKrsData() {
    final selectedItems = _scannedKrsItems.where((item) => item['selected'] == true).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu mata kuliah untuk diimpor! 🌸')),
      );
      return;
    }

    final nowId = DateTime.now().millisecondsSinceEpoch;
    final List<ScheduleModel> newSchedules = [];
    final List<CourseKrsModel> newKrs = [];

    for (int i = 0; i < selectedItems.length; i++) {
      final item = selectedItems[i];
      final parts = (item['time'] as String).split(' - ');
      final startTime = parts.isNotEmpty ? parts[0] : '08:00';
      final endTime = parts.length > 1 ? parts[1] : '10:00';

      // 1. Tambah Jadwal Kuliah
      newSchedules.add(
        ScheduleModel(
          id: nowId + i,
          dayOfWeek: item['dayIndex'] as int,
          courseName: item['name'] as String,
          courseCode: item['code'] as String,
          sks: item['sks'] as int,
          room: item['room'] as String,
          lecturer: item['lecturer'] as String,
          startTime: startTime,
          endTime: endTime,
          category: item['category'] as String,
          accentColorHex: item['accent'] as String,
        ),
      );

      // 2. Tambah Mata Kuliah KRS Semester
      newKrs.add(
        CourseKrsModel(
          id: nowId + 100 + i,
          semesterNumber: _appState.studentProfile.currentSemester,
          courseName: item['name'] as String,
          courseCode: item['code'] as String,
          sks: item['sks'] as int,
          targetGrade: 'A',
          gradePoint: 4.00,
          attendancePresent: 0,
          attendanceTotal: 14,
          status: 'Aktif',
        ),
      );
    }

    _appState.importSchedules(newSchedules);
    _appState.importKrsCourses(newKrs);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✨ Berhasil mengimpor ${selectedItems.length} mata kuliah ke Jadwal & KRS! 🌸',
        ),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  // Dialog untuk Mengedit Item Nilai KHS
  void _editKhsItemDialog(int index) {
    final item = _scannedKhsItems[index];
    final nameCtrl = TextEditingController(text: item['name'] as String);
    final codeCtrl = TextEditingController(text: item['code'] as String);
    int selectedSks = item['sks'] as int;
    String selectedGrade = item['grade'] as String;

    const gradePointMap = {
      'A': 4.00,
      'A-': 3.70,
      'B+': 3.30,
      'B': 3.00,
      'B-': 2.70,
      'C+': 2.30,
      'C': 2.00,
      'D': 1.00,
      'E': 0.00,
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Edit Nilai Mata Kuliah',
            style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Mata Kuliah', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Nama Mata Kuliah')),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kode MK', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          TextField(controller: codeCtrl, decoration: const InputDecoration(hintText: 'IF3102')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SKS', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<int>(
                            value: selectedSks,
                            items: [1, 2, 3, 4, 6].map((s) => DropdownMenuItem(value: s, child: Text('$s SKS'))).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedSks = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text('Nilai Huruf', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: gradePointMap.containsKey(selectedGrade) ? selectedGrade : 'A',
                  items: gradePointMap.keys.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text('$g (Bobot ${gradePointMap[g]!.toStringAsFixed(2)})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedGrade = val);
                  },
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
                setState(() {
                  _scannedKhsItems[index] = {
                    ...item,
                    'name': nameCtrl.text.trim().isEmpty ? item['name'] : nameCtrl.text.trim(),
                    'code': codeCtrl.text.trim().isEmpty ? item['code'] : codeCtrl.text.trim().toUpperCase(),
                    'sks': selectedSks,
                    'grade': selectedGrade,
                    'point': gradePointMap[selectedGrade] ?? 4.00,
                  };
                });
                Navigator.pop(ctx);
              },
              child: const Text('Simpan Perubahan 🌸'),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog untuk Menambah Item KHS Baru Manual
  void _addKhsItemDialog() {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController(text: 'MK${_scannedKhsItems.length + 1}');
    int selectedSks = 3;
    String selectedGrade = 'A';

    const gradePointMap = {
      'A': 4.00,
      'A-': 3.70,
      'B+': 3.30,
      'B': 3.00,
      'B-': 2.70,
      'C+': 2.30,
      'C': 2.00,
      'D': 1.00,
      'E': 0.00,
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            '+ Tambah Nilai Mata Kuliah',
            style: AppTypography.headlineSm.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Mata Kuliah', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'Contoh: Rekayasa Web')),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Kode MK', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          TextField(controller: codeCtrl, decoration: const InputDecoration(hintText: 'IF3201')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SKS', style: AppTypography.labelSm),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<int>(
                            value: selectedSks,
                            items: [1, 2, 3, 4, 6].map((s) => DropdownMenuItem(value: s, child: Text('$s SKS'))).toList(),
                            onChanged: (val) {
                              if (val != null) setDialogState(() => selectedSks = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Text('Nilai Huruf', style: AppTypography.labelSm),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedGrade,
                  items: gradePointMap.keys.map((g) {
                    return DropdownMenuItem(
                      value: g,
                      child: Text('$g (Bobot ${gradePointMap[g]!.toStringAsFixed(2)})'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedGrade = val);
                  },
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
                final name = nameCtrl.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    _scannedKhsItems.add({
                      'selected': true,
                      'code': codeCtrl.text.trim().isEmpty ? 'MK${_scannedKhsItems.length + 1}' : codeCtrl.text.trim().toUpperCase(),
                      'name': name,
                      'sks': selectedSks,
                      'grade': selectedGrade,
                      'point': gradePointMap[selectedGrade] ?? 4.00,
                    });
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('Tambahkan 🌸'),
            ),
          ],
        ),
      ),
    );
  }

  void _importKhsData() {
    final selectedItems = _scannedKhsItems.where((item) => item['selected'] == true).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih minimal satu nilai untuk diimpor! 🌸')),
      );
      return;
    }

    int totalSks = 0;
    double totalPoints = 0;
    final List<CourseKrsModel> newCoursesToImport = [];

    for (int i = 0; i < selectedItems.length; i++) {
      final item = selectedItems[i];
      final courseCode = (item['code'] as String).trim();
      final courseName = (item['name'] as String).trim();
      final sks = item['sks'] as int;
      final grade = item['grade'] as String;
      final point = (item['point'] as num).toDouble();

      totalSks += sks;
      totalPoints += (point * sks);

      // Cek apakah mata kuliah ada di krsCourses saat ini
      final existing = _appState.krsCourses.where((c) => c.courseCode.toUpperCase() == courseCode.toUpperCase()).toList();
      if (existing.isNotEmpty) {
        _appState.updateKrsGrade(existing.first.id!, grade, point);
      } else {
        newCoursesToImport.add(
          CourseKrsModel(
            id: DateTime.now().millisecondsSinceEpoch + 500 + i,
            semesterNumber: _selectedKhsSemester,
            courseName: courseName,
            courseCode: courseCode,
            sks: sks,
            targetGrade: grade,
            gradePoint: point,
            attendancePresent: 14,
            attendanceTotal: 14,
            status: 'Selesai',
          ),
        );
      }
    }

    if (newCoursesToImport.isNotEmpty) {
      _appState.importKrsCourses(newCoursesToImport);
    }

    final double ips = totalSks > 0 ? (totalPoints / totalSks) : 0.0;
    final double roundedIps = double.parse(ips.toStringAsFixed(2));

    // Perbarui riwayat KHS semester di AppState (otomatis hitung ulang IPK & total SKS)
    _appState.updateSemesterRecord(_selectedKhsSemester, totalSks, roundedIps);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          '🎉 KHS Sem $_selectedKhsSemester berhasil diimpor! IPS: $roundedIps ($totalSks SKS) • IPK diperbarui! 🎓🌸',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab Handle
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
            const SizedBox(height: 14),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.document_scanner_rounded,
                        size: 20,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan & Impor KRS / KHS',
                          style: AppTypography.headlineSm.copyWith(
                            fontSize: 16.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '100% Offline Parser • Cepat & Otomatis',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
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
            const SizedBox(height: 14),

            // Mode Selector Pill (KRS vs KHS)
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMode = 0;
                          _hasResult = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedMode == 0 ? AppColors.surfaceContainerLowest : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _selectedMode == 0
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '📄 Scan KRS (Jadwal)',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: _selectedMode == 0 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedMode == 0 ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMode = 1;
                          _hasResult = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _selectedMode == 1 ? AppColors.surfaceContainerLowest : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: _selectedMode == 1
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '📊 Scan KHS (Nilai)',
                            style: AppTypography.labelMd.copyWith(
                              fontWeight: _selectedMode == 1 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedMode == 1 ? AppColors.primary : AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Scanning Animation Screen
            if (_isScanning) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x33F4DCE4)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.radar_rounded,
                          size: 28,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _scanningStatus,
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: const SizedBox(
                        width: 180,
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!_hasResult) ...[
              // Source Selection Area
              Text(
                _selectedMode == 0
                    ? 'Pilih metode untuk membaca KRS dari portal kampusmu:'
                    : 'Pilih metode untuk membaca KHS / Transkrip semestermu:',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.camera_alt_rounded,
                      title: 'Foto KRS/KHS',
                      subtitle: 'Buka Galeri / Kamera',
                      color: AppColors.primaryContainer,
                      onTap: _pickImageFile,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.picture_as_pdf_rounded,
                      title: 'File PDF / Gambar',
                      subtitle: 'Buka File Laptop / HP',
                      color: AppColors.secondaryContainer,
                      onTap: _pickDocumentFile,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Paste text from SIAKAD web
              InkWell(
                onTap: _pasteTextDialog,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33F4DCE4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.paste_rounded, size: 16, color: AppColors.onSecondaryContainer),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tempel Teks Tabel SIAKAD 📋 (Paling Akurat!)',
                              style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Copy tabel jadwal dari website kampus dan paste langsung',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Notice Berkas Dimuat
              if (_loadedFileName.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Berkas "$_loadedFileName" terdeteksi! Kamu bisa sesuaikan atau edit mata kuliah di bawah sebelum diimpor 🌸',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onPrimaryContainer,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Result Preview Header Area
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedMode == 0 ? 'Matkul Terdeteksi' : 'Nilai Terdeteksi',
                      style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: Text(
                      _selectedMode == 0 ? 'Tambah MK' : 'Tambah Nilai',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onPressed: _selectedMode == 0 ? _addKrsItemDialog : _addKhsItemDialog,
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() {
                        _hasResult = false;
                      });
                    },
                    child: const Text('Scan Ulang', style: TextStyle(fontSize: 11)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Item List
              if (_selectedMode == 0) ...[
                // KRS List
                if (_scannedKrsItems.isEmpty)
                  PastelCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded, size: 36, color: AppColors.primary),
                        const SizedBox(height: 8),
                        Text(
                          'Teks KRS Tidak Terdeteksi Otomatis',
                          style: AppTypography.headlineSm.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Berkas berupa foto atau PDF tanpa teks digital sehingga teks belum terbaca secara offline. Yuk gunakan cara paling presisi & instan ini:',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: PastelButton(
                                text: 'Tempel Teks SIAKAD 📋',
                                onPressed: _pasteTextDialog,
                                type: PastelButtonType.primary,
                                height: 40,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: PastelButton(
                                text: '+ Tambah Manual',
                                onPressed: _addKrsItemDialog,
                                type: PastelButtonType.secondary,
                                height: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else ...[
                  ...List.generate(_scannedKrsItems.length, (idx) {
                  final item = _scannedKrsItems[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PastelCard(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item['selected'] as bool,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                item['selected'] = val ?? true;
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.secondaryContainer,
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                      child: Text(
                                        '${item['sks']} SKS • ${item['dayName']}',
                                        style: AppTypography.labelSm.copyWith(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      item['code'] as String,
                                      style: AppTypography.labelSm.copyWith(
                                        fontSize: 9.5,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item['name'] as String,
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['time']} • ${item['room']} • ${item['lecturer']}',
                                  style: AppTypography.bodySm.copyWith(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          // Edit Button
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            tooltip: 'Edit Detail',
                            onPressed: () => _editKrsItemDialog(idx),
                          ),
                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            tooltip: 'Hapus',
                            onPressed: () {
                              setState(() {
                                _scannedKrsItems.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                PastelButton(
                  text: 'Impor ke Jadwal Kuliah & KRS (${_scannedKrsItems.where((i) => i['selected'] == true).length}) 🌸',
                  width: double.infinity,
                  trailingIcon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                  onPressed: _importKrsData,
                ),
              ],
            ] else ...[
              if (_scannedKhsItems.isEmpty)
                PastelCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.search_off_rounded, size: 36, color: AppColors.secondary),
                      const SizedBox(height: 8),
                      Text(
                        'Teks KHS Tidak Terdeteksi Otomatis',
                        style: AppTypography.headlineSm.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Berkas foto atau PDF ini belum memiliki teks nilai digital. Yuk gunakan fitur tempel teks dari SIAKAD atau input manual:',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: PastelButton(
                              text: 'Tempel Teks SIAKAD 📋',
                              onPressed: _pasteTextDialog,
                              type: PastelButtonType.primary,
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PastelButton(
                              text: '+ Tambah Nilai',
                              onPressed: _addKhsItemDialog,
                              type: PastelButtonType.secondary,
                              height: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else ...[
                // Summary Card KHS
                Builder(
                  builder: (context) {
                    final selectedKhs = _scannedKhsItems.where((i) => i['selected'] == true).toList();
                    int totalSks = 0;
                    double totalPts = 0;
                    for (final item in selectedKhs) {
                      final s = item['sks'] as int;
                      final p = (item['point'] as num).toDouble();
                      totalSks += s;
                      totalPts += (s * p);
                    }
                    final ips = totalSks > 0 ? (totalPts / totalSks) : 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x33D98BAE)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Impor ke: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                                    DropdownButton<int>(
                                      value: _selectedKhsSemester,
                                      isDense: true,
                                      underline: const SizedBox(),
                                      items: List.generate(8, (i) => i + 1).map((s) {
                                        return DropdownMenuItem(
                                          value: s,
                                          child: Text('Semester $s', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) setState(() => _selectedKhsSemester = val);
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$totalSks SKS Terpilih (${selectedKhs.length} Mata Kuliah)',
                                  style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Text('Estimasi IPS', style: TextStyle(fontSize: 9.5, color: Colors.white70)),
                                Text(
                                  ips.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // KHS List
                ...List.generate(_scannedKhsItems.length, (idx) {
                  final item = _scannedKhsItems[idx];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PastelCard(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item['selected'] as bool,
                            activeColor: AppColors.primary,
                            onChanged: (val) {
                              setState(() {
                                item['selected'] = val ?? true;
                              });
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: AppTypography.headlineSm.copyWith(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item['code']} • ${item['sks']} SKS • Bobot: ${((item['point'] as num).toDouble()).toStringAsFixed(2)}',
                                  style: AppTypography.bodySm.copyWith(fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Nilai ${item['grade']}',
                              style: AppTypography.labelSm.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          // Edit Button
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.primary),
                            tooltip: 'Edit Nilai',
                            onPressed: () => _editKhsItemDialog(idx),
                          ),
                          // Delete Button
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            tooltip: 'Hapus',
                            onPressed: () {
                              setState(() {
                                _scannedKhsItems.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                PastelButton(
                  text: 'Simpan ke KHS & Perbarui IPK (${_scannedKhsItems.where((i) => i['selected'] == true).length} MK) ✨',
                  width: double.infinity,
                  trailingIcon: const Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                  onPressed: _importKhsData,
                ),
              ],
            ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33F4DCE4)),
        ),
        child: Column(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTypography.labelSm.copyWith(
                fontSize: 9.5,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
