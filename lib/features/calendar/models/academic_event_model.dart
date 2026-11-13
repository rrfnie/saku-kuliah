/// Model Agenda Kalender Akademik SakuKuliah
class AcademicEventModel {
  final int? id;
  final String title;
  final String eventDate; // YYYY-MM-DD
  final String? startTime;
  final String? endTime;
  final String eventType; // Tugas, UTS, UAS, Libur, Kelas Pengganti
  final String? location;
  final String? notes;

  AcademicEventModel({
    this.id,
    required this.title,
    required this.eventDate,
    this.startTime,
    this.endTime,
    required this.eventType,
    this.location,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'event_date': eventDate,
      'start_time': startTime,
      'end_time': endTime,
      'event_type': eventType,
      'location': location,
      'notes': notes,
    };
  }

  factory AcademicEventModel.fromMap(Map<String, dynamic> map) {
    return AcademicEventModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      eventDate: map['event_date'] as String,
      startTime: map['start_time'] as String?,
      endTime: map['end_time'] as String?,
      eventType: map['event_type'] as String,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
    );
  }
}

