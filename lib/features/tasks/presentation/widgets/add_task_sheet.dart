import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/task_model.dart';

/// Modal Bottom Sheet Tambah Tugas & Deadline Baru
class AddTaskSheet extends StatefulWidget {
  final Function(TaskModel) onSave;

  const AddTaskSheet({super.key, required this.onSave});

  static Future<void> show(BuildContext context, {required Function(TaskModel) onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(onSave: onSave),
    );
  }

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _attachmentController = TextEditingController();
  final _subtaskController = TextEditingController();

  String _priority = 'Tinggi';
  String _assignmentType = 'Individu';
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 23, minute: 59);
  final List<String> _tempSubtasks = [];

  final List<String> _priorities = ['Tinggi', 'Sedang', 'Rendah'];
  final List<String> _assignmentTypes = ['Individu', 'Kelompok'];

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _attachmentController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _tempSubtasks.add(text);
        _subtaskController.clear();
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final subtasks = List.generate(_tempSubtasks.length, (idx) {
        return SubtaskModel(
          id: idx + 1,
          title: _tempSubtasks[idx],
          isCompleted: false,
        );
      });

      final task = TaskModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text.trim(),
        courseName: _courseController.text.trim().isEmpty
            ? 'Tugas Kuliah'
            : _courseController.text.trim(),
        dueDate: '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
        dueTime:
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')} WIB',
        priority: _priority,
        attachmentInfo: _attachmentController.text.trim().isEmpty
            ? 'Format Bebas'
            : _attachmentController.text.trim(),
        assignmentType: _assignmentType,
        isCompleted: false,
        createdAt: DateTime.now().toIso8601String(),
        subtasks: subtasks,
      );

      widget.onSave(task);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    '+ Tambah Tugas & Deadline',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Judul Tugas
              Text('Judul Tugas', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Contoh: Laporan Evaluasi Heuristik'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Judul tugas wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Nama Mata Kuliah & Format Tugas
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mata Kuliah', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _courseController,
                          decoration: const InputDecoration(hintText: 'UI/UX Design'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Format / Berkas', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _attachmentController,
                          decoration: const InputDecoration(hintText: 'PDF Max 15MB'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Prioritas & Tipe Pengerjaan
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tingkat Prioritas', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _priority,
                          decoration: const InputDecoration(),
                          items: _priorities.map((p) {
                            return DropdownMenuItem(value: p, child: Text(p));
                          }).toList(),
                          onChanged: (val) => setState(() => _priority = val ?? 'Tinggi'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tipe Pengerjaan', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _assignmentType,
                          decoration: const InputDecoration(),
                          items: _assignmentTypes.map((t) {
                            return DropdownMenuItem(value: t, child: Text(t));
                          }).toList(),
                          onChanged: (val) => setState(() => _assignmentType = val ?? 'Individu'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Subtugas Checklist (Optional)
              Text('Checklist Subtugas (Opsional)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _subtaskController,
                      decoration: const InputDecoration(hintText: 'Tambah tahapan pengerjaan...'),
                      onFieldSubmitted: (_) => _addSubtask(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _addSubtask,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: AppColors.onPrimaryContainer,
                    ),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              if (_tempSubtasks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(_tempSubtasks.length, (idx) {
                    return Chip(
                      label: Text(_tempSubtasks[idx], style: const TextStyle(fontSize: 11)),
                      backgroundColor: AppColors.surfaceContainerLow,
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() {
                          _tempSubtasks.removeAt(idx);
                        });
                      },
                    );
                  }),
                ),
              ],
              const SizedBox(height: 20),

              // Submit Button
              PastelButton(
                text: 'Simpan Tugas',
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

