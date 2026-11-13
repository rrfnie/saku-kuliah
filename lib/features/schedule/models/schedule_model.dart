/// Model Jadwal Kuliah SakuKuliah
class ScheduleModel {
  final int? id;
  final int dayOfWeek; // 0 = Senin, 1 = Selasa, ..., 6 = Minggu
  final String courseName;
  final String courseCode;
  final int sks;
  final String room;
  final String lecturer;
  final String startTime;
  final String endTime;
  final String category; // Praktikum, Teori, Kuliah Inti
  final String accentColorHex;

  ScheduleModel({
    this.id,
    required this.dayOfWeek,
    required this.courseName,
    required this.courseCode,
    required this.sks,
    required this.room,
    required this.lecturer,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.accentColorHex,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'day_of_week': dayOfWeek,
      'course_name': courseName,
      'course_code': courseCode,
      'sks': sks,
      'room': room,
      'lecturer': lecturer,
      'start_time': startTime,
      'end_time': endTime,
      'category': category,
      'accent_color_hex': accentColorHex,
    };
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] as int?,
      dayOfWeek: map['day_of_week'] as int,
      courseName: map['course_name'] as String,
      courseCode: map['course_code'] as String,
      sks: map['sks'] as int,
      room: map['room'] as String,
      lecturer: map['lecturer'] as String,
      startTime: map['start_time'] as String,
      endTime: map['end_time'] as String,
      category: map['category'] as String,
      accentColorHex: map['accent_color_hex'] as String,
    );
  }
}

