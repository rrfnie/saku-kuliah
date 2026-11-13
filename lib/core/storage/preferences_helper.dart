import 'package:shared_preferences/shared_preferences.dart';

/// Helper SharedPreferences untuk pengaturan ringan offline
class PreferencesHelper {
  static const String _keyOnboardingDone = 'key_onboarding_done';
  static const String _keyClassReminder = 'key_class_reminder';
  static const String _keyTaskReminder = 'key_task_reminder';

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone(bool isDone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, isDone);
  }

  static Future<bool> isClassReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyClassReminder) ?? true;
  }

  static Future<void> setClassReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyClassReminder, enabled);
  }

  static Future<bool> isTaskReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTaskReminder) ?? true;
  }

  static Future<void> setTaskReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTaskReminder, enabled);
  }
}

