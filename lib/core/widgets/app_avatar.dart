import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Komponen Avatar Foto Profil Mahasiswa Reusable SakuKuliah
class AppAvatar extends StatelessWidget {
  final String? avatarBase64;
  final String? avatarPreset;
  final String name;
  final double size;
  final double borderWidth;
  final Color borderColor;
  final bool showEditBadge;
  final VoidCallback? onTap;

  // Cache byte gambar base64 di memori agar bebas kelap-kelip saat re-render
  static final Map<String, Uint8List> _bytesCache = {};

  static Uint8List? _getBytes(String base64Str) {
    if (_bytesCache.containsKey(base64Str)) {
      return _bytesCache[base64Str];
    }
    try {
      final bytes = base64Decode(base64Str);
      if (_bytesCache.length > 30) {
        _bytesCache.clear();
      }
      _bytesCache[base64Str] = bytes;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  const AppAvatar({
    super.key,
    this.avatarBase64,
    this.avatarPreset,
    required this.name,
    this.size = 54,
    this.borderWidth = 2,
    this.borderColor = Colors.white,
    this.showEditBadge = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryContainer,
        border: Border.all(color: borderColor, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: size * 0.15,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: _buildAvatarContent(),
      ),
    );

    Widget result = avatarWidget;

    if (showEditBadge) {
      final badgeSize = (size * 0.32).clamp(18.0, 26.0);
      result = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt_rounded,
                size: badgeSize * 0.55,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: result,
      );
    }

    return result;
  }

  Widget _buildAvatarContent() {
    if (avatarBase64 != null && avatarBase64!.trim().isNotEmpty) {
      final bytes = _getBytes(avatarBase64!);
      if (bytes != null) {
        return Image.memory(
          bytes,
          key: ValueKey(avatarBase64.hashCode),
          gaplessPlayback: true,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _buildFallbackInitial(),
        );
      }
    }

    if (avatarPreset != null && avatarPreset!.trim().isNotEmpty) {
      return Center(
        child: Text(
          avatarPreset!,
          style: TextStyle(fontSize: size * 0.52),
        ),
      );
    }

    return _buildFallbackInitial();
  }

  Widget _buildFallbackInitial() {
    if (name.trim().isEmpty) {
      return Center(
        child: Icon(
          Icons.person_rounded,
          size: size * 0.55,
          color: AppColors.onPrimaryContainer,
        ),
      );
    }
    final initial = name.trim().substring(0, 1).toUpperCase();
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: AppColors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

