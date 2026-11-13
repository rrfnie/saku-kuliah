class StudentDocumentModel {
  final String id;
  final String title;
  final String category; // 'Identitas', 'Akademik', 'Keuangan', 'Sertifikat', 'Skripsi / Riset'
  final String? documentNumber; // NIK, NIM, No. Registrasi, No. VA
  final String fileName;
  final String fileType; // 'pdf', 'image', 'other'
  final String fileSize;
  final String? base64Data; // Konten biner tersimpan lokal aman
  final String dateAdded;
  final String? notes;
  final bool isFavorite;

  const StudentDocumentModel({
    required this.id,
    required this.title,
    required this.category,
    this.documentNumber,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    this.base64Data,
    required this.dateAdded,
    this.notes,
    this.isFavorite = false,
  });

  StudentDocumentModel copyWith({
    String? id,
    String? title,
    String? category,
    String? documentNumber,
    String? fileName,
    String? fileType,
    String? fileSize,
    String? base64Data,
    String? dateAdded,
    String? notes,
    bool? isFavorite,
  }) {
    return StudentDocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      documentNumber: documentNumber ?? this.documentNumber,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      base64Data: base64Data ?? this.base64Data,
      dateAdded: dateAdded ?? this.dateAdded,
      notes: notes ?? this.notes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'documentNumber': documentNumber,
      'fileName': fileName,
      'fileType': fileType,
      'fileSize': fileSize,
      'base64Data': base64Data,
      'dateAdded': dateAdded,
      'notes': notes,
      'isFavorite': isFavorite,
    };
  }

  factory StudentDocumentModel.fromJson(Map<String, dynamic> json) {
    return StudentDocumentModel(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Dokumen Mahasiswa',
      category: json['category'] as String? ?? 'Identitas',
      documentNumber: json['documentNumber'] as String?,
      fileName: json['fileName'] as String? ?? 'berkas.pdf',
      fileType: json['fileType'] as String? ?? 'pdf',
      fileSize: json['fileSize'] as String? ?? '0 KB',
      base64Data: json['base64Data'] as String?,
      dateAdded: json['dateAdded'] as String? ?? '',
      notes: json['notes'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}

