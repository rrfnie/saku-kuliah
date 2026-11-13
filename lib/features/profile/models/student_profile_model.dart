/// Model Profil Mahasiswa SakuKuliah
class StudentProfileModel {
  final int? id;
  final String name;
  final String nim;
  final String major;
  final String faculty;
  final String university;
  final int currentSemester;
  final String academicYear;
  final String? avatarBase64;
  final String? avatarPreset;
  final double targetIpk;
  final double cumulativeIpk;
  final int completedSks;
  final int totalSks;
  final String degreeLevel; // 'D3', 'S1', 'D4'

  StudentProfileModel({
    this.id,
    required this.name,
    required this.nim,
    required this.major,
    required this.faculty,
    required this.university,
    required this.currentSemester,
    this.academicYear = '2026/2027 (Ganjil)',
    this.avatarBase64,
    this.avatarPreset,
    required this.targetIpk,
    required this.cumulativeIpk,
    required this.completedSks,
    required this.totalSks,
    this.degreeLevel = 'D3',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'nim': nim,
      'major': major,
      'faculty': faculty,
      'university': university,
      'current_semester': currentSemester,
      'academic_year': academicYear,
      'avatar_base64': avatarBase64,
      'avatar_preset': avatarPreset,
      'target_ipk': targetIpk,
      'cumulative_ipk': cumulativeIpk,
      'completed_sks': completedSks,
      'total_sks': totalSks,
      'degree_level': degreeLevel,
    };
  }

  factory StudentProfileModel.fromMap(Map<String, dynamic> map) {
    return StudentProfileModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      nim: map['nim'] as String,
      major: map['major'] as String,
      faculty: map['faculty'] as String,
      university: map['university'] as String,
      currentSemester: map['current_semester'] as int,
      academicYear: (map['academic_year'] as String?) ?? '2026/2027 (Ganjil)',
      avatarBase64: map['avatar_base64'] as String?,
      avatarPreset: map['avatar_preset'] as String?,
      targetIpk: (map['target_ipk'] as num).toDouble(),
      cumulativeIpk: (map['cumulative_ipk'] as num).toDouble(),
      completedSks: map['completed_sks'] as int,
      totalSks: map['total_sks'] as int,
      degreeLevel: (map['degree_level'] as String?) ?? 'D3',
    );
  }

  double get degreeProgressPercentage {
    if (totalSks == 0) return 0.0;
    return (completedSks / totalSks) * 100;
  }

  StudentProfileModel copyWith({
    int? id,
    String? name,
    String? nim,
    String? major,
    String? faculty,
    String? university,
    int? currentSemester,
    String? academicYear,
    String? avatarBase64,
    String? avatarPreset,
    double? targetIpk,
    double? cumulativeIpk,
    int? completedSks,
    int? totalSks,
    String? degreeLevel,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nim: nim ?? this.nim,
      major: major ?? this.major,
      faculty: faculty ?? this.faculty,
      university: university ?? this.university,
      currentSemester: currentSemester ?? this.currentSemester,
      academicYear: academicYear ?? this.academicYear,
      avatarBase64: avatarBase64 ?? this.avatarBase64,
      avatarPreset: avatarPreset ?? this.avatarPreset,
      targetIpk: targetIpk ?? this.targetIpk,
      cumulativeIpk: cumulativeIpk ?? this.cumulativeIpk,
      completedSks: completedSks ?? this.completedSks,
      totalSks: totalSks ?? this.totalSks,
      degreeLevel: degreeLevel ?? this.degreeLevel,
    );
  }
}

