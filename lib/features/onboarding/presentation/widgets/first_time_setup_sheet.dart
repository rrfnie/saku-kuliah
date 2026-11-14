import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/state/app_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/pastel_button.dart';
import '../../../profile/models/student_profile_model.dart';

/// Modal Bottom Sheet "Kenalan Dulu Yuk" saat pertama kali membuka aplikasi
/// Memungkinkan pengguna baru mengisi nama, kampus, jurusan, dan avatar mereka
class FirstTimeSetupSheet extends StatefulWidget {
  final VoidCallback onComplete;

  const FirstTimeSetupSheet({
    super.key,
    required this.onComplete,
  });

  static Future<void> show(
    BuildContext context, {
    required VoidCallback onComplete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FirstTimeSetupSheet(onComplete: onComplete),
    );
  }

  @override
  State<FirstTimeSetupSheet> createState() => _FirstTimeSetupSheetState();
}

class _FirstTimeSetupSheetState extends State<FirstTimeSetupSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _majorController = TextEditingController();

  int _selectedSemester = 1;
  String _selectedDegree = 'D3';
  String _selectedAvatar = '🌸';

  final List<String> _avatarPresets = [
    '🌸',
    '👩‍🎓',
    '🎀',
    '🐱',
    '☕',
    '🎓',
    '🧸',
    '✨',
  ];

  final List<int> _semesters = [1, 2, 3, 4, 5, 6, 7, 8];

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  void _saveAndProceed() {
    final name = _nameController.text.trim();
    final univ = _universityController.text.trim();
    final major = _majorController.text.trim();

    final currentProfile = SakuKuliahState.instance.studentProfile;
    final updatedProfile = StudentProfileModel(
      name: name.isNotEmpty ? name : AppConstants.defaultUserName,
      nim: currentProfile.nim,
      major: major.isNotEmpty ? major : AppConstants.defaultMajor,
      faculty: currentProfile.faculty,
      university: univ.isNotEmpty ? univ : AppConstants.defaultUniversity,
      currentSemester: _selectedSemester,
      academicYear: currentProfile.academicYear,
      targetIpk: currentProfile.targetIpk,
      cumulativeIpk: currentProfile.cumulativeIpk,
      completedSks: currentProfile.completedSks,
      totalSks: _selectedDegree == 'D3'
          ? AppConstants.defaultSksTotalD3
          : AppConstants.defaultSksTotalS1,
      degreeLevel: _selectedDegree,
      avatarBase64: null,
      avatarPreset: _selectedAvatar,
    );

    SakuKuliahState.instance.updateStudentProfile(updatedProfile);
    Navigator.pop(context); // Close bottom sheet
    widget.onComplete(); // Navigate to main app
  }

  void _skipAndProceed() {
    Navigator.pop(context);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Sambutan
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kenalan Dulu Yuk! 🌸✨',
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Biar SakuKuliah bisa memanggil namamu & menemani harimu',
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11.5,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // 1. Pilih Avatar
                Text(
                  'Pilih Avatar Maskotmu',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _avatarPresets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, idx) {
                      final emoji = _avatarPresets[idx];
                      final isSelected = _selectedAvatar == emoji;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = emoji;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(emoji, style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Input Nama Lengkap / Panggilan
                Text(
                  'Nama Panggilan / Lengkap',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Misal: Noemi / Amanda / Budi',
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Input Kampus
                Text(
                  'Asal Kampus / Universitas',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _universityController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Misal: Universitas Indonesia, ITB, dsb',
                    prefixIcon: Icon(Icons.account_balance_outlined, size: 20),
                  ),
                ),

                const SizedBox(height: 14),

                // 4. Input Program Studi / Jurusan
                Text(
                  'Program Studi / Jurusan',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _majorController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Misal: Teknik Informatika, Manajemen, dsb',
                    prefixIcon: Icon(Icons.school_outlined, size: 20),
                  ),
                ),

                const SizedBox(height: 14),

                // Jenjang Program Kuliah
                Text(
                  'Jenjang Program Kuliah',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDegree = 'D3';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedDegree == 'D3'
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDegree == 'D3' ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '🎓 Program D3 (6 Sem)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: _selectedDegree == 'D3' ? FontWeight.bold : FontWeight.w500,
                                color: _selectedDegree == 'D3' ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedDegree = 'S1';
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: _selectedDegree == 'S1'
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedDegree == 'S1' ? AppColors.primary : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '🎓 Program S1 (8 Sem)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: _selectedDegree == 'S1' ? FontWeight.bold : FontWeight.w500,
                                color: _selectedDegree == 'S1' ? AppColors.primary : AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 5. Semester Saat Ini
                Text(
                  'Semester Saat Ini',
                  style: AppTypography.labelMd.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _semesters.map((sem) {
                    final isSelected = _selectedSemester == sem;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSemester = sem;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'Sem $sem',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.onSurface,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // Tombol Aksi Simpan & Lewati
                PastelButton(
                  text: 'Simpan & Mulai Kuliah! 🚀',
                  width: double.infinity,
                  height: 48,
                  trailingIcon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  onPressed: _saveAndProceed,
                ),
                const SizedBox(height: 6),
                PastelButton(
                  text: 'Nanti Saja (Isi Nanti di Profil)',
                  type: PastelButtonType.ghost,
                  height: 38,
                  onPressed: _skipAndProceed,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

