import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/lecture_note_model.dart';

/// Modal Bottom Sheet Tambah & Edit Catatan Kuliah
class AddNoteSheet extends StatefulWidget {
  final Function(LectureNoteModel) onSave;
  final LectureNoteModel? noteToEdit;

  const AddNoteSheet({super.key, required this.onSave, this.noteToEdit});

  static Future<void> show(
    BuildContext context, {
    required Function(LectureNoteModel) onSave,
    LectureNoteModel? noteToEdit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddNoteSheet(onSave: onSave, noteToEdit: noteToEdit),
    );
  }

  @override
  State<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<AddNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPinned = false;

  @override
  void initState() {
    super.initState();
    if (widget.noteToEdit != null) {
      final n = widget.noteToEdit!;
      _titleController.text = n.title;
      _courseController.text = n.courseName;
      _contentController.text = n.content;
      _tagsController.text = n.tags ?? '';
      _isPinned = n.isPinned;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final now = DateTime.now();
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';
      final wordCount = _contentController.text.trim().split(RegExp(r'\s+')).length;
      final readMinutes = (wordCount / 80).ceil().clamp(1, 60);

      final note = LectureNoteModel(
        id: widget.noteToEdit?.id ?? DateTime.now().millisecondsSinceEpoch,
        courseName: _courseController.text.trim().isEmpty
            ? 'Catatan Umum'
            : _courseController.text.trim(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        createdDate: widget.noteToEdit?.createdDate ?? dateStr,
        isPinned: _isPinned,
        tags: _tagsController.text.trim().isEmpty ? null : _tagsController.text.trim(),
        attachmentName: widget.noteToEdit?.attachmentName,
        attachmentSize: widget.noteToEdit?.attachmentSize,
        readTime: '$readMinutes mnt baca',
      );

      widget.onSave(note);
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
                    widget.noteToEdit != null ? 'Edit Catatan Kuliah ✏️' : '+ Catatan Kuliah Baru 🌸',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Judul Catatan
              Text('Judul Catatan', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Contoh: Rangkuman Materi Pertemuan 5'),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Judul catatan wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Nama Mata Kuliah
              Text('Mata Kuliah', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(hintText: 'Contoh: Desain Antarmuka & UX'),
              ),
              const SizedBox(height: 12),

              // Isi Catatan
              Text('Isi Catatan Kuliah', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tulis ringkasan penjelasan dosen, rumus, poin penting...',
                  alignLabelWithHint: true,
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Isi catatan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 12),

              // Tags
              Text('Tagar / Kategori (Pisahkan dengan koma)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(hintText: '#UTS, #Penting, #Bab3'),
              ),
              const SizedBox(height: 12),

              // Switch Sematkan Catatan
              SwitchListTile(
                value: _isPinned,
                activeColor: AppColors.primary,
                contentPadding: EdgeInsets.zero,
                title: Text('Sematkan Catatan (Pin)', style: AppTypography.labelMd),
                subtitle: Text('Tampilkan di paling atas dashboard catatan', style: AppTypography.bodySm.copyWith(fontSize: 11)),
                onChanged: (val) => setState(() => _isPinned = val),
              ),
              const SizedBox(height: 16),

              // Submit Button
              PastelButton(
                text: widget.noteToEdit != null ? 'Perbarui Catatan 💾' : 'Simpan Catatan 🌸',
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

