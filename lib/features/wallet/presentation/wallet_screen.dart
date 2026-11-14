import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/fade_slide_entry.dart';
import '../../../core/widgets/pastel_card.dart';
import '../models/campus_bill_model.dart';
import '../models/transaction_model.dart';
import 'widgets/add_campus_bill_sheet.dart';
import 'widgets/add_transaction_sheet.dart';
import 'widgets/set_budget_dialog.dart';

/// Halaman Dompet Pastel Mahasiswa (Saku Keuangan 100% Offline)
/// Mengatur uang saku, batas jajan harian aman, tagihan UKT & kas kelas.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

  final List<String> _filters = [
    'Semua',
    'Makan & Minum',
    'Print & Fotokopi',
    'Kas Kelas & Ormawa',
    'Nongkrong & Hiburan',
    'UKT & Pendidikan',
    'Uang Saku / Beasiswa',
  ];

  String _formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  void _openAddTransaction({bool isExpense = true}) {
    AddTransactionSheet.show(
      context,
      initialIsExpense: isExpense,
      onSave: (tx) {
        _appState.addTransaction(tx);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isExpense ? AppColors.primary : AppColors.secondary,
            content: Text(
              isExpense
                  ? 'Pengeluaran "${tx.title}" berhasil dicatat! 💸'
                  : 'Pemasukan "${tx.title}" berhasil ditambahkan! 💰🌸',
            ),
          ),
        );
      },
    );
  }

  void _openAddCampusBill() {
    AddCampusBillSheet.show(
      context,
      onSave: (bill) {
        _appState.addCampusBill(bill);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            content: Text('Tagihan "${bill.title}" berhasil disimpan! 🏛️🌸'),
          ),
        );
      },
    );
  }

  void _openSetBudget() {
    SetBudgetDialog.show(
      context,
      currentBudget: _appState.monthlyBudget,
      onSave: (newBudget) {
        _appState.updateMonthlyBudget(newBudget);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Target anggaran bulanan berhasil diperbarui! 🌸✨')),
        );
      },
    );
  }

  void _confirmDeleteTransaction(TransactionModel tx) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                'Hapus Transaksi?',
                style: AppTypography.headlineSm.copyWith(fontSize: 16),
              ),
            ],
          ),
          content: Text(
            'Hapus catatan transaksi "${tx.title}" (${_formatRupiah(tx.amount)})?',
            style: AppTypography.bodyMd,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (tx.id != null) {
                  _appState.deleteTransaction(tx.id!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaksi berhasil dihapus 🗑️')),
                );
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteBill(CampusBillModel bill) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Hapus Tagihan?', style: AppTypography.headlineSm.copyWith(fontSize: 16)),
          content: Text('Hapus pengingat tagihan "${bill.title}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx);
                if (bill.id != null) {
                  _appState.deleteCampusBill(bill.id!);
                }
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final totalBalance = _appState.totalBalance;
        final totalIncome = _appState.totalIncomeThisMonth;
        final totalExpense = _appState.totalExpenseThisMonth;
        final safeDaily = _appState.safeToSpendDaily;
        final monthlyBudget = _appState.monthlyBudget;
        final bills = _appState.campusBills;
        final allTx = _appState.transactions;

        // Filter transactions
        final filteredByCat = _selectedFilterIndex == 0
            ? allTx
            : allTx.where((t) => t.category == _filters[_selectedFilterIndex]).toList();

        final transactions = _searchQuery.isEmpty
            ? filteredByCat
            : filteredByCat.where((t) {
                return t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    t.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (t.notes != null && t.notes!.toLowerCase().contains(_searchQuery.toLowerCase()));
              }).toList();

        final budgetRatio = monthlyBudget > 0 ? (totalExpense / monthlyBudget).clamp(0.0, 1.0) : 0.0;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Dompet Pastel Mahasiswa 👛'),
            actions: [
              IconButton(
                tooltip: 'Tambah Tagihan Kampus',
                icon: Icon(Icons.receipt_long_rounded, color: AppColors.primary),
                onPressed: _openAddCampusBill,
              ),
              IconButton(
                tooltip: 'Atur Anggaran Bulanan',
                icon: Icon(Icons.tune_rounded, color: AppColors.primary),
                onPressed: _openSetBudget,
              ),
            ],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Kartu Saldo & Ringkasan Bulan Ini
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 60),
                    child: _buildMainBalanceCard(totalBalance, totalIncome, totalExpense),
                  ),
                  const SizedBox(height: 18),

                  // 2. Kartu Jatah Jajan Harian Aman (Safe-to-Spend)
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 120),
                    child: _buildSafeToSpendCard(safeDaily, totalExpense, monthlyBudget, budgetRatio),
                  ),
                  const SizedBox(height: 20),

                  // 3. Section Tagihan Kampus & Uang Kas
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 180),
                    child: _buildCampusBillsSection(bills),
                  ),
                  const SizedBox(height: 22),

                  // 4. Section Riwayat Transaksi
                  FadeSlideEntry(
                    delay: const Duration(milliseconds: 240),
                    child: _buildTransactionListSection(transactions),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainBalanceCard(double balance, double income, double expense) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceContainerLowest,
            AppColors.primaryContainer.withValues(alpha: 0.45),
            AppColors.secondaryContainer.withValues(alpha: 0.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, size: 18, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Saldo Saku Saat Ini',
                    style: AppTypography.labelMd.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '100% Offline 🌸',
                  style: AppTypography.labelSm.copyWith(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nominal Saldo
          Text(
            _formatRupiah(balance),
            style: AppTypography.headlineLg.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: balance >= 0 ? AppColors.onSurface : AppColors.error,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),

          // Pemasukan vs Pengeluaran Bulan Ini
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.onSecondaryContainer),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pemasukan Bln Ini',
                              style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              _formatRupiah(income),
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                                fontSize: 12.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 28, width: 1, color: AppColors.cardBorder),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pengeluaran Bln Ini',
                              style: AppTypography.labelSm.copyWith(fontSize: 10, color: AppColors.onSurfaceVariant),
                            ),
                            Text(
                              _formatRupiah(expense),
                              style: AppTypography.labelMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                fontSize: 12.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tombol Tindakan Cepat (Pengeluaran & Pemasukan)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 17),
                  label: Text(
                    '+ Pengeluaran',
                    style: AppTypography.labelMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _openAddTransaction(isExpense: true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppColors.cardBorder),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(Icons.add_circle_outline_rounded, size: 17, color: AppColors.secondary),
                  label: Text(
                    '+ Pemasukan',
                    style: AppTypography.labelMd.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _openAddTransaction(isExpense: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafeToSpendCard(double safeDaily, double expense, double budget, double ratio) {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final remainingDays = (daysInMonth - now.day + 1).clamp(1, 31);

    return PastelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.insights_rounded, size: 16, color: AppColors.onTertiaryContainer),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jatah Jajan Harian Aman',
                    style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _openSetBudget,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 11, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Atur Budget',
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Safe daily amount
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatRupiah(safeDaily),
                style: AppTypography.headlineSm.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '/ hari',
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Batas aman jajan kamu agar uang saku cukup sampai akhir bulan ($remainingDays hari tersisa) 🌸',
            style: AppTypography.bodySm.copyWith(fontSize: 11.5, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 7,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: AlwaysStoppedAnimation<Color>(
                ratio > 0.85 ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai ${_formatRupiah(expense)}',
                style: AppTypography.labelSm.copyWith(fontSize: 10.5, color: AppColors.onSurfaceVariant),
              ),
              Text(
                'Budget ${_formatRupiah(budget)}',
                style: AppTypography.labelSm.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCampusBillsSection(List<CampusBillModel> bills) {
    final pendingCount = bills.where((b) => !b.isPaid).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Tagihan Kampus & Kas Kelas',
                  style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                if (pendingCount > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      '$pendingCount Belum Lunas',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                GestureDetector(
                  onTap: _openAddCampusBill,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 12, color: AppColors.onSecondaryContainer),
                        const SizedBox(width: 3),
                        Text(
                          'Tagihan',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (bills.isEmpty)
          PastelCard(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Tidak ada tagihan kampus aktif 🎉',
                style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              ),
            ),
          )
        else
          ...bills.map((bill) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PastelCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    // Checkbox status bayar
                    Checkbox(
                      value: bill.isPaid,
                      activeColor: AppColors.secondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      onChanged: (val) {
                        if (bill.id != null) {
                          _appState.toggleBillPaid(bill.id!);
                        }
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  bill.title,
                                  style: AppTypography.labelMd.copyWith(
                                    fontWeight: FontWeight.bold,
                                    decoration: bill.isPaid ? TextDecoration.lineThrough : null,
                                    color: bill.isPaid ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: bill.isPaid
                                      ? AppColors.secondaryContainer
                                      : AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(9999),
                                ),
                                child: Text(
                                  bill.isPaid ? 'Lunas ✅' : 'Jatuh Tempo: ${bill.dueDate}',
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: bill.isPaid
                                        ? AppColors.onSecondaryContainer
                                        : AppColors.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bill.note ?? bill.category,
                            style: AppTypography.bodySm.copyWith(fontSize: 10.5, color: AppColors.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatRupiah(bill.amount),
                      style: AppTypography.labelMd.copyWith(
                        fontWeight: FontWeight.bold,
                        color: bill.isPaid ? AppColors.onSurfaceVariant : AppColors.primary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 16, color: AppColors.outline),
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _confirmDeleteBill(bill),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildTransactionListSection(List<TransactionModel> txList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Riwayat Transaksi Mahasiswa',
                  style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              '${txList.length} transaksi',
              style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Search Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppColors.cardShadow,
          ),
          child: TextField(
            onChanged: (val) {
              setState(() => _searchQuery = val.trim());
            },
            decoration: InputDecoration(
              hintText: 'Cari transaksi soto, print, kas, kos...',
              hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: AppColors.outline),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_filters.length, (index) {
              final isSelected = _selectedFilterIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceContainerLow,
                  labelStyle: AppTypography.labelSm.copyWith(
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                    ),
                  ),
                  showCheckmark: false,
                  onSelected: (val) {
                    if (val) {
                      setState(() => _selectedFilterIndex = index);
                    }
                  },
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),

        if (txList.isEmpty)
          PastelCard(
            padding: const EdgeInsets.all(28),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_rounded, size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada catatan transaksi 🌸',
                    style: AppTypography.headlineSm.copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tekan tombol + Pengeluaran atau + Pemasukan untuk mencatat.',
                    style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          ...txList.map((tx) {
            final isExpense = tx.isExpense;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PastelCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Category Emoji Container
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isExpense
                            ? AppColors.errorContainer.withValues(alpha: 0.5)
                            : AppColors.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          tx.categoryEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.title,
                            style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                tx.date,
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 10.5,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('•', style: TextStyle(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 10)),
                              const SizedBox(width: 6),
                              Text(
                                tx.category,
                                style: AppTypography.bodySm.copyWith(
                                  fontSize: 10.5,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Amount
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isExpense ? '-' : '+'} ${_formatRupiah(tx.amount)}',
                          style: AppTypography.labelMd.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isExpense ? AppColors.error : AppColors.secondary,
                            fontSize: 13,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline_rounded, size: 15, color: AppColors.outline),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                          onPressed: () => _confirmDeleteTransaction(tx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}
