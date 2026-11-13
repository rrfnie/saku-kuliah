import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../models/student_profile_model.dart';

/// Modal Bottom Sheet untuk Mengubah Data Profil & Foto Mahasiswa
class EditProfileSheet extends StatefulWidget {
  final StudentProfileModel currentProfile;
  final Function(StudentProfileModel) onSave;

  const EditProfileSheet({
    super.key,
    required this.currentProfile,
    required this.onSave,
  });

  static Future<void> show(
    BuildContext context, {
    required StudentProfileModel currentProfile,
    required Function(StudentProfileModel) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(
        currentProfile: currentProfile,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _nimController;
  late TextEditingController _universityController;
  late TextEditingController _majorController;
  late TextEditingController _facultyController;
  late int _selectedSemester;
  late String _selectedDegree;
  late String _selectedAcademicYear;
  late double _selectedTargetIpk;
  String? _avatarBase64;
  String? _avatarPreset;

  final List<String> _presetAvatars = ['👩‍🎓', '🌸', '🎀', '🐱', '☕', '🎓', '🧸', '✨'];
  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];
  final List<String> _academicYears = [
    '2026/2027 (Ganjil)',
    '2026/2027 (Genap)',
    '2027/2028 (Ganjil)',
    '2027/2028 (Genap)',
    '2028/2029 (Ganjil)',
    '2028/2029 (Genap)',
    '2029/2030 (Ganjil)',
    '2029/2030 (Genap)',
    '2030/2031 (Ganjil)',
    '2030/2031 (Genap)',
    '2025/2026 (Genap)',
    '2025/2026 (Ganjil)',
  ];
  final List<double> _targetIpks = [3.00, 3.25, 3.50, 3.75, 3.85, 3.90, 4.00];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentProfile.name);
    _nimController = TextEditingController(text: widget.currentProfile.nim);
    _universityController = TextEditingController(text: widget.currentProfile.university);
    _majorController = TextEditingController(text: widget.currentProfile.major);
    _facultyController = TextEditingController(text: widget.currentProfile.faculty);
    _selectedDegree = widget.currentProfile.degreeLevel;
    _selectedSemester = widget.currentProfile.currentSemester;
    _selectedAcademicYear = _academicYears.contains(widget.currentProfile.academicYear)
        ? widget.currentProfile.academicYear
        : _academicYears.first;
    _selectedTargetIpk = widget.currentProfile.targetIpk;
    _avatarBase64 = widget.currentProfile.avatarBase64;
    _avatarPreset = widget.currentProfile.avatarPreset;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _facultyController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarImage() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isNotEmpty) {
        final bytes = await files.first.xFile.readAsBytes();
        setState(() {
          _avatarBase64 = base64Encode(bytes);
          _avatarPreset = null;
        });
      }
    } catch (_) {}
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updated = widget.currentProfile.copyWith(
        name: _nameController.text.trim(),
        nim: _nimController.text.trim(),
        university: _universityController.text.trim(),
        major: _majorController.text.trim(),
        faculty: _facultyController.text.trim(),
        currentSemester: _selectedSemester,
        academicYear: _selectedAcademicYear,
        avatarBase64: _avatarBase64,
        avatarPreset: _avatarPreset,
        targetIpk: _selectedTargetIpk,
        degreeLevel: _selectedDegree,
        totalSks: _selectedDegree == 'D3'
            ? AppConstants.defaultSksTotalD3
            : AppConstants.defaultSksTotalS1,
      );

      widget.onSave(updated);
      Navigator.pop(context);
    }
  }

  Widget _buildAvatarPreview() {
    if (_avatarBase64 != null && _avatarBase64!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_avatarBase64!),
          gaplessPlayback: true,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (_) {}
    }
    if (_avatarPreset != null && _avatarPreset!.isNotEmpty) {
      return Center(
        child: Text(
          _avatarPreset!,
          style: const TextStyle(fontSize: 38),
        ),
      );
    }
    final initial = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim().substring(0, 1).toUpperCase()
        : 'N';
    return Center(
      child: Text(
        initial,
        style: const TextStyle(
          color: AppColors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab Handle
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
              const SizedBox(height: 14),

              // Sheet Header
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
                          Icons.person_rounded,
                          size: 18,
                          color: AppColors.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Edit Profil & Foto Mahasiswa',
                        style: AppTypography.headlineSm.copyWith(
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // FOTO PROFIL SECTION
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickAvatarImage,
                          child: Container(
                            width: 82,
                            height: 82,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryContainer,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x22805063),
                                  blurRadius: 12,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildAvatarPreview(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAvatarImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tombol Pilih Foto dari Galeri
                    InkWell(
                      onTap: _pickAvatarImage,
                      borderRadius: BorderRadius.circular(9999),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library_rounded, size: 15, color: AppColors.primary),
                            const SizedBox(width: 5),
                            Text(
                              'Pilih Foto dari Galeri / File',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Avatar Emoji Presets
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ..._presetAvatars.map((emoji) {
                            final isSelected = _avatarPreset == emoji;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _avatarPreset = emoji;
                                  _avatarBase64 = null;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.primaryContainer
                                      : AppColors.surfaceContainerLow,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(emoji, style: const TextStyle(fontSize: 16)),
                              ),
                            );
                          }),
                          if (_avatarBase64 != null || _avatarPreset != null)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _avatarBase64 = null;
                                  _avatarPreset = null;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(9999),
                                  color: AppColors.surfaceContainerLow,
                                ),
                                child: Text(
                                  'Reset',
                                  style: AppTypography.labelSm.copyWith(
                                    fontSize: 10,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nama Lengkap
              Text('Nama Lengkap', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Amanda Putri',
                  prefixIcon: Icon(Icons.badge_outlined, size: 18),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nama lengkap wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // NIM & Program Studi
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('NIM Mahasiswa', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _nimController,
                          decoration: const InputDecoration(
                            hintText: '2201010045',
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty) ? 'NIM wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Program Studi', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _majorController,
                          decoration: const InputDecoration(
                            hintText: 'Teknik Informatika',
                          ),
                          validator: (val) =>
                              (val == null || val.trim().isEmpty) ? 'Prodi wajib diisi' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Perguruan Tinggi / Kampus
              Text('Universitas / Kampus', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _universityController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Politeknik Sekayu',
                  prefixIcon: Icon(Icons.school_outlined, size: 18),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Nama kampus wajib diisi' : null,
              ),
              const SizedBox(height: 12),

              // Fakultas (Opsional)
              Text('Fakultas (Opsional)', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              TextFormField(
                controller: _facultyController,
                decoration: const InputDecoration(
                  hintText: 'Bisa dikosongkan jika tidak ada fakultas',
                  prefixIcon: Icon(Icons.apartment_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 12),

              // Jenjang Program Studi (D3 vs S1 / D4)
              Text('Jenjang Program Kuliah', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedDegree,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.school_outlined, size: 18),
                ),
                items: const [
                  DropdownMenuItem(value: 'D3', child: Text('D3 (Diploma 3 • 6 Semester)')),
                  DropdownMenuItem(value: 'S1', child: Text('S1 (Sarjana • 8 Semester)')),
                  DropdownMenuItem(value: 'D4', child: Text('D4 (Sarjana Terapan • 8 Semester)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedDegree = val);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Tahun Akademik
              Text('Tahun Akademik & Semester', style: AppTypography.labelMd),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedAcademicYear,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.date_range_outlined, size: 18),
                ),
                items: _academicYears.map((ay) {
                  return DropdownMenuItem(
                    value: ay,
                    child: Text(ay),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedAcademicYear = val);
                  }
                },
              ),
              const SizedBox(height: 12),

              // Semester & Target IPK
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Semester Sekarang', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<int>(
                          value: _selectedSemester,
                          decoration: const InputDecoration(),
                          items: _semesters.map((s) {
                            return DropdownMenuItem(
                              value: s,
                              child: Text('Semester $s'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedSemester = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Target IPK', style: AppTypography.labelMd),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<double>(
                          value: _selectedTargetIpk,
                          decoration: const InputDecoration(),
                          items: _targetIpks.map((ipk) {
                            return DropdownMenuItem(
                              value: ipk,
                              child: Text(ipk.toStringAsFixed(2)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedTargetIpk = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Submit Button
              PastelButton(
                text: 'Simpan Profil 🌸',
                width: double.infinity,
                trailingIcon: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
