import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../features/schedule/models/schedule_model.dart';
import '../../features/tasks/models/task_model.dart';

/// Service Notifikasi Lokal HP (100% Offline) SakuKuliah
/// Memunculkan notifikasi sistem di status bar / banner HP Android & iOS
/// untuk pengingat jadwal kuliah, tugas, dan ujian tanpa internet.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Channel ID khusus notifikasi akademik
  static const String channelId = 'sakukuliah_academic_channel';
  static const String channelName = 'Pengingat Akademik SakuKuliah';
  static const String channelDescription =
      'Notifikasi pengingat jadwal kuliah, batas waktu tugas, dan ujian';

  /// Inisialisasi service saat aplikasi pertama kali dijalankan
  Future<void> initialize() async {
    if (_isInitialized) return;

    if (kIsWeb) {
      _isInitialized = true;
      return;
    }

    try {
      // Inisialisasi zona waktu untuk scheduling
      tz.initializeTimeZones();

      // Pengaturan Android (menggunakan icon app resmi / default status bar)
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Pengaturan iOS / Darwin
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notifikasi diklik dengan payload: ${response.payload}');
        },
      );

      // Buat Android Notification Channel dengan prioritas tinggi agar muncul pop-up banner
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Buat channel
          await androidImplementation.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
              showBadge: true,
            ),
          );

          // Minta izin notifikasi langsung di Android 13+
          await androidImplementation.requestNotificationsPermission();
        }
      }

      _isInitialized = true;
      debugPrint('NotificationService berhasil diinisialisasi 🌸✨');
    } catch (e) {
      debugPrint('Error inisialisasi NotificationService: $e');
    }
  }

  /// Minta izin notifikasi secara eksplisit
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        final granted =
            await androidImplementation?.requestNotificationsPermission();
        return granted ?? false;
      } else if (Platform.isIOS) {
        final iosImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        final granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (_) {}
    return false;
  }

  /// Tampilkan notifikasi instan langsung muncul detik ini juga di status bar HP
  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    await initialize();

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'SakuKuliah',
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Gagal menampilkan notifikasi instan: $e');
    }
  }

  /// Jadwalkan notifikasi di masa depan (misal sebelum jam kuliah atau deadline tugas)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb) return;
    await initialize();

    // Pastikan waktu di masa depan
    if (scheduledDate.isBefore(DateTime.now())) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Gagal menjadwalkan notifikasi: $e');
    }
  }

  /// Jadwalkan pengingat deadline tugas (H-1 dan jam 07:00 pagi hari H)
  Future<void> scheduleTaskDeadlineReminder(TaskModel task) async {
    if (kIsWeb || task.id == null || task.isCompleted) return;

    try {
      final dueDate = DateTime.tryParse(task.dueDate);
      if (dueDate == null) return;

      // 1. Pengingat H-1 pukul 19:00 malam
      final reminderEve = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day - 1,
        19,
        0,
      );
      if (reminderEve.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: (task.id! * 10) + 1,
          title: '⏰ Besok Deadline: ${task.title}',
          body:
              'Mata kuliah: ${task.courseName}. Yuk cek & tuntaskan tugasmu malam ini! 🌸',
          scheduledDate: reminderEve,
          payload: 'task_${task.id}',
        );
      }

      // 2. Pengingat Hari H pukul 07:00 pagi
      final reminderMorning = DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        7,
        0,
      );
      if (reminderMorning.isAfter(DateTime.now())) {
        await scheduleNotification(
          id: (task.id! * 10) + 2,
          title: '🚨 Deadline Hari Ini: ${task.title}!',
          body:
              'Batas pengumpulan tugas ${task.courseName} hari ini (${task.dueTime.isNotEmpty ? task.dueTime : "segera"}). Semangat yaa! ✨',
          scheduledDate: reminderMorning,
          payload: 'task_${task.id}',
        );
      }
    } catch (_) {}
  }

  /// Jadwalkan pengingat jadwal kuliah mingguan (H-30 menit sebelum kelas)
  Future<void> scheduleClassReminder(ScheduleModel schedule) async {
    if (kIsWeb || schedule.id == null) return;

    try {
      final parts = schedule.startTime.split(':');
      if (parts.length < 2) return;
      final hour = int.tryParse(parts[0]) ?? 8;
      final minute = int.tryParse(parts[1]) ?? 0;

      // Cari tanggal hari terdekat sesuai dayOfWeek (0: Senin, 6: Minggu)
      final now = DateTime.now();
      // dayOfWeek di model: 0=Senin, 1=Selasa, dst. Di Dart weekday: 1=Senin, 7=Minggu
      final targetWeekday = schedule.dayOfWeek + 1;
      int daysAhead = targetWeekday - now.weekday;
      if (daysAhead < 0) {
        daysAhead += 7;
      }

      // Waktu kelas terdekat
      final classTime = DateTime(
        now.year,
        now.month,
        now.day + daysAhead,
        hour,
        minute,
      );

      // Pengingat 30 menit sebelum kelas
      final reminderTime = classTime.subtract(const Duration(minutes: 30));
      if (reminderTime.isAfter(now)) {
        await scheduleNotification(
          id: 1000 + schedule.id!,
          title: '📚 30 Menit Lagi Kelas: ${schedule.courseName}',
          body:
              'Pukul ${schedule.startTime} WIB di ${schedule.room}. Jangan sampai terlambat yaa! 🌸',
          scheduledDate: reminderTime,
          payload: 'schedule_${schedule.id}',
        );
      }
    } catch (_) {}
  }

  /// Batalkan notifikasi tertentu
  Future<void> cancelNotification(int id) async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }

  /// Batalkan seluruh notifikasi
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
