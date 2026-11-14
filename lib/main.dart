import 'dart:ui';
import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'core/state/app_state.dart';
import 'core/storage/preferences_helper.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'features/academic/presentation/academic_screen.dart';
import 'features/calendar/presentation/academic_calendar_screen.dart';
import 'features/dashboard/presentation/home_dashboard_screen.dart';
import 'features/navigation/presentation/main_navigation_scaffold.dart';
import 'features/notes/presentation/notes_screen.dart';
import 'features/onboarding/presentation/app_splash_loading_screen.dart';
import 'features/onboarding/presentation/splash_onboarding_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/schedule/presentation/weekly_schedule_screen.dart';
import 'features/tasks/presentation/task_list_screen.dart';
import 'features/wallet/presentation/wallet_screen.dart';

/// Physics scroll bouncing lembut iOS-style untuk seluruh layar & modal (Mendukung drag mouse pada Web)
class SmoothScrollBehavior extends MaterialScrollBehavior {
  const SmoothScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const SakuKuliahApp());
}

class SakuKuliahApp extends StatefulWidget {
  const SakuKuliahApp({super.key});

  @override
  State<SakuKuliahApp> createState() => _SakuKuliahAppState();
}

class _SakuKuliahAppState extends State<SakuKuliahApp> {
  bool _hasSeenOnboarding = false;
  bool _showSplashLoading = true;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    try {
      final done = await PreferencesHelper.isOnboardingDone();
      if (mounted) {
        setState(() {
          _hasSeenOnboarding = done;
        });
      }
    } catch (_) {}
  }

  void _finishSplashLoading() {
    setState(() {
      _showSplashLoading = false;
    });
  }

  void _finishOnboarding() {
    PreferencesHelper.setOnboardingDone(true);
    setState(() {
      _hasSeenOnboarding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: SakuKuliahState.instance,
      builder: (context, _) {
        final appState = SakuKuliahState.instance;

        return MaterialApp(
          title: 'SakuKuliah',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.buildTheme(
            paletteType: appState.themePalette,
            isDark: false,
          ),
          darkTheme: AppTheme.buildTheme(
            paletteType: appState.themePalette,
            isDark: true,
          ),
          themeMode: appState.themeMode,
          scrollBehavior: const SmoothScrollBehavior(),
          builder: (context, child) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              color: isDark ? const Color(0xFF0F0B10) : AppColors.surfaceContainerLow,
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? const Color(0x33000000) : AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 28,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: child ?? const SizedBox(),
                ),
              ),
            );
          },
          home: _showSplashLoading
              ? AppSplashLoadingScreen(
                  onLoadingFinished: _finishSplashLoading,
                )
              : (_hasSeenOnboarding
                  ? const MainAppRoot()
                  : SplashOnboardingScreen(onFinishOnboarding: _finishOnboarding)),
          routes: {
            '/calendar': (context) => const AcademicCalendarScreen(),
            '/notes': (context) => const NotesScreen(),
            '/wallet': (context) => const WalletScreen(),
          },
        );
      },
    );
  }
}

/// Root widget yang membungkus MainNavigationScaffold dengan koordinasi navigasi
class MainAppRoot extends StatefulWidget {
  const MainAppRoot({super.key});

  @override
  State<MainAppRoot> createState() => _MainAppRootState();
}

class _MainAppRootState extends State<MainAppRoot> {
  int _activeTabIndex = 0;

  void _switchTab(int index) {
    setState(() {
      _activeTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeDashboardScreen(
        onNavigateToSchedule: () => _switchTab(1),
        onNavigateToTasks: () => _switchTab(2),
        onNavigateToAcademic: () => _switchTab(3),
        onNavigateToNotes: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotesScreen()),
          );
        },
        onNavigateToProfile: () => _switchTab(4),
      ),
      const WeeklyScheduleScreen(),
      const TaskListScreen(),
      const AcademicScreen(),
      const ProfileScreen(),
    ];

    return MainNavigationScaffold(
      initialIndex: _activeTabIndex,
      onTabChanged: (i) {
        _activeTabIndex = i;
      },
      pages: pages,
    );
  }
}

