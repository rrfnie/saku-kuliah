/// Model Transaksi Keuangan Mahasiswa SakuKuliah (100% Offline)
class TransactionModel {
  final int? id;
  final String title;
  final double amount;
  final bool isExpense;
  final String category;
  final String date;
  final String? notes;

  TransactionModel({
    this.id,
    required this.title,
    required this.amount,
    required this.isExpense,
    required this.category,
    required this.date,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'is_expense': isExpense ? 1 : 0,
      'category': category,
      'date': date,
      'notes': notes,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      isExpense: map['is_expense'] == 1 || map['is_expense'] == true,
      category: map['category'] as String,
      date: map['date'] as String,
      notes: map['notes'] as String?,
    );
  }

  TransactionModel copyWith({
    int? id,
    String? title,
    double? amount,
    bool? isExpense,
    String? category,
    String? date,
    String? notes,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isExpense: isExpense ?? this.isExpense,
      category: category ?? this.category,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  /// Helper untuk mendapatkan emoji sesuai kategori pengeluaran/pemasukan
  String get categoryEmoji {
    switch (category) {
      case 'Makan & Minum':
        return '🍜';
      case 'Print & Fotokopi':
        return '🖨️';
      case 'Kas Kelas & Ormawa':
        return '💸';
      case 'Kos & Utilitas':
        return '🏠';
      case 'UKT & Pendidikan':
        return '🎓';
      case 'Transportasi':
        return '🛵';
      case 'Nongkrong & Hiburan':
        return '☕';
      case 'Uang Saku / Beasiswa':
        return '💰';
      case 'Gaji Part-time / Magang':
        return '💼';
      default:
        return isExpense ? '🛍️' : '💵';
    }
  }
}

