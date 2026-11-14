import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/schedule_model.dart';

/// Modal Bottom Sheet Tambah & Edit Jadwal Kuliah
class AddScheduleSheet extends StatefulWidget {
  final Function(ScheduleModel) onSave;
  final ScheduleModel? initialSchedule;

  const AddScheduleSheet({
    super.key,
    required this.onSave,
    this.initialSchedule,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(ScheduleModel) onSave,
    ScheduleModel? initialSchedule,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddScheduleSheet(
        onSave: onSave,
        initialSchedule: initialSchedule,
      ),
    );
  }

  @override
  State<AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends State<AddScheduleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _courseNameController = TextEditingController();
  final _courseCodeController = TextEditingController();
  final _roomController = TextEditingController();
  final _lecturerController = TextEditingController();

  int _selectedDay = 0; // 0 = Senin
  int _selectedSks = 3;
  String _selectedCategory = 'Praktikum';
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 10, minute: 30);

  final List<String> _categories = ['Praktikum', 'Teori', 'Kuliah Inti', 'Seminar'];

  @override
  void initState() {
    super.initState();
    if (widget.initialSchedule != null) {
      final s = widget.initialSchedule!;
      _courseNameController.text = s.courseName;
      _courseCodeController.text = s.courseCode;
      _roomController.text = s.room;
      _lecturerController.text = s.lecturer;
      _selectedDay = s.dayOfWeek;
      _selectedSks = s.sks;
      _selectedCategory = s.category;

      final startParts = s.startTime.split(':');
      if (startParts.length >= 2) {
        _startTime = TimeOfDay(
          hour: int.tryParse(startParts[0]) ?? 8,
          minute: int.tryParse(startParts[1]) ?? 0,
        );
      }
      final endParts = s.endTime.split(':');
      if (endParts.length >= 2) {
        _endTime = TimeOfDay(
          hour: int.tryParse(endParts[0]) ?? 10,
          minute: int.tryParse(endParts[1]) ?? 30,
        );
      }
    }
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isStart ? 'PILIH JAM MULAI KULIAH' : 'PILIH JAM SELESAI KULIAH',
      cancelText: 'BATAL',
      confirmText: 'PILIH',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.onSurface,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
          // Otomatis sesuaikan jam selesai minimal + (SKS x 50 menit) jika jam selesai mendahului jam mulai
          final startMinutes = picked.hour * 60 + picked.minute;
          final endMinutes = _endTime.hour * 60 + _endTime.minute;
          if (endMinutes <= startMinutes) {
            final newEndMinutes = (startMinutes + (_selectedSks * 50)).clamp(0, 1439);
            _endTime = TimeOfDay(hour: newEndMinutes ~/ 60, minute: newEndMinutes % 60);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final schedule = ScheduleModel(
        id: widget.initialSchedule?.id ?? DateTime.now().millisecondsSinceEpoch,
        dayOfWeek: _selectedDay,
        courseName: _courseNameController.text.trim(),
        courseCode: _courseCodeController.text.trim().isEmpty
            ? (widget.initialSchedule?.courseCode ?? 'IF3000')
            : _courseCodeController.text.trim(),
        sks: _selectedSks,
        room: _roomController.text.trim().isEmpty ? 'R. Kuliah' : _roomController.text.trim(),
        lecturer: _lecturerController.text.trim().isEmpty
            ? 'Dosen Pengampu'
            : _lecturerController.text.trim(),
        startTime:
            '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}',
        endTime:
            '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')}',
        category: _selectedCategory,
        accentColorHex: widget.initialSchedule?.accentColorHex ?? '#805063',
      );

      widget.onSave(schedule);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialSchedule != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? '✏️ Edit Jadwal Kuliah' : '+ Tambah Jadwal Kuliah',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Nama Mata Kuliah
              Text('Nama Mata Kuliah', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _courseNameController,
                decoration: const InputDecoration(hintText: 'Contoh: Interaksi Manusia & Komputer'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Wajib diisi yaa' : null,
              ),
              const SizedBox(height: 12),

              // Hari & SKS
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hari Kuliah', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedDay,
                          decoration: const InputDecoration(),
                          items: List.generate(AppConstants.daysOfWeek.length, (idx) {
                            return DropdownMenuItem(
                              value: idx,
                              child: Text(AppConstants.daysOfWeek[idx]),
                            );
                          }),
                          onChanged: (val) => setState(() => _selectedDay = val ?? 0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Beban SKS', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          initialValue: _selectedSks,
                          decoration: const InputDecoration(),
                          items: [1, 2, 3, 4, 6].map((sks) {
                            return DropdownMenuItem(
                              value: sks,
                              child: Text('$sks SKS'),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedSks = val ?? 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Waktu Kuliah (Jam Mulai - Jam Selesai)
              Text('Waktu Kuliah (Jam Mulai & Selesai)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Jam Mulai
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(isStart: true),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.schedule_rounded, size: 16, color: AppColors.primary),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam Mulai',
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')} WIB',
                                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.onSurfaceVariant),
                  ),
                  // Jam Selesai
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickTime(isStart: false),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.6)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.alarm_off_rounded, size: 16, color: AppColors.secondary),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Jam Selesai',
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 10,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '${_endTime.hour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')} WIB',
                                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ruangan & Kategori
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kode Ruangan', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _roomController,
                          decoration: const InputDecoration(hintText: 'Lab 402'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kategori Kelas', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(),
                          items: _categories.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val ?? 'Praktikum'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Dosen Pengampu
              Text('Dosen Pengampu', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _lecturerController,
                decoration: const InputDecoration(hintText: 'Contoh: Dr. Sarah Amanda, M.Ds.'),
              ),
              const SizedBox(height: 18),

              // Submit Button
              PastelButton(
                text: isEditing ? 'Simpan Perubahan 🌸' : 'Simpan ke Jadwal 🌸',
                width: double.infinity,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
