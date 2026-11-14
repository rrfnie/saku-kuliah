import 'package:flutter/material.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pastel_card.dart';
import '../models/lecture_note_model.dart';
import 'widgets/add_note_sheet.dart';
import 'widgets/note_detail_sheet.dart';

/// Halaman Catatan Kuliah dan Materi Perkuliahan dengan State Reaktif,
/// membaca catatan penuh/lebar, menyunting, dan menghapus catatan.
class NotesScreen extends StatefulWidget {
  final bool isEmbedded;

  const NotesScreen({super.key, this.isEmbedded = false});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final SakuKuliahState _appState = SakuKuliahState.instance;
  int _selectedFilterIndex = 0;
  String _searchQuery = '';

  void _openNoteDetail(LectureNoteModel note) {
    NoteDetailSheet.show(
      context,
      note: note,
      onUpdated: () => setState(() {}),
    );
  }

  void _confirmDeleteNote(LectureNoteModel note) {
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
                Navigator.pop(dialogCtx);
                if (note.id != null) {
                  _appState.deleteNote(note.id!);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.error,
                    content: Text('Catatan "${note.title}" berhasil dihapus 🗑️'),
                  ),
                );
              },
              child: const Text('Hapus Catatan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNoteCard(LectureNoteModel note, {required bool isPinned}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: PastelCard(
        onTap: () => _openNoteDetail(note),
        accentColor: isPinned ? AppColors.primary : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Subject, Date, Pin & Delete actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isPinned ? AppColors.secondaryFixed : AppColors.primaryFixed,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            note.courseName,
                            style: AppTypography.labelSm.copyWith(
                              color: isPinned ? AppColors.onSecondaryFixedVariant : AppColors.onPrimaryFixed,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        note.createdDate,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pin toggle button
                    IconButton(
                      tooltip: isPinned ? 'Lepas Pin' : 'Sematkan di Atas',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 17,
                        color: isPinned ? AppColors.primary : AppColors.onSurfaceVariant,
                      ),
                      onPressed: () {
                        if (note.id != null) {
                          _appState.togglePinNote(note.id!);
                        }
                      },
                    ),
                    const SizedBox(width: 2),
                    // Delete button
                    IconButton(
                      tooltip: 'Hapus Catatan',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 17,
                        color: AppColors.error,
                      ),
                      onPressed: () => _confirmDeleteNote(note),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Note Title
            Text(
              note.title,
              style: AppTypography.headlineSm.copyWith(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),

            // Note Content Snippet
            Text(
              note.content,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.45,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Bottom Info Row & Read Full Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tags or Attachment
                Expanded(
                  child: Row(
                    children: [
                      if (note.attachmentName != null) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.picture_as_pdf_outlined, size: 12, color: AppColors.error),
                              const SizedBox(width: 3),
                              Text(
                                note.attachmentName!,
                                style: AppTypography.labelSm.copyWith(
                                  fontSize: 9.5,
                                  color: AppColors.onSecondaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                      if (note.tagList.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            note.tagList.first.startsWith('#') ? note.tagList.first : '#${note.tagList.first}',
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 9.5,
                              color: AppColors.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Tap to view full hint
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buka Catatan',
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appState,
      builder: (context, _) {
        final allNotes = _appState.notes;

        // Build dynamic filters list
        final List<String> filters = ['Semua Catatan'];
        for (final n in allNotes) {
          if (n.courseName.isNotEmpty && !filters.contains(n.courseName)) {
            filters.add(n.courseName);
          }
        }
        if (_selectedFilterIndex >= filters.length) {
          _selectedFilterIndex = 0;
        }

        // Filter by category chip
        final categoryFiltered = _selectedFilterIndex == 0
            ? allNotes
            : allNotes.where((LectureNoteModel n) => n.courseName.toLowerCase() == filters[_selectedFilterIndex].toLowerCase()).toList();

        // Filter by search query
        final notes = _searchQuery.isEmpty
            ? categoryFiltered
            : categoryFiltered.where((LectureNoteModel n) {
                return n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    n.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    n.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    (n.tags != null && n.tags!.toLowerCase().contains(_searchQuery.toLowerCase()));
              }).toList();

        final pinnedNotes = notes.where((LectureNoteModel n) => n.isPinned).toList();
        final unpinnedNotes = notes.where((LectureNoteModel n) => !n.isPinned).toList();

        final body = SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: TextField(
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Cari catatan kuliah, materi, dosen...',
                      hintStyle: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                      prefixIcon: Icon(Icons.search, color: AppColors.outline),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => setState(() => _searchQuery = ''),
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Filter Chips Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(filters.length, (index) {
                      final isSelected = _selectedFilterIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filters[index]),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedFilterIndex = index;
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
                              color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 18),

                // Pinned Note Section Header
                if (pinnedNotes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.push_pin, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            'CATATAN DISEMATKAN',
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Text(
                          '${pinnedNotes.length} Catatan Penting',
                          style: AppTypography.labelSm.copyWith(
                            fontSize: 9.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  ...pinnedNotes.map((note) => _buildNoteCard(note, isPinned: true)),
                  const SizedBox(height: 14),
                ],

                // Recent Notes Stream Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Catatan Kuliah',
                      style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${notes.length} total',
                      style: AppTypography.labelSm.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (unpinnedNotes.isEmpty && pinnedNotes.isEmpty)
                  PastelCard(
                    padding: const EdgeInsets.all(28),
                    child: Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.menu_book_rounded, size: 36, color: AppColors.primary),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada catatan kuliah 🌸',
                            style: AppTypography.headlineSm.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Tekan tombol + di atas untuk mencatat rangkuman materi dosen, rumus, atau kisi-kisi ujian.',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodySm.copyWith(color: AppColors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Buat Catatan Sekarang'),
                            onPressed: () {
                              AddNoteSheet.show(context, onSave: (newNote) {
                                _appState.addNote(newNote);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Catatan kuliah berhasil disimpan! 🌸✨')),
                                );
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...unpinnedNotes.map((note) => _buildNoteCard(note, isPinned: false)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );

        if (widget.isEmbedded) {
          return body;
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text('Catatan & Materi Kuliah'),
            actions: [
              IconButton(
                tooltip: 'Tambah Catatan Baru',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.note_add_rounded, size: 20, color: AppColors.onPrimaryContainer),
                ),
                onPressed: () {
                  AddNoteSheet.show(context, onSave: (note) {
                    _appState.addNote(note);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catatan kuliah berhasil disimpan! 🌸✨')),
                    );
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text('Tulis Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              AddNoteSheet.show(context, onSave: (note) {
                _appState.addNote(note);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan kuliah berhasil disimpan! 🌸✨')),
                );
              });
            },
          ),
          body: body,
        );
      },
    );
  }
}
