/// Model Catatan Kuliah & Materi SakuKuliah
class LectureNoteModel {
  final int? id;
  final String courseName;
  final String title;
  final String content;
  final String createdDate;
  final bool isPinned;
  final String? tags;
  final String? attachmentName;
  final String? attachmentSize;
  final String? readTime;

  LectureNoteModel({
    this.id,
    required this.courseName,
    required this.title,
    required this.content,
    required this.createdDate,
    this.isPinned = false,
    this.tags,
    this.attachmentName,
    this.attachmentSize,
    this.readTime,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'course_name': courseName,
      'title': title,
      'content': content,
      'created_date': createdDate,
      'is_pinned': isPinned ? 1 : 0,
      'tags': tags,
      'attachment_name': attachmentName,
      'attachment_size': attachmentSize,
      'read_time': readTime,
    };
  }

  factory LectureNoteModel.fromMap(Map<String, dynamic> map) {
    return LectureNoteModel(
      id: map['id'] as int?,
      courseName: map['course_name'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      createdDate: map['created_date'] as String,
      isPinned: (map['is_pinned'] as int) == 1,
      tags: map['tags'] as String?,
      attachmentName: map['attachment_name'] as String?,
      attachmentSize: map['attachment_size'] as String?,
      readTime: map['read_time'] as String?,
    );
  }

  List<String> get tagList {
    if (tags == null || tags!.isEmpty) return [];
    return tags!.split(',').map((String e) => e.trim()).where((String e) => e.isNotEmpty).toList();
  }

  LectureNoteModel copyWith({
    int? id,
    String? courseName,
    String? title,
    String? content,
    String? createdDate,
    bool? isPinned,
    String? tags,
    String? attachmentName,
    String? attachmentSize,
    String? readTime,
  }) {
    return LectureNoteModel(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      title: title ?? this.title,
      content: content ?? this.content,
      createdDate: createdDate ?? this.createdDate,
      isPinned: isPinned ?? this.isPinned,
      tags: tags ?? this.tags,
      attachmentName: attachmentName ?? this.attachmentName,
      attachmentSize: attachmentSize ?? this.attachmentSize,
      readTime: readTime ?? this.readTime,
    );
  }
}

