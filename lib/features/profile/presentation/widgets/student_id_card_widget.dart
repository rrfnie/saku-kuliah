import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../models/student_profile_model.dart';

/// Kartu Tanda Mahasiswa (KTM) Digital Pastel Interaktif
class StudentIdCardWidget extends StatefulWidget {
  final StudentProfileModel profile;
  final VoidCallback? onEditProfile;

  const StudentIdCardWidget({
    super.key,
    required this.profile,
    this.onEditProfile,
  });

  @override
  State<StudentIdCardWidget> createState() => _StudentIdCardWidgetState();
}

class _StudentIdCardWidgetState extends State<StudentIdCardWidget> with SingleTickerProviderStateMixin {
  bool _showBack = false;

  void _flipCard() {
    setState(() {
      _showBack = !_showBack;
    });
  }

  void _showFullScreenCard(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, size: 20, color: AppColors.primary),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(height: 8),
              _buildCardContainer(isDialog: true),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.profile.nim));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('NIM berhasil disalin ke clipboard! 📋✨')),
                      );
                    },
                    icon: const Icon(Icons.copy_rounded, size: 16),
                    label: const Text('Salin NIM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _flipCard();
                    },
                    icon: const Icon(Icons.flip_to_back_rounded, size: 16),
                    label: Text(_showBack ? 'Lihat Depan' : 'Balik Kartu', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.badge_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Kartu Mahasiswa (KTM Digital)',
                  style: AppTypography.labelLg.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            GestureDetector(
              onTap: _flipCard,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(9999),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sync_rounded, size: 13, color: AppColors.onPrimaryContainer),
                    const SizedBox(width: 4),
                    Text(
                      _showBack ? 'Lihat Depan' : 'Putar Kartu',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => _showFullScreenCard(context),
          child: _buildCardContainer(isDialog: false),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required bool isDialog}) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, animation) {
        return RotationTransition(
          turns: animation.drive(Tween<double>(begin: 0.05, end: 0.0)),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: _showBack
          ? _buildBackCard(key: const ValueKey('back'), isDialog: isDialog)
          : _buildFrontCard(key: const ValueKey('front'), isDialog: isDialog),
    );
  }

  Widget _buildFrontCard({required Key key, required bool isDialog}) {
    final p = widget.profile;

    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerLowest,
            AppColors.primaryContainer.withValues(alpha: 0.35),
            AppColors.secondaryContainer.withValues(alpha: 0.35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Stack(
        children: [
          // Background Decorative Shimmer Watermark
          Positioned(
            right: -24,
            bottom: -24,
            child: Opacity(
              opacity: 0.08,
              child: Icon(
                Icons.school_rounded,
                size: 160,
                color: AppColors.primary,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Row: University Name & Microchip Hologram
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // University Header Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.university.trim().isEmpty ? 'UNIVERSITAS BELUM DIATUR' : p.university.toUpperCase(),
                            style: AppTypography.labelSm.copyWith(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: 0.8,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Row(
                            children: [
                              Text(
                                'KARTU TANDA MAHASISWA',
                                style: AppTypography.bodySm.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurfaceVariant,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFFA5D6A7), width: 0.8),
                                ),
                                child: const Text(
                                  'OFFLINE ID',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Logo Aplikasi SakuKuliah
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.school_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Divider(height: 18, color: AppColors.dividerColor),

                // Middle Row: Photo + Student Information
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo Box
                    Container(
                      width: 68,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryContainer, width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F805063),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildIdCardPhoto(p),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Info Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name.trim().isEmpty ? 'Nama Belum Diisi' : p.name,
                            style: AppTypography.headlineSm.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: p.name.trim().isEmpty ? AppColors.onSurfaceVariant : const Color(0xFF332F31),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              p.nim.trim().isEmpty ? 'NIM: -' : 'NIM: ${p.nim}',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w800,
                                fontSize: 11.5,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.major.trim().isEmpty ? 'Program Studi Belum Diatur' : p.major,
                            style: AppTypography.bodySm.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (p.faculty.trim().isNotEmpty)
                            Text(
                              p.faculty,
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Mahasiswa Aktif • Sem ${p.currentSemester}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Bottom Row: Stylized Barcode & Validity
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Stylized Barcode
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStylizedBarcode(p.nim),
                        const SizedBox(height: 2),
                        Text(
                          'ID: SAKU-${p.nim}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 8.5,
                            letterSpacing: 1.2,
                            color: Color(0xFF7A6B72),
                          ),
                        ),
                      ],
                    ),

                    // Validity & Academic Year
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Tahun Akademik',
                          style: TextStyle(
                            fontSize: 8.5,
                            color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          p.academicYear,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard({required Key key, required bool isDialog}) {
    final p = widget.profile;

    return Container(
      key: key,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceContainerLowest,
            AppColors.secondaryContainer.withValues(alpha: 0.35),
            AppColors.primaryContainer.withValues(alpha: 0.35),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white, width: 2),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Magnetic Stripe Look
          Container(
            height: 32,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF3E3639),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simulated QR Code
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.cardBorder, width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 4),
                  ],
                ),
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _qrSquare(),
                        _qrDot(),
                        _qrSquare(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _qrDot(),
                        _qrDot(),
                        _qrDot(),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _qrSquare(),
                        _qrDot(),
                        _qrDot(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Card Usage Rules
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ketentuan Kartu Mahasiswa:',
                      style: AppTypography.labelSm.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1. Kartu ini sah digunakan sebagai tanda pengenal mahasiswa di lingkungan kampus dan layanan akademik.',
                      style: AppTypography.bodySm.copyWith(fontSize: 8.5, height: 1.3),
                    ),
                    Text(
                      '2. Dapat digunakan untuk akses perpustakaan, ujian semester, serta diskon mahasiswa offline.',
                      style: AppTypography.bodySm.copyWith(fontSize: 8.5, height: 1.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Bottom Barcode & Verification info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terverifikasi 100% Offline • SakuKuliah',
                style: TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
              Text(
                'NIM: ${p.nim}',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF494547),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qrSquare() {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _qrDot() {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStylizedBarcode(String seed) {
    // Generates a realistic barcode pattern
    final bars = [2, 1, 3, 1, 2, 1, 1, 3, 2, 1, 2, 1, 3, 1, 1, 2, 3, 1, 2, 1];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: bars.map((w) {
        return Container(
          width: w * 1.5,
          height: 22,
          margin: const EdgeInsets.only(right: 1.2),
          color: const Color(0xFF42393D),
        );
      }).toList(),
    );
  }

  Widget _buildIdCardPhoto(StudentProfileModel p) {
    if (p.avatarBase64 != null && p.avatarBase64!.trim().isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(p.avatarBase64!),
          gaplessPlayback: true,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => _buildFallbackPhoto(p),
        );
      } catch (_) {
        return _buildFallbackPhoto(p);
      }
    }

    if (p.avatarPreset != null && p.avatarPreset!.trim().isNotEmpty) {
      return Container(
        color: AppColors.primaryContainer,
        child: Center(
          child: Text(
            p.avatarPreset!,
            style: const TextStyle(fontSize: 34),
          ),
        ),
      );
    }

    return _buildFallbackPhoto(p);
  }

  Widget _buildFallbackPhoto(StudentProfileModel p) {
    final initial = p.name.trim().isNotEmpty ? p.name.trim().substring(0, 1).toUpperCase() : 'N';
    return Container(
      color: AppColors.primaryContainer,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            color: AppColors.onPrimaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}

