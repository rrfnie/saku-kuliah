import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/schedule_model.dart';

/// Modal Bottom Sheet Tambah Jadwal Kuliah Baru
class AddScheduleSheet extends StatefulWidget {
  final Function(ScheduleModel) onSave;

  const AddScheduleSheet({super.key, required this.onSave});

  static Future<void> show(BuildContext context, {required Function(ScheduleModel) onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddScheduleSheet(onSave: onSave),
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
  void dispose() {
    _courseNameController.dispose();
    _courseCodeController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final schedule = ScheduleModel(
        id: DateTime.now().millisecondsSinceEpoch,
        dayOfWeek: _selectedDay,
        courseName: _courseNameController.text.trim(),
        courseCode: _courseCodeController.text.trim().isEmpty
            ? 'IF3000'
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
        accentColorHex: '#805063',
      );

      widget.onSave(schedule);
      Navigator.pop(context);
    }
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
                    '+ Tambah Jadwal Kuliah',
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
                          value: _selectedDay,
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
                          value: _selectedSks,
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

              // Ruangan & Dosen
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
                          value: _selectedCategory,
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
                text: 'Simpan ke Jadwal',
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

