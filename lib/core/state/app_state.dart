import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../services/notification_service.dart';
import '../theme/app_palettes.dart';
import '../../features/academic/models/course_krs_model.dart';
import '../../features/academic/models/semester_record_model.dart';
import '../../features/calendar/models/academic_event_model.dart';
import '../../features/notes/models/lecture_note_model.dart';
import '../../features/profile/models/student_profile_model.dart';
import '../../features/schedule/models/schedule_model.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/wallet/models/transaction_model.dart';
import '../../features/wallet/models/campus_bill_model.dart';
import '../../features/vault/models/student_document_model.dart';

/// State Management terpusat SakuKuliah (100% Offline & Reactive)
class SakuKuliahState extends ChangeNotifier {
  static final SakuKuliahState instance = SakuKuliahState._internal();
  SakuKuliahState._internal() {
    _loadInitialMockData();
    _loadFromStorage();
  }

  // Profil Mahasiswa
  late StudentProfileModel studentProfile;

  // Data List
  List<ScheduleModel> schedules = [];
  List<TaskModel> tasks = [];
  List<LectureNoteModel> notes = [];
  List<CourseKrsModel> krsCourses = [];
  List<SemesterRecordModel> semesterHistory = [];
  List<AcademicEventModel> academicEvents = [];
  List<TransactionModel> transactions = [];
  List<CampusBillModel> campusBills = [];
  List<StudentDocumentModel> documents = [];
  double monthlyBudget = 0.0;

  // Tema & Tampilan Aplikasi
  ThemeMode themeMode = ThemeMode.system;
  AppPaletteType themePalette = AppPaletteType.sakura;

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    notifyListeners();
    _saveThemePreferences();
  }

  void setThemePalette(AppPaletteType palette) {
    themePalette = palette;
    notifyListeners();
    _saveThemePreferences();
  }

  Future<void> _saveThemePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sakukuliah_theme_mode', themeMode.name);
      await prefs.setString('sakukuliah_theme_palette', themePalette.name);
    } catch (_) {}
  }

  void _loadInitialMockData() {
    // Profil Baru Bersih (Fresh Install)
    studentProfile = StudentProfileModel(
      name: '',
      nim: '',
      major: '',
      faculty: '',
      university: '',
      currentSemester: 1,
      academicYear: AppConstants.defaultAcademicYear,
      targetIpk: 4.00,
      cumulativeIpk: 0.00,
      completedSks: 0,
      totalSks: AppConstants.defaultSksTotalD3,
      degreeLevel: AppConstants.defaultDegreeLevel,
    );

    // Semua data awal fresh install kosong
    schedules = [];
    tasks = [];
    notes = [];
    krsCourses = [];
    semesterHistory = [];
    academicEvents = [];
    transactions = [];
    campusBills = [];
    documents = [];
    monthlyBudget = 0.0;
  }

  /// Menghapus seluruh data kembali ke kondisi awal yang bersih
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
    _loadInitialMockData();
    notifyListeners();
    await saveAll();
  }

  /// Menyimpan seluruh state ke penyimpanan lokal
  Future<void> saveAll() async {
    await _saveProfile();
    await _saveSchedules();
    await _saveTasks();
    await _saveNotes();
    await _saveKrsCourses();
    await _saveSemesterHistory();
    await _saveAcademicEvents();
    await _saveTransactions();
    await _saveCampusBills();
    await _saveDocuments();
    await _saveMonthlyBudget();
  }


  // --- ACTIONS ---

  // Jadwal Kuliah (Terintegrasi otomatis dengan KRS & Pelacak Absensi)
  void addSchedule(ScheduleModel schedule) {
    schedules.add(schedule);
    _syncScheduleToKrs(schedule);
    notifyListeners();
    _saveSchedules();
    NotificationService.instance.scheduleClassReminder(schedule);
  }

  void deleteSchedule(int id) {
    final deleted = schedules.where((s) => s.id == id).firstOrNull;
    schedules.removeWhere((item) => item.id == id);
    if (deleted != null) {
      final stillExists = schedules.any((s) => s.courseName.trim().toUpperCase() == deleted.courseName.trim().toUpperCase());
      if (!stillExists) {
        krsCourses.removeWhere((c) => c.courseName.trim().toUpperCase() == deleted.courseName.trim().toUpperCase());
        _saveKrsCourses();
      }
    }
    notifyListeners();
    _saveSchedules();
    NotificationService.instance.cancelNotification(1000 + id);
  }

  void updateSchedule(ScheduleModel schedule) {
    final index = schedules.indexWhere((item) => item.id == schedule.id);
    if (index != -1) {
      schedules[index] = schedule;
      _syncScheduleToKrs(schedule);
      notifyListeners();
      _saveSchedules();
      NotificationService.instance.scheduleClassReminder(schedule);
    }
  }

  void _syncScheduleToKrs(ScheduleModel schedule) {
    final name = schedule.courseName.trim().toUpperCase();
    final code = schedule.courseCode.trim().toUpperCase();
    final idx = krsCourses.indexWhere((c) =>
        (code.isNotEmpty && c.courseCode.trim().toUpperCase() == code) ||
        c.courseName.trim().toUpperCase() == name);

    if (idx != -1) {
      final old = krsCourses[idx];
      if (old.sks != schedule.sks) {
        krsCourses[idx] = CourseKrsModel(
          id: old.id,
          semesterNumber: old.semesterNumber,
          courseName: old.courseName,
          courseCode: old.courseCode,
          sks: schedule.sks,
          targetGrade: old.targetGrade,
          gradePoint: old.gradePoint,
          attendancePresent: old.attendancePresent,
          attendanceTotal: old.attendanceTotal,
          status: old.status,
        );
        _saveKrsCourses();
      }
    } else if (schedule.courseName.trim().isNotEmpty) {
      krsCourses.add(CourseKrsModel(
        id: DateTime.now().millisecondsSinceEpoch + ((schedule.id ?? 0) % 1000),
        semesterNumber: studentProfile.currentSemester,
        courseName: schedule.courseName.trim(),
        courseCode: schedule.courseCode.trim().isEmpty ? 'MK${(schedule.id ?? 0) % 10000}' : schedule.courseCode.trim(),
        sks: schedule.sks > 0 ? schedule.sks : 3,
        targetGrade: 'A',
        gradePoint: 4.0,
        attendancePresent: 0,
        attendanceTotal: 16,
        status: 'Aktif',
      ));
      _saveKrsCourses();
    }
  }

  void syncAllSchedulesToKrs({Map<String, dynamic>? attendanceMap}) {
    bool changed = false;
    for (final s in schedules) {
      final name = s.courseName.trim().toUpperCase();
      final code = s.courseCode.trim().toUpperCase();
      final idx = krsCourses.indexWhere((c) =>
          (code.isNotEmpty && c.courseCode.trim().toUpperCase() == code) ||
          c.courseName.trim().toUpperCase() == name);

      if (idx == -1 && s.courseName.trim().isNotEmpty) {
        int present = 0;
        int total = 16;
        if (attendanceMap != null) {
          final item = (attendanceMap[code] ?? attendanceMap[name]) as Map<String, dynamic>?;
          if (item != null) {
            present = ((item['hadir'] as num?)?.toInt() ?? 0).clamp(0, 16);
            final hadir = present;
            final izin = ((item['izin'] as num?)?.toInt() ?? 0).clamp(0, 16);
            final alpa = ((item['alpa'] as num?)?.toInt() ?? 0).clamp(0, 16);
            total = (hadir + izin + alpa) > 0 ? (hadir + izin + alpa) : 16;
          }
        }

        krsCourses.add(CourseKrsModel(
          id: DateTime.now().millisecondsSinceEpoch + ((s.id ?? 0) % 1000),
          semesterNumber: studentProfile.currentSemester,
          courseName: s.courseName.trim(),
          courseCode: s.courseCode.trim().isEmpty ? 'MK${(s.id ?? 0) % 10000}' : s.courseCode.trim(),
          sks: s.sks > 0 ? s.sks : 3,
          targetGrade: 'A',
          gradePoint: 4.0,
          attendancePresent: present,
          attendanceTotal: total,
          status: 'Aktif',
        ));
        changed = true;
      } else if (idx != -1 && attendanceMap != null) {
        final old = krsCourses[idx];
        final item = (attendanceMap[code] ?? attendanceMap[name]) as Map<String, dynamic>?;
        if (item != null) {
          final present = ((item['hadir'] as num?)?.toInt() ?? 0).clamp(0, 16);
          final hadir = present;
          final izin = ((item['izin'] as num?)?.toInt() ?? 0).clamp(0, 16);
          final alpa = ((item['alpa'] as num?)?.toInt() ?? 0).clamp(0, 16);
          final total = (hadir + izin + alpa) > 0 ? (hadir + izin + alpa) : 16;
          if (old.attendancePresent != present || old.attendanceTotal != total) {
            krsCourses[idx] = CourseKrsModel(
              id: old.id,
              semesterNumber: old.semesterNumber,
              courseName: old.courseName,
              courseCode: old.courseCode,
              sks: old.sks,
              targetGrade: old.targetGrade,
              gradePoint: old.gradePoint,
              attendancePresent: present,
              attendanceTotal: total,
              status: old.status,
            );
            changed = true;
          }
        }
      }
    }

    if (changed) {
      _saveKrsCourses();
    }
  }

  // Tugas & Deadline
  void addTask(TaskModel task) {
    tasks.insert(0, task);
    notifyListeners();
    _saveTasks();
    NotificationService.instance.scheduleTaskDeadlineReminder(task);
  }

  void toggleTaskCompletion(int id) {
    final index = tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = tasks[index];
      final isCompleted = !task.isCompleted;
      tasks[index] = task.copyWith(isCompleted: isCompleted);
      notifyListeners();
      _saveTasks();
      if (isCompleted) {
        NotificationService.instance.cancelNotification((id * 10) + 1);
        NotificationService.instance.cancelNotification((id * 10) + 2);
      } else {
        NotificationService.instance.scheduleTaskDeadlineReminder(tasks[index]);
      }
    }
  }

  void deleteTask(int id) {
    tasks.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveTasks();
    NotificationService.instance.cancelNotification((id * 10) + 1);
    NotificationService.instance.cancelNotification((id * 10) + 2);
  }

  // Catatan Kuliah
  void addNote(LectureNoteModel note) {
    notes.insert(0, note);
    notifyListeners();
    _saveNotes();
  }

  void updateNote(LectureNoteModel note) {
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      notes[index] = note;
      notifyListeners();
      _saveNotes();
    }
  }

  void deleteNote(int id) {
    notes.removeWhere((n) => n.id == id);
    notifyListeners();
    _saveNotes();
  }

  void togglePinNote(int id) {
    final index = notes.indexWhere((n) => n.id == id);
    if (index != -1) {
      final n = notes[index];
      notes[index] = n.copyWith(isPinned: !n.isPinned);
      notifyListeners();
      _saveNotes();
    }
  }

  // Profil Mahasiswa
  void updateStudentProfile(StudentProfileModel newProfile) {
    studentProfile = newProfile;
    notifyListeners();
    _saveProfile();
  }

  // Impor Massal dari Scan KRS / KHS
  void importSchedules(List<ScheduleModel> newSchedules) {
    schedules.addAll(newSchedules);
    notifyListeners();
    _saveSchedules();
  }

  void importKrsCourses(List<CourseKrsModel> newCourses) {
    krsCourses.addAll(newCourses);
    notifyListeners();
    _saveKrsCourses();
  }

  void updateKrsGrade(int courseId, String targetGrade, double gradePoint) {
    final idx = krsCourses.indexWhere((c) => c.id == courseId);
    if (idx != -1) {
      final old = krsCourses[idx];
      krsCourses[idx] = CourseKrsModel(
        id: old.id,
        semesterNumber: old.semesterNumber,
        courseName: old.courseName,
        courseCode: old.courseCode,
        sks: old.sks,
        targetGrade: targetGrade,
        gradePoint: gradePoint,
        attendancePresent: old.attendancePresent,
        attendanceTotal: old.attendanceTotal,
        status: old.status,
      );
      notifyListeners();
      _saveKrsCourses();
    }
  }

  void updateCourseAttendance(String courseCodeOrName, int present, int total) {
    final query = courseCodeOrName.trim().toUpperCase();
    final idx = krsCourses.indexWhere((c) =>
        (c.courseCode.trim().isNotEmpty && c.courseCode.trim().toUpperCase() == query) ||
        c.courseName.trim().toUpperCase() == query);

    if (idx != -1) {
      final old = krsCourses[idx];
      krsCourses[idx] = CourseKrsModel(
        id: old.id,
        semesterNumber: old.semesterNumber,
        courseName: old.courseName,
        courseCode: old.courseCode,
        sks: old.sks,
        targetGrade: old.targetGrade,
        gradePoint: old.gradePoint,
        attendancePresent: present,
        attendanceTotal: total > 0 ? total : 16,
        status: old.status,
      );
    } else {
      // Jika belum ada di krsCourses, ambil dari jadwal kuliah
      final sched = schedules.where((s) =>
          (s.courseCode.trim().isNotEmpty && s.courseCode.trim().toUpperCase() == query) ||
          s.courseName.trim().toUpperCase() == query).firstOrNull;
      if (sched != null) {
        krsCourses.add(CourseKrsModel(
          id: DateTime.now().millisecondsSinceEpoch,
          semesterNumber: studentProfile.currentSemester,
          courseName: sched.courseName,
          courseCode: sched.courseCode,
          sks: sched.sks,
          targetGrade: 'A',
          gradePoint: 4.0,
          attendancePresent: present,
          attendanceTotal: total > 0 ? total : 16,
          status: 'Aktif',
        ));
      }
    }
    notifyListeners();
    _saveKrsCourses();
  }

  // Riwayat KHS Semester Sebelumnya & Pengaturan Jenjang (D3 / S1)
  void updateSemesterRecord(int semesterNumber, int sks, double ips) {
    final idx = semesterHistory.indexWhere((s) => s.semesterNumber == semesterNumber);
    if (idx != -1) {
      semesterHistory[idx] = semesterHistory[idx].copyWith(sks: sks, ips: ips);
    } else {
      semesterHistory.add(SemesterRecordModel(
        semesterNumber: semesterNumber,
        academicYear: 'Semester $semesterNumber',
        sks: sks,
        ips: ips,
      ));
      semesterHistory.sort((a, b) => a.semesterNumber.compareTo(b.semesterNumber));
    }
    _recalculateCumulativeStatsFromHistory();
    notifyListeners();
    _saveSemesterHistory();
  }

  void _recalculateCumulativeStatsFromHistory() {
    if (semesterHistory.isEmpty) return;
    int totalSks = 0;
    double totalPoints = 0;
    for (final s in semesterHistory.where((e) => e.isCompleted)) {
      totalSks += s.sks;
      totalPoints += (s.ips * s.sks);
    }
    if (totalSks > 0) {
      final double calculatedIpk = totalPoints / totalSks;
      studentProfile = studentProfile.copyWith(
        completedSks: totalSks,
        cumulativeIpk: double.parse(calculatedIpk.toStringAsFixed(2)),
      );
      _saveProfile();
    }
  }

  void updateQuickPreviousStats({required double ipk, required int sks}) {
    studentProfile = studentProfile.copyWith(
      cumulativeIpk: ipk,
      completedSks: sks,
    );
    notifyListeners();
    _saveProfile();
  }

  void updateDegreeLevel(String degree) {
    final int newTotalSks = degree == 'D3' ? AppConstants.defaultSksTotalD3 : AppConstants.defaultSksTotalS1;
    studentProfile = studentProfile.copyWith(
      degreeLevel: degree,
      totalSks: newTotalSks,
    );
    notifyListeners();
    _saveProfile();
  }

  // Agenda Kalender Akademik & Ujian (UTS, UAS, Ujian Praktikum, Kuis)
  void addAcademicEvent(AcademicEventModel event) {
    academicEvents.add(event);
    academicEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    notifyListeners();
    _saveAcademicEvents();
  }

  void updateAcademicEvent(AcademicEventModel event) {
    final idx = academicEvents.indexWhere((e) => e.id == event.id);
    if (idx != -1) {
      academicEvents[idx] = event;
      academicEvents.sort((a, b) => a.eventDate.compareTo(b.eventDate));
      notifyListeners();
      _saveAcademicEvents();
    }
  }

  void deleteAcademicEvent(int id) {
    academicEvents.removeWhere((e) => e.id == id);
    notifyListeners();
    _saveAcademicEvents();
  }

  // --- FITUR DOMPET PASTEL & KEUANGAN MAHASISWA ---

  double get totalBalance {
    double total = 0;
    for (final t in transactions) {
      if (t.isExpense) {
        total -= t.amount;
      } else {
        total += t.amount;
      }
    }
    return total;
  }

  double get totalIncomeThisMonth {
    final currentMonthStr = DateTime.now().toIso8601String().substring(0, 7);
    double total = 0;
    for (final t in transactions) {
      if (!t.isExpense && t.date.startsWith(currentMonthStr)) {
        total += t.amount;
      }
    }
    return total;
  }

  double get totalExpenseThisMonth {
    final currentMonthStr = DateTime.now().toIso8601String().substring(0, 7);
    double total = 0;
    for (final t in transactions) {
      if (t.isExpense && t.date.startsWith(currentMonthStr)) {
        total += t.amount;
      }
    }
    return total;
  }

  /// Jatah Jajan Harian Aman: (Sisa Uang Saku / Sisa Hari Bulan Ini)
  double get safeToSpendDaily {
    if (monthlyBudget <= 0) return 0.0;
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = (daysInMonth - now.day + 1).clamp(1, 31);
    final remainingBudget = (monthlyBudget - totalExpenseThisMonth).clamp(0.0, double.infinity);
    return remainingBudget / daysRemaining;
  }

  int get pendingBillsCount {
    return campusBills.where((b) => !b.isPaid).length;
  }

  void addTransaction(TransactionModel tx) {
    transactions.insert(0, tx);
    notifyListeners();
    _saveTransactions();
  }

  void deleteTransaction(int id) {
    transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    _saveTransactions();
  }

  void addCampusBill(CampusBillModel bill) {
    campusBills.add(bill);
    campusBills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
    _saveCampusBills();
  }

  void toggleBillPaid(int id) {
    final idx = campusBills.indexWhere((b) => b.id == id);
    if (idx != -1) {
      final old = campusBills[idx];
      campusBills[idx] = old.copyWith(isPaid: !old.isPaid);
      notifyListeners();
      _saveCampusBills();
    }
  }

  void deleteCampusBill(int id) {
    campusBills.removeWhere((b) => b.id == id);
    notifyListeners();
    _saveCampusBills();
  }

  void updateMonthlyBudget(double amount) {
    monthlyBudget = amount;
    notifyListeners();
    _saveMonthlyBudget();
  }

  // --- FITUR BRANKAS DOKUMEN MAHASISWA (STUDENT DOCUMENT VAULT) ---

  void addDocument(StudentDocumentModel doc) {
    documents.insert(0, doc);
    notifyListeners();
    _saveDocuments();
  }

  void updateDocument(StudentDocumentModel doc) {
    final idx = documents.indexWhere((d) => d.id == doc.id);
    if (idx != -1) {
      documents[idx] = doc;
      notifyListeners();
      _saveDocuments();
    }
  }

  void deleteDocument(String id) {
    documents.removeWhere((d) => d.id == id);
    notifyListeners();
    _saveDocuments();
  }

  void toggleDocumentFavorite(String id) {
    final idx = documents.indexWhere((d) => d.id == id);
    if (idx != -1) {
      final doc = documents[idx];
      documents[idx] = doc.copyWith(isFavorite: !doc.isFavorite);
      notifyListeners();
      _saveDocuments();
    }
  }

  Future<void> _saveDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = documents.map((d) => d.toJson()).toList();
      await prefs.setString('sakukuliah_documents', jsonEncode(list));
    } catch (_) {}
  }

  // --- LOCAL PERSISTENCE STORAGE METHODS (100% OFFLINE) ---

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Profil Mahasiswa
      final profileJson = prefs.getString('sakukuliah_profile');
      if (profileJson != null && profileJson.isNotEmpty) {
        studentProfile = StudentProfileModel.fromMap(
          Map<String, dynamic>.from(jsonDecode(profileJson) as Map),
        );
        // Auto-upgrade tahun akademik lama ke versi terbaru 2026/2027
        if (studentProfile.academicYear.contains('2025/2026') || studentProfile.academicYear.contains('2024/2025')) {
          studentProfile = studentProfile.copyWith(academicYear: AppConstants.defaultAcademicYear);
          _saveProfile();
        }
        // Bersihkan fakultas default mock bawaan lama
        if (studentProfile.faculty == 'Fakultas Ilmu Komputer') {
          studentProfile = studentProfile.copyWith(faculty: '');
          _saveProfile();
        }
      }

      // 2. Jadwal Kuliah
      final schedulesJson = prefs.getString('sakukuliah_schedules');
      if (schedulesJson != null && schedulesJson.isNotEmpty) {
        final List list = jsonDecode(schedulesJson) as List;
        schedules = list
            .map((e) => ScheduleModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 3. Tugas Kuliah
      final tasksJson = prefs.getString('sakukuliah_tasks');
      if (tasksJson != null && tasksJson.isNotEmpty) {
        final List list = jsonDecode(tasksJson) as List;
        tasks = list
            .map((e) => TaskModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 4. Catatan Kuliah
      final notesJson = prefs.getString('sakukuliah_notes');
      if (notesJson != null && notesJson.isNotEmpty) {
        final List list = jsonDecode(notesJson) as List;
        notes = list
            .map((e) => LectureNoteModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 5. Mata Kuliah KRS
      final krsJson = prefs.getString('sakukuliah_krs_courses');
      if (krsJson != null && krsJson.isNotEmpty) {
        final List list = jsonDecode(krsJson) as List;
        krsCourses = list
            .map((e) => CourseKrsModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 6. Riwayat KHS Semester Sebelumnya
      final historyJson = prefs.getString('sakukuliah_semester_history');
      if (historyJson != null && historyJson.isNotEmpty) {
        final List list = jsonDecode(historyJson) as List;
        semesterHistory = list
            .map((e) => SemesterRecordModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 7. Agenda Ujian & Kalender Akademik
      final eventsJson = prefs.getString('sakukuliah_academic_events');
      if (eventsJson != null && eventsJson.isNotEmpty) {
        final List list = jsonDecode(eventsJson) as List;
        academicEvents = list
            .map((e) => AcademicEventModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 8. Transaksi Dompet Mahasiswa
      final txJson = prefs.getString('sakukuliah_transactions');
      if (txJson != null && txJson.isNotEmpty) {
        final List list = jsonDecode(txJson) as List;
        transactions = list
            .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 9. Tagihan Kampus
      final billsJson = prefs.getString('sakukuliah_campus_bills');
      if (billsJson != null && billsJson.isNotEmpty) {
        final List list = jsonDecode(billsJson) as List;
        campusBills = list
            .map((e) => CampusBillModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 10. Anggaran Uang Saku Bulanan
      final budget = prefs.getDouble('sakukuliah_monthly_budget');
      if (budget != null && budget > 0) {
        monthlyBudget = budget;
      }

      // 11. Brankas Dokumen Mahasiswa
      final docsJson = prefs.getString('sakukuliah_documents');
      if (docsJson != null && docsJson.isNotEmpty) {
        final List list = jsonDecode(docsJson) as List;
        documents = list
            .map((e) => StudentDocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }

      // 12. Tema & Tampilan Aplikasi
      final modeStr = prefs.getString('sakukuliah_theme_mode');
      if (modeStr != null) {
        themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == modeStr,
          orElse: () => ThemeMode.system,
        );
      }
      final paletteStr = prefs.getString('sakukuliah_theme_palette');
      if (paletteStr != null) {
        themePalette = AppPaletteType.values.firstWhere(
          (p) => p.name == paletteStr,
          orElse: () => AppPaletteType.sakura,
        );
      }

      // 13. Sinkronisasi Cerdas Jadwal Kuliah & KRS serta Pelacak Absensi
      Map<String, dynamic>? attendanceMap;
      final rawAtt = prefs.getString('sakukuliah_attendance_counts');
      if (rawAtt != null && rawAtt.isNotEmpty) {
        try {
          attendanceMap = jsonDecode(rawAtt) as Map<String, dynamic>;
        } catch (_) {}
      }
      syncAllSchedulesToKrs(attendanceMap: attendanceMap);

      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sakukuliah_profile', jsonEncode(studentProfile.toMap()));
    } catch (_) {}
  }

  Future<void> _saveSchedules() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = schedules.map((s) => s.toMap()).toList();
      await prefs.setString('sakukuliah_schedules', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = tasks.map((t) => t.toMap()).toList();
      await prefs.setString('sakukuliah_tasks', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = notes.map((n) => n.toMap()).toList();
      await prefs.setString('sakukuliah_notes', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveKrsCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = krsCourses.map((c) => c.toMap()).toList();
      await prefs.setString('sakukuliah_krs_courses', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveSemesterHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = semesterHistory.map((s) => s.toMap()).toList();
      await prefs.setString('sakukuliah_semester_history', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveAcademicEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = academicEvents.map((e) => e.toMap()).toList();
      await prefs.setString('sakukuliah_academic_events', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = transactions.map((t) => t.toMap()).toList();
      await prefs.setString('sakukuliah_transactions', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveCampusBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = campusBills.map((b) => b.toMap()).toList();
      await prefs.setString('sakukuliah_campus_bills', jsonEncode(list));
    } catch (_) {}
  }

  Future<void> _saveMonthlyBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('sakukuliah_monthly_budget', monthlyBudget);
    } catch (_) {}
  }

  // Perhitungan IPK
  double calculatePredictedIps() {
    if (krsCourses.isEmpty) return 0.0;
    double totalPoints = 0;
    int totalSks = 0;
    for (final c in krsCourses) {
      totalPoints += (c.gradePoint * c.sks);
      totalSks += c.sks;
    }
    if (totalSks == 0) return 0.0;
    return totalPoints / totalSks;
  }

  /// Ekspor seluruh data lokal aplikasi SakuKuliah ke format JSON (100% Offline & Portable)
  String exportBackupJson() {
    final Map<String, dynamic> backup = {
      'app': AppConstants.appName,
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'student_profile': studentProfile.toMap(),
      'schedules': schedules.map((s) => s.toMap()).toList(),
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'notes': notes.map((n) => n.toMap()).toList(),
      'courses_krs': krsCourses.map((c) => c.toMap()).toList(),
      'semester_history': semesterHistory.map((s) => s.toMap()).toList(),
      'academic_events': academicEvents.map((e) => e.toMap()).toList(),
      'transactions': transactions.map((t) => t.toMap()).toList(),
      'campus_bills': campusBills.map((b) => b.toMap()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'monthly_budget': monthlyBudget,
    };
    return const JsonEncoder.withIndent('  ').convert(backup);
  }

  /// Memulihkan / Restore data dari berkas JSON backup
  bool restoreBackupJson(String jsonString) {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(jsonDecode(jsonString) as Map);

      if (data.containsKey('student_profile') && data['student_profile'] != null) {
        studentProfile = StudentProfileModel.fromMap(Map<String, dynamic>.from(data['student_profile'] as Map));
        _saveProfile();
      }

      if (data.containsKey('schedules') && data['schedules'] is List) {
        schedules = (data['schedules'] as List)
            .map((e) => ScheduleModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveSchedules();
      }

      if (data.containsKey('tasks') && data['tasks'] is List) {
        tasks = (data['tasks'] as List)
            .map((e) => TaskModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveTasks();
      }

      if (data.containsKey('notes') && data['notes'] is List) {
        notes = (data['notes'] as List)
            .map((e) => LectureNoteModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveNotes();
      }

      if (data.containsKey('courses_krs') && data['courses_krs'] is List) {
        krsCourses = (data['courses_krs'] as List)
            .map((e) => CourseKrsModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveKrsCourses();
      }

      if (data.containsKey('semester_history') && data['semester_history'] is List) {
        semesterHistory = (data['semester_history'] as List)
            .map((e) => SemesterRecordModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveSemesterHistory();
      }

      if (data.containsKey('academic_events') && data['academic_events'] is List) {
        academicEvents = (data['academic_events'] as List)
            .map((e) => AcademicEventModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveAcademicEvents();
      }

      if (data.containsKey('transactions') && data['transactions'] is List) {
        transactions = (data['transactions'] as List)
            .map((e) => TransactionModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveTransactions();
      }

      if (data.containsKey('campus_bills') && data['campus_bills'] is List) {
        campusBills = (data['campus_bills'] as List)
            .map((e) => CampusBillModel.fromMap(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveCampusBills();
      }

      if (data.containsKey('documents') && data['documents'] is List) {
        documents = (data['documents'] as List)
            .map((e) => StudentDocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        _saveDocuments();
      }

      if (data.containsKey('monthly_budget') && data['monthly_budget'] is num) {
        monthlyBudget = (data['monthly_budget'] as num).toDouble();
        _saveMonthlyBudget();
      }

      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}

