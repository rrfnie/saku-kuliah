import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/academic_event_model.dart';

/// Bottom Sheet Manis untuk Menambah Jadwal UTS, UAS, Ujian Praktikum, atau Libur
class AddExamEventSheet extends StatefulWidget {
  final DateTime? initialDate;

  const AddExamEventSheet({super.key, this.initialDate});

  static Future<void> show(BuildContext context, {DateTime? initialDate}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExamEventSheet(initialDate: initialDate),
    );
  }

  @override
  State<AddExamEventSheet> createState() => _AddExamEventSheetState();
}

class _AddExamEventSheetState extends State<AddExamEventSheet> {
  final SakuKuliahState _appState = SakuKuliahState.instance;

  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  String _selectedType = 'UTS';
  late DateTime _selectedDate;
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 0);
  String? _selectedCourseName;

  final List<Map<String, dynamic>> _eventTypes = [
    {'type': 'UTS', 'label': 'UTS', 'icon': '📝', 'color': AppColors.primary},
    {'type': 'UAS', 'label': 'UAS', 'icon': '🎓', 'color': AppColors.tertiary},
    {'type': 'Ujian Praktikum', 'label': 'Praktikum', 'icon': '💻', 'color': AppColors.secondary},
    {'type': 'Kuis', 'label': 'Kuis / Ujian', 'icon': '✍️', 'color': Color(0xFFB06000)},
    {'type': 'Libur', 'label': 'Libur Kuliah', 'icon': '🌴', 'color': Color(0xFF2E7D32)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _titleController = TextEditingController(text: 'UTS Desain Antarmuka & UX');
    _locationController = TextEditingController(text: 'Lab Multimedia 402');
    _notesController = TextEditingController(text: 'Bawa kartu ujian & laptop. Sifat ujian: Praktik.');

    if (_appState.krsCourses.isNotEmpty) {
      _selectedCourseName = _appState.krsCourses.first.courseName;
      _updateTitleBasedOnSelection();
    }
  }

  void _updateTitleBasedOnSelection() {
    if (_selectedType == 'Libur') {
      _titleController.text = 'Libur Kuliah & Kegiatan Akademik';
      _locationController.text = 'Kampus / Rumah';
    } else if (_selectedCourseName != null) {
      _titleController.text = '$_selectedType $_selectedCourseName';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2032),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceContainerLowest,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceContainerLowest,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _saveEvent() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul ujian / agenda tidak boleh kosong yaa! 🌸')),
      );
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final newEvent = AcademicEventModel(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      eventDate: dateStr,
      startTime: _formatTime(_startTime),
      endTime: _formatTime(_endTime),
      eventType: _selectedType,
      location: _locationController.text.trim().isEmpty ? 'Ruang Ujian' : _locationController.text.trim(),
      notes: _notesController.text.trim(),
    );

    _appState.addAcademicEvent(newEvent);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text('✨ Jadwal $_selectedType "$title" berhasil ditambahkan! 🌸'),
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
            // Drag Handle
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
            const SizedBox(height: 14),

            // Header Title
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_note_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Jadwal Ujian / Agenda',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Catat jadwal UTS, UAS, kuis, atau hari libur akademik',
                        style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Tipe Ujian / Agenda (Chips)
            Text('Tipe Kegiatan', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: _eventTypes.map((item) {
                  final isSelected = _selectedType == item['type'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: isSelected,
                      label: Text('${item['icon']} ${item['label']}'),
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                      ),
                      selectedColor: item['color'] as Color,
                      backgroundColor: AppColors.surfaceContainerLow,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(
                        color: isSelected ? Colors.transparent : const Color(0x33D98BAE),
                      ),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _selectedType = item['type'] as String;
                            _updateTitleBasedOnSelection();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Pilih Mata Kuliah Terdaftar (Jika Bukan Libur)
            if (_selectedType != 'Libur' && _appState.krsCourses.isNotEmpty) ...[
              Text('Pilih Mata Kuliah Terdaftar', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x33D98BAE)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCourseName,
                    isExpanded: true,
                    items: _appState.krsCourses.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.courseName,
                        child: Text(
                          '${c.courseCode} - ${c.courseName} (${c.sks} SKS)',
                          style: const TextStyle(fontSize: 12.5),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedCourseName = val;
                          _updateTitleBasedOnSelection();
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 3. Judul Ujian / Agenda
            Text('Nama Ujian / Agenda', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Contoh: UTS Pemrograman Mobile',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x33D98BAE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x33D98BAE)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Tanggal Ujian & Waktu
            Row(
              children: [
                // Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal', style: AppTypography.labelSm),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x33D98BAE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  DateFormat('d MMM yyyy').format(_selectedDate),
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Jam Mulai
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jam Mulai', style: AppTypography.labelSm),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _pickTime(isStart: true),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x33D98BAE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatTime(_startTime)} WIB',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Jam Selesai
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Selesai', style: AppTypography.labelSm),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => _pickTime(isStart: false),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0x33D98BAE)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_off_outlined, size: 16, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 6),
                              Text(
                                '${_formatTime(_endTime)} WIB',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // 5. Ruangan / Lokasi Ujian
            Text('Ruangan / Lokasi', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: 'Contoh: Lab Multimedia 402 / R. Teori B.204',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x33D98BAE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x33D98BAE)),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 6. Catatan Ujian (Tata Tertib / Materi)
            Text('Catatan / Syarat Ujian', style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Contoh: Bawa kartu ujian & kalkulator saintifik...',
                filled: true,
                fillColor: AppColors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x33D98BAE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0x33D98BAE)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Simpan
            PastelButton(
              text: 'Simpan Jadwal $_selectedType 🌸',
              width: double.infinity,
              trailingIcon: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
              onPressed: _saveEvent,
            ),
          ],
        ),
      ),
    );
  }
}

