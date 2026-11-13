import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/transaction_model.dart';

/// Modal Bottom Sheet untuk mencatat Pengeluaran / Pemasukan Mahasiswa
class AddTransactionSheet extends StatefulWidget {
  final Function(TransactionModel) onSave;
  final bool initialIsExpense;

  const AddTransactionSheet({
    super.key,
    required this.onSave,
    this.initialIsExpense = true,
  });

  static Future<void> show(
    BuildContext context, {
    required Function(TransactionModel) onSave,
    bool initialIsExpense = true,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(
        onSave: onSave,
        initialIsExpense: initialIsExpense,
      ),
    );
  }

  @override
  State<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  late bool _isExpense;
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late String _selectedCategory;

  final List<Map<String, String>> _expenseCategories = [
    {'name': 'Makan & Minum', 'emoji': '🍜'},
    {'name': 'Print & Fotokopi', 'emoji': '🖨️'},
    {'name': 'Kas Kelas & Ormawa', 'emoji': '💸'},
    {'name': 'Kos & Utilitas', 'emoji': '🏠'},
    {'name': 'UKT & Pendidikan', 'emoji': '🎓'},
    {'name': 'Transportasi', 'emoji': '🛵'},
    {'name': 'Nongkrong & Hiburan', 'emoji': '☕'},
    {'name': 'Lainnya', 'emoji': '🛍️'},
  ];

  final List<Map<String, String>> _incomeCategories = [
    {'name': 'Uang Saku / Beasiswa', 'emoji': '💰'},
    {'name': 'Gaji Part-time / Magang', 'emoji': '💼'},
    {'name': 'Lainnya', 'emoji': '💵'},
  ];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _selectedCategory = _isExpense ? 'Makan & Minum' : 'Uang Saku / Beasiswa';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addAmountPreset(int add) {
    final current = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final total = current + add;
    _amountController.text = total.toString();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
        _selectedDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final cleanAmount = _amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final amount = double.tryParse(cleanAmount) ?? 0;

      final tx = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: _titleController.text.trim(),
        amount: amount,
        isExpense: _isExpense,
        category: _selectedCategory,
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      widget.onSave(tx);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _isExpense ? _expenseCategories : _incomeCategories;

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
              // Grab Handle
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

              // Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isExpense ? 'Catat Pengeluaran 💸' : 'Catat Pemasukan 💰',
                    style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Toggle Tab Pengeluaran vs Pemasukan
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpense = true;
                            _selectedCategory = 'Makan & Minum';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isExpense ? AppColors.errorContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '💸 Pengeluaran',
                              style: AppTypography.labelMd.copyWith(
                                color: _isExpense ? AppColors.onErrorContainer : AppColors.onSurfaceVariant,
                                fontWeight: _isExpense ? FontWeight.bold : FontWeight.normal,
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
                            _isExpense = false;
                            _selectedCategory = 'Uang Saku / Beasiswa';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isExpense ? AppColors.secondaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              '💰 Pemasukan',
                              style: AppTypography.labelMd.copyWith(
                                color: !_isExpense ? AppColors.onSecondaryContainer : AppColors.onSurfaceVariant,
                                fontWeight: !_isExpense ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nominal Input
              Text('Nominal (Rp)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: AppTypography.headlineSm.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _isExpense ? AppColors.error : AppColors.secondary,
                ),
                decoration: InputDecoration(
                  prefixText: 'Rp ',
                  prefixStyle: AppTypography.headlineSm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _isExpense ? AppColors.error : AppColors.secondary,
                  ),
                  hintText: '0',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nominal wajib diisi';
                  final num = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), ''));
                  if (num == null || num <= 0) return 'Nominal harus lebih dari 0';
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Quick Presets (+10rb, +20rb, +50rb, +100rb)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPresetChip('+10.000', 10000),
                    const SizedBox(width: 6),
                    _buildPresetChip('+20.000', 20000),
                    const SizedBox(width: 6),
                    _buildPresetChip('+50.000', 50000),
                    const SizedBox(width: 6),
                    _buildPresetChip('+100.000', 100000),
                    const SizedBox(width: 6),
                    _buildPresetChip('+500.000', 500000),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Judul / Keperluan
              Text('Keperluan / Keterangan', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: _isExpense
                      ? 'Contoh: Nasi Soto Ayam Kantin Fasilkom'
                      : 'Contoh: Transfer Uang Saku Bulanan',
                ),
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Keperluan wajib diisi' : null,
              ),
              const SizedBox(height: 14),

              // Kategori Chip Selector
              Text('Kategori', style: AppTypography.labelMd),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat['name'];
                  return ChoiceChip(
                    label: Text('${cat['emoji']} ${cat['name']}'),
                    selected: isSelected,
                    selectedColor: _isExpense ? AppColors.primaryContainer : AppColors.secondaryContainer,
                    backgroundColor: AppColors.surfaceContainerLow,
                    labelStyle: AppTypography.labelSm.copyWith(
                      color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : const Color(0x33F4DCE4),
                      ),
                    ),
                    showCheckmark: false,
                    onSelected: (val) {
                      if (val) {
                        setState(() {
                          _selectedCategory = cat['name']!;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Tanggal Transaksi
              Text('Tanggal', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickDate,
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
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd MMMM yyyy').format(_selectedDate),
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

              // Catatan Opsional
              Text('Catatan Tambahan (Opsional)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Tulis rincian atau catatan pengingat...',
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              PastelButton(
                text: _isExpense ? 'Simpan Pengeluaran 💸' : 'Simpan Pemasukan 💰',
                width: double.infinity,
                type: _isExpense ? PastelButtonType.primary : PastelButtonType.secondary,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String label, int amount) {
    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelSm.copyWith(
        fontSize: 10.5,
        color: AppColors.onSurfaceVariant,
      ),
      backgroundColor: AppColors.surfaceContainerLow,
      side: const BorderSide(color: Color(0x33F4DCE4)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: EdgeInsets.zero,
      onPressed: () => _addAmountPreset(amount),
    );
  }
}
