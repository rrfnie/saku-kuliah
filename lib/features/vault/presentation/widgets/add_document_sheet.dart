import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/student_document_model.dart';

class AddDocumentSheet extends StatefulWidget {
  final StudentDocumentModel? documentToEdit;

  const AddDocumentSheet({super.key, this.documentToEdit});

  static Future<void> show(BuildContext context, {StudentDocumentModel? documentToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddDocumentSheet(documentToEdit: documentToEdit),
    );
  }

  @override
  State<AddDocumentSheet> createState() => _AddDocumentSheetState();
}

class _AddDocumentSheetState extends State<AddDocumentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _docNumberController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Identitas';
  String _fileName = '';
  String _fileType = 'pdf';
  String _fileSize = '';
  String? _base64Data;
  bool _isFavorite = false;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Identitas', 'icon': Icons.badge_rounded, 'color': Color(0xFF6B5A60)},
    {'name': 'Akademik', 'icon': Icons.school_rounded, 'color': Color(0xFF805063)},
    {'name': 'Keuangan', 'icon': Icons.account_balance_wallet_rounded, 'color': Color(0xFF880E4F)},
    {'name': 'Sertifikat', 'icon': Icons.workspace_premium_rounded, 'color': Color(0xFFD87D4A)},
    {'name': 'Skripsi / Riset', 'icon': Icons.menu_book_rounded, 'color': Color(0xFF2E7D32)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.documentToEdit != null) {
      final d = widget.documentToEdit!;
      _titleController.text = d.title;
      _docNumberController.text = d.documentNumber ?? '';
      _notesController.text = d.notes ?? '';
      _selectedCategory = d.category;
      _fileName = d.fileName;
      _fileType = d.fileType;
      _fileSize = d.fileSize;
      _base64Data = d.base64Data;
      _isFavorite = d.isFavorite;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _docNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );

      if (result.isNotEmpty) {
        final file = result.first;
        final name = file.name;
        final ext = name.split('.').last.toLowerCase();
        final type = (ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'webp') ? 'image' : 'pdf';
        
        // Baca file bytes
        final bytes = await file.xFile.readAsBytes();
        final sizeKb = (bytes.lengthInBytes / 1024).round();
        final sizeStr = sizeKb > 1024 
            ? '${(sizeKb / 1024).toStringAsFixed(1)} MB' 
            : '$sizeKb KB';

        setState(() {
          _fileName = name;
          _fileType = type;
          _fileSize = sizeStr;
          // Simpan base64 agar aman tersimpan lokal & bisa dibuka/diunduh kembali
          _base64Data = base64Encode(bytes);
          
          if (_titleController.text.trim().isEmpty) {
            // Auto-fill nama dokumen dari nama file yang dibersihkan
            final cleanName = name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '').replaceAll('_', ' ');
            _titleController.text = cleanName;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text('Gagal memilih file: $e'),
          ),
        );
      }
    }
  }

  void _saveDocument() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final docNumber = _docNumberController.text.trim().isNotEmpty ? _docNumberController.text.trim() : null;
    final notes = _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null;
    final now = DateTime.now();
    final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final doc = StudentDocumentModel(
      id: widget.documentToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: _selectedCategory,
      documentNumber: docNumber,
      fileName: _fileName.isNotEmpty ? _fileName : '$title.${_fileType == 'image' ? 'jpg' : 'pdf'}',
      fileType: _fileType,
      fileSize: _fileSize.isNotEmpty ? _fileSize : 'Lokal',
      base64Data: _base64Data,
      dateAdded: widget.documentToEdit?.dateAdded ?? dateStr,
      notes: notes,
      isFavorite: _isFavorite,
    );

    final appState = SakuKuliahState.instance;
    if (widget.documentToEdit != null) {
      appState.updateDocument(doc);
    } else {
      appState.addDocument(doc);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: Text(
          widget.documentToEdit != null
              ? 'Dokumen "$title" berhasil diperbarui! 🌸✨'
              : 'Dokumen "$title" aman tersimpan di Brankas! 🗄️💖',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 24 + bottomInset,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Drag Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.folder_special_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.documentToEdit != null ? 'Edit Dokumen' : 'Simpan Dokumen ke Brankas 🗄️',
                          style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '100% Offline & tersimpan aman di memori perangkatmu',
                          style: AppTypography.bodySm.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // File Picker Box
              InkWell(
                onTap: _pickFile,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _fileName.isNotEmpty
                        ? AppColors.primaryContainer.withValues(alpha: 0.25)
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _fileName.isNotEmpty
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : const Color(0x33F4DCE4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _fileName.isNotEmpty
                              ? AppColors.primaryContainer
                              : AppColors.surfaceContainerLowest,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _fileName.isNotEmpty
                              ? (_fileType == 'image' ? Icons.image_rounded : Icons.picture_as_pdf_rounded)
                              : Icons.file_upload_outlined,
                          color: _fileName.isNotEmpty ? AppColors.primary : AppColors.onSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName.isNotEmpty ? _fileName : 'Pilih Berkas PDF / Foto Dokumen',
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _fileName.isNotEmpty ? AppColors.primary : AppColors.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _fileName.isNotEmpty
                                  ? 'Format: ${_fileType.toUpperCase()} • Ukuran: $_fileSize (Siap Disimpan)'
                                  : 'Mendukung PDF, JPG, PNG (KTP, KTM, Transkrip, Sertifikat)',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0x22F4DCE4)),
                        ),
                        child: Text(
                          _fileName.isNotEmpty ? 'Ganti' : 'Pilih File',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title Field
              Text(
                'Nama / Judul Dokumen *',
                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Contoh: KTP Elektronik, Transkrip Semester 5, Sertifikat TOEFL',
                  hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  prefixIcon: const Icon(Icons.description_outlined, size: 20, color: AppColors.primary),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama dokumen wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              Text(
                'Kategori Dokumen *',
                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat['name'];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['name'] as String;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : const Color(0x22F4DCE4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            cat['icon'] as IconData,
                            size: 15,
                            color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat['name'] as String,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Document Number (Optional, Quick Copy)
              Row(
                children: [
                  Text(
                    'Nomor Dokumen / NIK / NIM / No. Registrasi',
                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(Opsional)',
                    style: AppTypography.bodySm.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _docNumberController,
                decoration: InputDecoration(
                  hintText: 'Contoh: 3201234567890001 atau REG-2026/TOEFL/889',
                  hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  prefixIcon: const Icon(Icons.pin_outlined, size: 20, color: AppColors.secondary),
                  helperText: 'Bisa langsung kamu salin (copy) dalam 1-klik saat isi form kampus!',
                  helperStyle: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Field
              Text(
                'Catatan / Keterangan Tambahan',
                style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Contoh: Skor TOEFL 550, berlaku sampai Nov 2028, atau simpanan asli di ordner lemari',
                  hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.6)),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  prefixIcon: const Icon(Icons.notes_rounded, size: 20, color: AppColors.onSurfaceVariant),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              PastelButton(
                text: widget.documentToEdit != null ? 'Perbarui Dokumen 🌸' : 'Simpan ke Brankas Dokumen 🗄️✨',
                width: double.infinity,
                onPressed: _saveDocument,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
