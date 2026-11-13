/// Model Subtugas SakuKuliah
class SubtaskModel {
  final int? id;
  final int? taskId;
  final String title;
  final bool isCompleted;

  SubtaskModel({
    this.id,
    this.taskId,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      'title': title,
      'is_completed': isCompleted ? 1 : 0,
    };
  }

  factory SubtaskModel.fromMap(Map<String, dynamic> map) {
    return SubtaskModel(
      id: map['id'] as int?,
      taskId: map['task_id'] as int?,
      title: map['title'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
    );
  }

  SubtaskModel copyWith({
    int? id,
    int? taskId,
    String? title,
    bool? isCompleted,
  }) {
    return SubtaskModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Model Tugas Kuliah & Deadline SakuKuliah
class TaskModel {
  final int? id;
  final String title;
  final String courseName;
  final String dueDate;
  final String dueTime;
  final String priority; // Tinggi, Sedang, Rendah
  final String? attachmentInfo;
  final String assignmentType; // Individu, Kelompok
  final bool isCompleted;
  final String createdAt;
  final List<SubtaskModel> subtasks;

  TaskModel({
    this.id,
    required this.title,
    required this.courseName,
    required this.dueDate,
    required this.dueTime,
    required this.priority,
    this.attachmentInfo,
    required this.assignmentType,
    this.isCompleted = false,
    required this.createdAt,
    this.subtasks = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'course_name': courseName,
      'due_date': dueDate,
      'due_time': dueTime,
      'priority': priority,
      'attachment_info': attachmentInfo,
      'assignment_type': assignmentType,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
    };
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, {List<SubtaskModel> subtasks = const []}) {
    List<SubtaskModel> parsedSubtasks = subtasks;
    if (map['subtasks'] != null && map['subtasks'] is List) {
      parsedSubtasks = (map['subtasks'] as List)
          .map((s) => SubtaskModel.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList();
    }
    return TaskModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      courseName: map['course_name'] as String,
      dueDate: map['due_date'] as String,
      dueTime: map['due_time'] as String,
      priority: map['priority'] as String,
      attachmentInfo: map['attachment_info'] as String?,
      assignmentType: map['assignment_type'] as String,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: map['created_at'] as String,
      subtasks: parsedSubtasks,
    );
  }

  TaskModel copyWith({
    int? id,
    String? title,
    String? courseName,
    String? dueDate,
    String? dueTime,
    String? priority,
    String? attachmentInfo,
    String? assignmentType,
    bool? isCompleted,
    String? createdAt,
    List<SubtaskModel>? subtasks,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      courseName: courseName ?? this.courseName,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      attachmentInfo: attachmentInfo ?? this.attachmentInfo,
      assignmentType: assignmentType ?? this.assignmentType,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}

