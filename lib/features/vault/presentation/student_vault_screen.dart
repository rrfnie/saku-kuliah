import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/pastel_button.dart';
import '../../../core/widgets/pastel_card.dart';
import '../models/student_document_model.dart';
import 'widgets/add_document_sheet.dart';

class StudentVaultScreen extends StatefulWidget {
  const StudentVaultScreen({super.key});

  @override
  State<StudentVaultScreen> createState() => _StudentVaultScreenState();
}

class _StudentVaultScreenState extends State<StudentVaultScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Semua';

  final List<String> _categoryFilters = [
    'Semua',
    'Identitas',
    'Akademik',
    'Keuangan',
    'Sertifikat',
    'Skripsi / Riset',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$label berhasil disalin ke clipboard! 📋✨',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentPreview(StudentDocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 16, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                doc.fileType == 'image' ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${doc.category} • ${doc.fileSize}',
                    style: AppTypography.bodySm.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (doc.fileType == 'image' && doc.base64Data != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  width: double.infinity,
                  color: AppColors.surfaceContainerLow,
                  child: Image.memory(
                    base64Decode(doc.base64Data!),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0x22F4DCE4)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf_rounded, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 8),
                    Text(
                      doc.fileName,
                      style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Berkas PDF tersimpan aman di memori lokal SakuKuliah',
                      style: AppTypography.bodySm.copyWith(fontSize: 11, color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (doc.documentNumber != null && doc.documentNumber!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pin_rounded, size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Nomor: ${doc.documentNumber!}',
                        style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    InkWell(
                      onTap: () => _copyToClipboard(doc.documentNumber!, 'Nomor Dokumen'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Salin', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (doc.notes != null && doc.notes!.isNotEmpty) ...[
              Text(
                'Catatan: ${doc.notes!}',
                style: AppTypography.bodySm.copyWith(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit Dokumen'),
            onPressed: () {
              Navigator.pop(ctx);
              AddDocumentSheet.show(context, documentToEdit: doc);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDelete(StudentDocumentModel doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Dokumen?'),
        content: Text('Apakah kamu yakin ingin menghapus "${doc.title}" dari brankas? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              SakuKuliahState.instance.deleteDocument(doc.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red.shade700,
                  content: Text('Dokumen "${doc.title}" telah dihapus.'),
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SakuKuliahState.instance,
      builder: (context, _) {
        final allDocs = SakuKuliahState.instance.documents;

        // Filtering
        final filteredDocs = allDocs.where((doc) {
          final matchesCategory = _selectedCategory == 'Semua' || doc.category == _selectedCategory;
          final matchesSearch = _searchQuery.isEmpty ||
              doc.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (doc.documentNumber != null && doc.documentNumber!.toLowerCase().contains(_searchQuery.toLowerCase())) ||
              doc.fileName.toLowerCase().contains(_searchQuery.toLowerCase());
          return matchesCategory && matchesSearch;
        }).toList();

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.onSurface),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Brankas Dokumen Mahasiswa',
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                tooltip: 'Tambah Dokumen',
                onPressed: () => AddDocumentSheet.show(context),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Search Bar & Filter Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: Column(
                    children: [
                      // Search Input
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x22F4DCE4)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val.trim();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari nama berkas, KTP, KTM, atau NIM...',
                            hintStyle: AppTypography.bodySm.copyWith(
                              color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                            ),
                            prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.primary),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Horizontal Scroll
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categoryFilters.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedCategory = cat;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? AppColors.primary : const Color(0x22F4DCE4),
                                    ),
                                  ),
                                  child: Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      color: isSelected ? Colors.white : AppColors.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Vault Security Info Strip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, size: 16, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '100% Offline • Dokumen tersimpan privat di perangkatmu tanpa server luar',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 10.5,
                              color: AppColors.onPrimaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${allDocs.length} Berkas',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Document List / Empty State
                Expanded(
                  child: filteredDocs.isEmpty
                      ? _buildEmptyState(allDocs.isEmpty)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 6, 20, 80),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredDocs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, idx) {
                            final doc = filteredDocs[idx];
                            return _buildDocumentCard(doc);
                          },
                        ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 3,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Unggah Dokumen 🌸', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () => AddDocumentSheet.show(context),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isCompletelyEmpty) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🗄️', style: TextStyle(fontSize: 38)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isCompletelyEmpty ? 'Brankas Dokumen Masih Kosong' : 'Tidak Ditemukan',
              style: AppTypography.headlineSm.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              isCompletelyEmpty
                  ? 'Simpan berkas pentingmu seperti scan KTP, KTM, Transkrip Nilai, dan Sertifikat TOEFL agar tidak tercecer dan siap disalin/dibagikan kapan saja!'
                  : 'Tidak ada dokumen yang cocok dengan kata kunci atau filter yang kamu pilih.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            if (isCompletelyEmpty)
              PastelButton(
                text: '+ Tambah Dokumen Pertama 🌸',
                width: 260,
                onPressed: () => AddDocumentSheet.show(context),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(StudentDocumentModel doc) {
    Color categoryColor = AppColors.primary;
    IconData categoryIcon = Icons.badge_rounded;

    switch (doc.category) {
      case 'Identitas':
        categoryColor = const Color(0xFF6B5A60);
        categoryIcon = Icons.badge_rounded;
        break;
      case 'Akademik':
        categoryColor = const Color(0xFF805063);
        categoryIcon = Icons.school_rounded;
        break;
      case 'Keuangan':
        categoryColor = const Color(0xFF880E4F);
        categoryIcon = Icons.account_balance_wallet_rounded;
        break;
      case 'Sertifikat':
        categoryColor = const Color(0xFFD87D4A);
        categoryIcon = Icons.workspace_premium_rounded;
        break;
      case 'Skripsi / Riset':
        categoryColor = const Color(0xFF2E7D32);
        categoryIcon = Icons.menu_book_rounded;
        break;
    }

    return PastelCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Category Pill & Options
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(categoryIcon, size: 13, color: categoryColor),
                    const SizedBox(width: 5),
                    Text(
                      doc.category,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Favorite Star Toggle
              InkWell(
                onTap: () => SakuKuliahState.instance.toggleDocumentFavorite(doc.id),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    doc.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: doc.isFavorite ? Colors.amber.shade700 : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Menu Options Popup
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.onSurfaceVariant),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                onSelected: (val) {
                  if (val == 'edit') {
                    AddDocumentSheet.show(context, documentToEdit: doc);
                  } else if (val == 'delete') {
                    _confirmDelete(doc);
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit Dokumen', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(fontSize: 12, color: Colors.red.shade700)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Document Title & File Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0x18F4DCE4)),
                ),
                child: Center(
                  child: Icon(
                    doc.fileType == 'image' ? Icons.image_rounded : Icons.picture_as_pdf_rounded,
                    color: doc.fileType == 'image' ? AppColors.secondary : Colors.redAccent,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: AppTypography.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${doc.fileName} • ${doc.fileSize} • Ditambahkan ${doc.dateAdded}',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 10.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Document Number Quick Copy Pill
          if (doc.documentNumber != null && doc.documentNumber!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x22F4DCE4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.pin_rounded, size: 15, color: AppColors.secondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      doc.documentNumber!,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _copyToClipboard(doc.documentNumber!, 'Nomor'),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.copy_rounded, size: 12, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            'Salin',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Notes Callout
          if (doc.notes != null && doc.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Catatan: ${doc.notes!}',
                style: AppTypography.bodySm.copyWith(
                  fontSize: 10.5,
                  fontStyle: FontStyle.italic,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0x18F4DCE4)),
          const SizedBox(height: 10),

          // Bottom Action Row
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: Color(0x33F4DCE4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.primary),
                label: const Text('Buka Dokumen', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                onPressed: () => _showDocumentPreview(doc),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.onSurfaceVariant),
                label: const Text('Edit', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
                onPressed: () => AddDocumentSheet.show(context, documentToEdit: doc),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
