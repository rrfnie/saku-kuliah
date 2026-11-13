/// Model Riwayat KHS / Nilai Per Semester (Transkrip Akademik)
class SemesterRecordModel {
  final int semesterNumber;
  final String academicYear;
  final int sks;
  final double ips;
  final bool isCompleted;

  SemesterRecordModel({
    required this.semesterNumber,
    required this.academicYear,
    required this.sks,
    required this.ips,
    this.isCompleted = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'semester_number': semesterNumber,
      'academic_year': academicYear,
      'sks': sks,
      'ips': ips,
      'is_completed': isCompleted,
    };
  }

  factory SemesterRecordModel.fromMap(Map<String, dynamic> map) {
    return SemesterRecordModel(
      semesterNumber: map['semester_number'] as int,
      academicYear: map['academic_year'] as String,
      sks: map['sks'] as int,
      ips: (map['ips'] as num).toDouble(),
      isCompleted: (map['is_completed'] as bool?) ?? true,
    );
  }

  SemesterRecordModel copyWith({
    int? semesterNumber,
    String? academicYear,
    int? sks,
    double? ips,
    bool? isCompleted,
  }) {
    return SemesterRecordModel(
      semesterNumber: semesterNumber ?? this.semesterNumber,
      academicYear: academicYear ?? this.academicYear,
      sks: sks ?? this.sks,
      ips: ips ?? this.ips,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

