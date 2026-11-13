import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Scaffold utama dengan Bottom Navigation Bar 5-Destinasi feminine pastel
class MainNavigationScaffold extends StatefulWidget {
  final int initialIndex;
  final List<Widget> pages;
  final ValueChanged<int>? onTabChanged;

  const MainNavigationScaffold({
    super.key,
    this.initialIndex = 0,
    required this.pages,
    this.onTabChanged,
  });

  @override
  State<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends State<MainNavigationScaffold> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainNavigationScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex && widget.initialIndex != _currentIndex) {
      setState(() {
        _currentIndex = widget.initialIndex;
      });
    }
  }

  void _onTabSelected(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      widget.onTabChanged?.call(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOutQuart,
        switchOutCurve: Curves.easeInQuad,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: widget.pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: _buildPastelBottomBar(),
    );
  }

  Widget _buildPastelBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(217, 139, 174, 0.18),
            blurRadius: 24,
            offset: Offset(0, -4),
            spreadRadius: -4,
          ),
        ],
        border: const Border(
          top: BorderSide(
            color: Color(0x22F4DCE4),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.calendar_today_rounded, 'Jadwal'),
              _buildNavItem(2, Icons.checklist_rounded, 'Tugas'),
              _buildNavItem(3, Icons.school_rounded, 'Akademik'),
              _buildNavItem(4, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onTabSelected(index),
          splashColor: AppColors.primaryContainer.withValues(alpha: 0.3),
          highlightColor: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Pill for Active Tab Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                width: isSelected ? 48 : 42,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: AnimatedScale(
                  scale: isSelected ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? AppColors.onPrimaryContainer
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.labelSm.copyWith(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

