/// Model KRS & Nilai Mata Kuliah SakuKuliah
class CourseKrsModel {
  final int? id;
  final int semesterNumber;
  final String courseName;
  final String courseCode;
  final int sks;
  final String targetGrade; // A, A-, B+, B, B-, C+, C, D, E
  final double gradePoint; // 4.0, 3.7, 3.3, 3.0, 2.7, 2.3, 2.0, 1.0, 0.0
  final int attendancePresent;
  final int attendanceTotal;
  final String status; // Aktif, Selesai

  CourseKrsModel({
    this.id,
    required this.semesterNumber,
    required this.courseName,
    required this.courseCode,
    required this.sks,
    required this.targetGrade,
    required this.gradePoint,
    required this.attendancePresent,
    required this.attendanceTotal,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'semester_number': semesterNumber,
      'course_name': courseName,
      'course_code': courseCode,
      'sks': sks,
      'target_grade': targetGrade,
      'grade_point': gradePoint,
      'attendance_present': attendancePresent,
      'attendance_total': attendanceTotal,
      'status': status,
    };
  }

  factory CourseKrsModel.fromMap(Map<String, dynamic> map) {
    return CourseKrsModel(
      id: map['id'] as int?,
      semesterNumber: map['semester_number'] as int,
      courseName: map['course_name'] as String,
      courseCode: map['course_code'] as String,
      sks: map['sks'] as int,
      targetGrade: map['target_grade'] as String,
      gradePoint: (map['grade_point'] as num).toDouble(),
      attendancePresent: map['attendance_present'] as int,
      attendanceTotal: map['attendance_total'] as int,
      status: map['status'] as String,
    );
  }

  double get attendancePercentage {
    if (attendanceTotal == 0) return 100.0;
    return (attendancePresent / attendanceTotal) * 100;
  }

  bool get isAttendanceWarning {
    return attendancePercentage < 75.0;
  }
}

