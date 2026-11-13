/// Model Tagihan Kampus (UKT, Uang Kas Kelas, Buku, Iuran)
class CampusBillModel {
  final int? id;
  final String title;
  final double amount;
  final String dueDate;
  final bool isPaid;
  final String category;
  final String? note;

  CampusBillModel({
    this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.category,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'due_date': dueDate,
      'is_paid': isPaid ? 1 : 0,
      'category': category,
      'note': note,
    };
  }

  factory CampusBillModel.fromMap(Map<String, dynamic> map) {
    return CampusBillModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      dueDate: map['due_date'] as String,
      isPaid: map['is_paid'] == 1 || map['is_paid'] == true,
      category: map['category'] as String,
      note: map['note'] as String?,
    );
  }

  CampusBillModel copyWith({
    int? id,
    String? title,
    double? amount,
    String? dueDate,
    bool? isPaid,
    String? category,
    String? note,
  }) {
    return CampusBillModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      category: category ?? this.category,
      note: note ?? this.note,
    );
  }
}

