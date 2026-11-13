import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pastel_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../models/task_model.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../notes/presentation/widgets/add_note_sheet.dart';
import 'widgets/add_task_sheet.dart';

/// Halaman Daftar Tugas & Deadline dengan Filter Tab dan State Reaktif
class TaskListScreen extends StatefulWidget {
  final int initialViewMode;

  const TaskListScreen({super.key, this.initialViewMode = 0});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;
  int _selectedTabIndex = 0;
  late int _viewMode; // 0 = Daftar Tugas, 1 = Catatan Kuliah

  @override
  void initState() {
    super.initState();
    _viewMode = widget.initialViewMode;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final allTasks = _appState.tasks;
        final urgentTasks = allTasks.where((TaskModel t) => t.priority == 'Tinggi' && !t.isCompleted).toList();
        final pendingTasks = allTasks.where((TaskModel t) => !t.isCompleted).toList();
        final completedTasks = allTasks.where((TaskModel t) => t.isCompleted).toList();

        final tabs = [
          'Semua (${allTasks.length})',
          'Mendesak (${urgentTasks.length})',
          'Minggu Ini (${pendingTasks.length})',
          'Selesai (${completedTasks.length})',
        ];

        List<TaskModel> currentFilteredTasks;
        switch (_selectedTabIndex) {
          case 1:
            currentFilteredTasks = urgentTasks;
            break;
          case 2:
            currentFilteredTasks = pendingTasks;
            break;
          case 3:
            currentFilteredTasks = completedTasks;
            break;
          case 0:
          default:
            currentFilteredTasks = allTasks;
            break;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(_viewMode == 0 ? 'Daftar Tugas & Deadline' : 'Catatan & Materi Kuliah'),
            actions: [
              IconButton(
                tooltip: _viewMode == 0 ? 'Buka Catatan Kuliah' : 'Buka Daftar Tugas',
                icon: Icon(
                  _viewMode == 0 ? Icons.edit_note_rounded : Icons.checklist_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () {
                  setState(() {
                    _viewMode = _viewMode == 0 ? 1 : 0;
                  });
                },
              ),
              if (_viewMode == 0)
                IconButton(
                  tooltip: 'Tambah Tugas',
                  icon: const Icon(Icons.add_task_rounded, color: AppColors.primary),
                  onPressed: () {
                    AddTaskSheet.show(context, onSave: (task) {
                      _appState.addTask(task);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tugas baru berhasil ditambahkan! 💖')),
                      );
                    });
                  },
                )
              else
                IconButton(
                  tooltip: 'Tambah Catatan',
                  icon: const Icon(Icons.note_add_rounded, color: AppColors.primary),
                  onPressed: () {
                    AddNoteSheet.show(context, onSave: (note) {
                      _appState.addNote(note);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Catatan baru berhasil disimpan! 🌸')),
                      );
                    });
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              // Segmented Tab Switcher: Daftar Tugas vs Catatan Kuliah
              Container(
                margin: const EdgeInsets.fromLTRB(18, 8, 18, 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _viewMode = 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _viewMode == 0 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: _viewMode == 0
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 15,
                                color: _viewMode == 0 ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Daftar Tugas',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _viewMode == 0 ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _viewMode = 1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _viewMode == 1 ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(9999),
                            boxShadow: _viewMode == 1
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.25),
                                      blurRadius: 4,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_note_rounded,
                                size: 15,
                                color: _viewMode == 1 ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Catatan Kuliah',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _viewMode == 1 ? Colors.white : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // View content
              Expanded(
                child: _viewMode == 1
                    ? const NotesScreen(isEmbedded: true)
                    : SafeArea(
                        top: false,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Filter Tab Chips Horizontal
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(tabs.length, (index) {
                        final isSelected = _selectedTabIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(tabs[index]),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTabIndex = index;
                                });
                              }
                            },
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.surfaceContainerLow,
                            labelStyle: AppTypography.labelSm.copyWith(
                              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : const Color(0x33F4DCE4),
                              ),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (currentFilteredTasks.isEmpty)
                    PastelCard(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.task_alt_rounded, size: 36, color: AppColors.primary),
                            const SizedBox(height: 8),
                            Text(
                              'Tidak ada tugas pada filter ini 🌸',
                              style: AppTypography.headlineSm.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gunakan tombol + di kanan atas untuk membuat tugas baru.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...currentFilteredTasks.map((TaskModel task) {
                      final isUrgent = task.priority == 'Tinggi' && !task.isCompleted;
                      final totalSub = task.subtasks.length;
                      int completedSub = 0;
                      for (final SubtaskModel s in task.subtasks) {
                        if (s.isCompleted) {
                          completedSub++;
                        }
                      }
                      final double progress = totalSub > 0 ? (completedSub / totalSub) : 0.0;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PastelCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () => _appState.toggleTaskCompletion(task.id!),
                                child: AnimatedScale(
                                  scale: task.isCompleted ? 1.12 : 1.0,
                                  duration: const Duration(milliseconds: 220),
                                  curve: Curves.easeOutBack,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    margin: const EdgeInsets.only(top: 2),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: task.isCompleted ? AppColors.primary : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: task.isCompleted ? AppColors.primary : AppColors.outlineVariant,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 180),
                                      transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                      child: task.isCompleted
                                          ? const Icon(Icons.check_rounded, key: ValueKey('checked'), size: 16, color: Colors.white)
                                          : const SizedBox.shrink(key: ValueKey('unchecked')),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            isUrgent
                                                ? StatusBadge.urgent(label: 'Prioritas Tinggi')
                                                : StatusBadge.mediumPriority(label: 'Prioritas ${task.priority}'),
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondaryContainer,
                                                borderRadius: BorderRadius.circular(9999),
                                              ),
                                              child: Text(
                                                task.courseName,
                                                style: AppTypography.labelSm.copyWith(
                                                  fontSize: 10,
                                                  color: AppColors.onSecondaryContainer,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                          onPressed: () {
                                            _appState.deleteTask(task.id!);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Tugas berhasil dihapus')),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      task.title,
                                      style: AppTypography.headlineSm.copyWith(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                        color: task.isCompleted ? AppColors.outline : AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.alarm,
                                          size: 15,
                                          color: isUrgent ? AppColors.error : AppColors.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${task.dueDate} • ${task.dueTime}',
                                          style: AppTypography.labelSm.copyWith(
                                            fontSize: 11,
                                            color: isUrgent ? AppColors.error : AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.description_outlined, size: 14, color: AppColors.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.attachmentInfo ?? 'Berkas',
                                          style: AppTypography.bodySm.copyWith(fontSize: 11),
                                        ),
                                        const SizedBox(width: 10),
                                        const Icon(Icons.person_outline, size: 14, color: AppColors.onSurfaceVariant),
                                        const SizedBox(width: 4),
                                        Text(
                                          task.assignmentType,
                                          style: AppTypography.bodySm.copyWith(fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    if (totalSub > 0) ...[
                                      const SizedBox(height: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '$completedSub dari $totalSub subtugas selesai',
                                                style: AppTypography.labelSm.copyWith(
                                                  fontSize: 10,
                                                  color: AppColors.onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                '${(progress * 100).toInt()}%',
                                                style: AppTypography.labelSm.copyWith(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(9999),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 5,
                                              backgroundColor: AppColors.surfaceContainerHigh,
                                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
},
);
}
}
