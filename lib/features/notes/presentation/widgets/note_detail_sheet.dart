import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/lecture_note_model.dart';
import 'add_note_sheet.dart';

/// Modal Bottom Sheet untuk membaca catatan kuliah secara penuh & lebar,
/// dilengkapi fitur Salin Teks, Edit Catatan, Sematkan (Pin), dan Hapus Catatan.
class NoteDetailSheet extends StatelessWidget {
  final LectureNoteModel note;
  final VoidCallback? onUpdated;

  const NoteDetailSheet({
    super.key,
    required this.note,
    this.onUpdated,
  });

  static Future<void> show(
    BuildContext context, {
    required LectureNoteModel note,
    VoidCallback? onUpdated,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NoteDetailSheet(note: note, onUpdated: onUpdated),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceContainerLowest,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.delete_forever_rounded, color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 10),
              Text(
                'Hapus Catatan?',
                style: AppTypography.headlineSm.copyWith(fontSize: 16),
              ),
            ],
          ),
          content: Text(
            'Catatan "${note.title}" akan dihapus permanen dari penyimpanan offline HP kamu.',
            style: AppTypography.bodyMd,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              onPressed: () {
                Navigator.pop(dialogCtx); // Tutup dialog
                Navigator.pop(context); // Tutup detail sheet
                if (note.id != null) {
                  SakuKuliahState.instance.deleteNote(note.id!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text('Catatan "${note.title}" berhasil dihapus 🗑️'),
                  ),
                );
                onUpdated?.call();
              },
              child: const Text('Hapus Catatan'),
            ),
          ],
        );
      },
    );
  }

  void _editNote(BuildContext context) {
    Navigator.pop(context); // Tutup sheet detail
    AddNoteSheet.show(
      context,
      noteToEdit: note,
      onSave: (updated) {
        SakuKuliahState.instance.updateNote(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan kuliah berhasil diperbarui! 🌸✨')),
        );
        onUpdated?.call();
      },
    );
  }

  void _copyToClipboard(BuildContext context) {
    final fullText = '${note.title}\n\nMata Kuliah: ${note.courseName}\nTanggal: ${note.createdDate}\n\n${note.content}';
    Clipboard.setData(ClipboardData(text: fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        content: const Text('Isi catatan berhasil disalin ke clipboard! 📋🌸'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPinned = note.isPinned;

    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Top Bar with Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        note.courseName,
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.onPrimaryFixed,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (isPinned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.push_pin, size: 12, color: AppColors.onSecondaryContainer),
                            const SizedBox(width: 4),
                            Text(
                              'Disematkan',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onSecondaryContainer,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    // Copy button
                    IconButton(
                      tooltip: 'Salin Teks Catatan',
                      icon: Icon(Icons.copy_rounded, size: 20, color: AppColors.primary),
                      onPressed: () => _copyToClipboard(context),
                    ),
                    // Edit button
                    IconButton(
                      tooltip: 'Edit Catatan',
                      icon: Icon(Icons.edit_outlined, size: 20, color: AppColors.onSurfaceVariant),
                      onPressed: () => _editNote(context),
                    ),
                    // Delete button
                    IconButton(
                      tooltip: 'Hapus Catatan',
                      icon: Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                      onPressed: () => _confirmDelete(context),
                    ),
                    // Close button
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.dividerColor),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta Info (Date & Read Time)
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        note.createdDate,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Icon(Icons.schedule_rounded, size: 13, color: AppColors.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        note.readTime ?? '3 mnt baca',
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  SelectableText(
                    note.title,
                    style: AppTypography.headlineSm.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),

                  // Tag List
                  if (note.tagList.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: note.tagList.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Text(
                            tag.startsWith('#') ? tag : '#$tag',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10.5,
                              color: AppColors.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Attachment box if exists
                  if (note.attachmentName != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.dividerColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.attachmentName!,
                                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  note.attachmentSize ?? 'Lampiran Dokumen',
                                  style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // Content Body Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.dividerColor),
                    ),
                    child: SelectableText(
                      note.content,
                      style: AppTypography.bodyMd.copyWith(
                        fontSize: 14.5,
                        height: 1.65,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bottom Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            side: BorderSide(color: AppColors.cardBorder),
                          ),
                          icon: Icon(Icons.copy_rounded, size: 16, color: AppColors.primary),
                          label: Text(
                            'Salin Semua Teks',
                            style: AppTypography.labelMd.copyWith(color: AppColors.primary),
                          ),
                          onPressed: () => _copyToClipboard(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.edit_rounded, size: 16),
                          label: Text(
                            'Edit Catatan',
                            style: AppTypography.labelMd.copyWith(color: Colors.white),
                          ),
                          onPressed: () => _editNote(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

