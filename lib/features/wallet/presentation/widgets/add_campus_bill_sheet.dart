import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/campus_bill_model.dart';

/// Modal Bottom Sheet Tambah Tagihan Kampus & Uang Kas Kelas
class AddCampusBillSheet extends StatefulWidget {
  final Function(CampusBillModel) onSave;

  const AddCampusBillSheet({super.key, required this.onSave});

  static Future<void> show(BuildContext context, {required Function(CampusBillModel) onSave}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCampusBillSheet(onSave: onSave),
    );
  }

  @override
  State<AddCampusBillSheet> createState() => _AddCampusBillSheetState();
}

class _AddCampusBillSheetState extends State<AddCampusBillSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _dueDate = DateTime.now().add(const Duration(days: 7));
  String _selectedCategory = 'Kas Kelas & Ormawa';

  final List<String> _categories = [
    'UKT & Pendidikan',
    'Kas Kelas & Ormawa',
    'Print & Fotokopi',
    'Buku & Alat Praktikum',
    'Lainnya',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
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
        _dueDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cleanAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = double.tryParse(cleanAmount) ?? 0;

      final bill = CampusBillModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text.trim(),
        amount: amount,
        dueDate: DateFormat('yyyy-MM-dd').format(_dueDate),
        category: _selectedCategory,
        note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
      );

      widget.onSave(bill);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
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
              // Handle
              Center(
                child: Container(
                  width: 44,
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
                    '+ Tagihan Kampus Baru 🏛️',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Judul Tagihan
              Text('Nama Tagihan / Iuran', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: UKT Semester Ganjil / Uang Kas Kelas',
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama tagihan wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Nominal
              Text('Nominal Tagihan (Rp)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: 'Rp ',
                  hintText: '0',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nominal wajib diisi';
                  final num = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
                  if (num == null || num <= 0) return 'Nominal harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Kategori Tagihan
              Text('Kategori Tagihan', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0x33F4DCE4)),
                  ),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCategory = val);
                  }
                },
              ),
              const SizedBox(height: 14),

              // Tanggal Jatuh Tempo
              Text('Jatuh Tempo Pembayaran', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x33F4DCE4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.alarm_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_dueDate),
                            style: AppTypography.bodyMd,
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: AppColors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Catatan
              Text('Catatan / Nomor Rekening / VA (Opsional)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Bayar via VA Mandiri: 887081234567',
                ),
              ),
              const SizedBox(height: 20),

              PastelButton(
                text: 'Simpan Tagihan 🌸',
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

