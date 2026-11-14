import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

/// Database Helper SQLite untuk penyimpanan data 100% lokal & privat
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sakukuliah.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Profil Mahasiswa
    await db.execute('''
      CREATE TABLE student_profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nim TEXT NOT NULL,
        major TEXT NOT NULL,
        faculty TEXT NOT NULL,
        university TEXT NOT NULL,
        current_semester INTEGER NOT NULL,
        target_ipk REAL NOT NULL,
        cumulative_ipk REAL NOT NULL,
        completed_sks INTEGER NOT NULL,
        total_sks INTEGER NOT NULL
      )
    ''');

    // 2. Jadwal Kuliah
    await db.execute('''
      CREATE TABLE schedules (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        day_of_week INTEGER NOT NULL,
        course_name TEXT NOT NULL,
        course_code TEXT NOT NULL,
        sks INTEGER NOT NULL,
        room TEXT NOT NULL,
        lecturer TEXT NOT NULL,
        start_time TEXT NOT NULL,
        end_time TEXT NOT NULL,
        category TEXT NOT NULL,
        accent_color_hex TEXT NOT NULL
      )
    ''');

    // 3. Tugas & Deadline
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        course_name TEXT NOT NULL,
        due_date TEXT NOT NULL,
        due_time TEXT NOT NULL,
        priority TEXT NOT NULL,
        attachment_info TEXT,
        assignment_type TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Subtugas
    await db.execute('''
      CREATE TABLE subtasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
      )
    ''');

    // 5. Kalender Agenda Akademik
    await db.execute('''
      CREATE TABLE academic_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        event_date TEXT NOT NULL,
        start_time TEXT,
        end_time TEXT,
        event_type TEXT NOT NULL,
        location TEXT,
        notes TEXT
      )
    ''');

    // 6. Catatan Kuliah & Materi
    await db.execute('''
      CREATE TABLE lecture_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_name TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        created_date TEXT NOT NULL,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        tags TEXT,
        attachment_name TEXT,
        attachment_size TEXT,
        read_time TEXT
      )
    ''');

    // 7. KRS & Perhitungan IPK
    await db.execute('''
      CREATE TABLE courses_krs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        semester_number INTEGER NOT NULL,
        course_name TEXT NOT NULL,
        course_code TEXT NOT NULL,
        sks INTEGER NOT NULL,
        target_grade TEXT NOT NULL,
        grade_point REAL NOT NULL,
        attendance_present INTEGER NOT NULL,
        attendance_total INTEGER NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    // Inisialisasi Mock Seed Data (Dibiarkan kosong untuk fresh install offline)
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    // Fresh install tanpa data dummy
  }

  /// Ekspor seluruh data lokal ke format JSON untuk backup
  Future<String> exportBackupJson() async {
    final db = await database;
    final Map<String, dynamic> backup = {
      'app': AppConstants.appName,
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'student_profile': await db.query('student_profile'),
      'schedules': await db.query('schedules'),
      'tasks': await db.query('tasks'),
      'subtasks': await db.query('subtasks'),
      'academic_events': await db.query('academic_events'),
      'lecture_notes': await db.query('lecture_notes'),
      'courses_krs': await db.query('courses_krs'),
    };
    return jsonEncode(backup);
  }
}

