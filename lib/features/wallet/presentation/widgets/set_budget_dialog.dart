import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Dialog untuk mengubah target anggaran uang saku bulanan
class SetBudgetDialog extends StatefulWidget {
  final double currentBudget;
  final Function(double) onSave;

  const SetBudgetDialog({
    super.key,
    required this.currentBudget,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required double currentBudget,
    required Function(double) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => SetBudgetDialog(
        currentBudget: currentBudget,
        onSave: onSave,
      ),
    );
  }

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentBudget.toInt().toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _preset(int val) {
    _controller.text = val.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.savings_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 10),
          Text(
            'Target Uang Saku Bulanan',
            style: AppTypography.headlineSm.copyWith(fontSize: 16),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Atur batas total uang saku per bulan untuk menghitung jatah jajan harian aman kamu secara otomatis 🌸',
            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              prefixText: 'Rp ',
              hintText: '1500000',
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip('1 Juta', 1000000),
                const SizedBox(width: 6),
                _buildChip('1.5 Juta', 1500000),
                const SizedBox(width: 6),
                _buildChip('2 Juta', 2000000),
                const SizedBox(width: 6),
                _buildChip('2.5 Juta', 2500000),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
          onPressed: () {
            final val = double.tryParse(_controller.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? widget.currentBudget;
            if (val > 0) {
              widget.onSave(val);
              Navigator.pop(context);
            }
          },
          child: const Text('Simpan Anggaran'),
        ),
      ],
    );
  }

  Widget _buildChip(String label, int val) {
    return ActionChip(
      label: Text(label),
      labelStyle: AppTypography.labelSm.copyWith(fontSize: 10.5),
      padding: EdgeInsets.zero,
      onPressed: () => _preset(val),
    );
  }
}

