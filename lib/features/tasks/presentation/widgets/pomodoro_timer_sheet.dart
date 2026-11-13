import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

/// Modal Mode Ambis Belajar (Pomodoro Focus Timer) Pastel untuk Mahasiswa
class PomodoroTimerSheet extends StatefulWidget {
  const PomodoroTimerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PomodoroTimerSheet(),
    );
  }

  @override
  State<PomodoroTimerSheet> createState() => _PomodoroTimerSheetState();
}

class _PomodoroTimerSheetState extends State<PomodoroTimerSheet> {
  // Timer modes: 25 mins focus (1500s) or 5 mins break (300s)
  bool _isBreakMode = false;
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;
  int _completedSessions = 0;

  final List<String> _subjects = [
    'Tugas Kuliah Umum 📚',
    'Desain Antarmuka & UX 🎨',
    'Sistem Kecerdasan Buatan 🤖',
    'Metodologi Penelitian TI 📝',
    'Pemrograman Web Lanjut 💻',
    'Review Materi Ujian 🌸',
  ];
  late String _selectedSubject;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 25 * 60;
    _selectedSubject = _subjects.first;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          if (!_isBreakMode) {
            _completedSessions++;
            _isBreakMode = true;
            _remainingSeconds = 5 * 60;
            _showCompletionDialog(
              title: 'Sesi Belajar Selesai! 🎉🌸',
              message: 'Hebat banget ${_getUserFirstName()}! Sesi fokus berhasil diselesaikan. Sekarang rileks dan istirahat 5 menit ya 🥰✨',
            );
          } else {
            _isBreakMode = false;
            _remainingSeconds = 25 * 60;
            _showCompletionDialog(
              title: 'Waktu Istirahat Selesai! ☕',
              message: 'Siap mulai fokus belajar sesi berikutnya? Semangat ya ${_getUserFirstName()}! 💖',
            );
          }
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _isBreakMode ? 5 * 60 : 25 * 60;
    });
  }

  void _switchMode(bool isBreak) {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isBreakMode = isBreak;
      _remainingSeconds = isBreak ? 5 * 60 : 25 * 60;
    });
  }

  void _showCompletionDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: AppTypography.headlineSm.copyWith(fontSize: 16)),
          content: Text(message, style: AppTypography.bodyMd),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Lanjut! ✨'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final totalTarget = _isBreakMode ? (5 * 60) : (25 * 60);
    final progress = 1.0 - (_remainingSeconds / totalTarget);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.hourglass_top_rounded,
                      size: 18,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mode Ambis Belajar (Pomodoro)',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Teknik Fokus 25 Menit + 5 Menit Rehat',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const Divider(height: 18, color: Color(0x22F4DCE4)),

          // Mode Selector Tabs (Fokus vs Rehat)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchMode(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isBreakMode ? AppColors.primary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Center(
                      child: Text(
                        '🎯 Fokus Belajar (25m)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: !_isBreakMode ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => _switchMode(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isBreakMode ? AppColors.secondary : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Center(
                      child: Text(
                        '☕ Rehat Santai (5m)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _isBreakMode ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Subject Selection
          DropdownButtonFormField<String>(
            initialValue: _selectedSubject,
            isDense: true,
            decoration: InputDecoration(
              labelText: 'Mata Kuliah / Target Belajar',
              labelStyle: AppTypography.labelSm,
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: _subjects.map((sub) {
              return DropdownMenuItem(value: sub, child: Text(sub, style: AppTypography.bodySm));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedSubject = val);
            },
          ),

          const SizedBox(height: 20),

          // Circular Countdown Timer Display
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: const Color(0x33F4DCE4),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _isBreakMode ? AppColors.secondary : AppColors.primary,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(_remainingSeconds),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppColors.onSurface,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _isBreakMode ? AppColors.secondaryContainer : AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        _isBreakMode ? 'Waktu Rehat ☕' : 'Fokus Ambis 🌸',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _isBreakMode ? AppColors.onSecondaryContainer : AppColors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Dynamic Motivational Message for Student
          Text(
            _isBreakMode
                ? 'Waktunya rehat manis! Minum air putih atau teh dulu ya ${_getUserFirstName()} ☕💖'
                : 'Semangat belajarnya ${_getUserFirstName()}! Sedikit lagi selesai, masa depan cerah menanti 🌸✨',
            textAlign: TextAlign.center,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
              fontSize: 11.5,
            ),
          ),

          const SizedBox(height: 18),

          // Control Action Buttons (Start/Pause, Reset)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurfaceVariant,
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                onPressed: _resetTimer,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Reset', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? const Color(0xFFE57373) : AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
                  elevation: 4,
                ),
                onPressed: _toggleTimer,
                icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                label: Text(
                  _isRunning ? 'Jeda Dulu' : 'Mulai Ambis! ✨',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Completed Session Pill
          if (_completedSessions > 0)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
              ),
              child: Text(
                '🎉 $_completedSessions Sesi Fokus Selesai Hari Ini! Keren banget ${_getUserFirstName()}!',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getUserFirstName() {
    try {
      final name = SakuKuliahState.instance.studentProfile.name.trim();
      if (name.isEmpty) return 'Sobat Kuliah';
      return name.split(' ').first;
    } catch (_) {
      return 'Sobat Kuliah';
    }
  }
}

