import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme.dart';
import '../providers/behavior_provider.dart';
import '../providers/settings_provider.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/plan/plan_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../shared/widgets/animated_nav_bar.dart';

class CloudStudyApp extends ConsumerWidget {
  const CloudStudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = switch (settings.darkModeOverride) {
      true => ThemeMode.dark,
      false => ThemeMode.light,
      null => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Cloud Study',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends ConsumerStatefulWidget {
  const _AppShell();

  @override
  ConsumerState<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<_AppShell> with TickerProviderStateMixin, WidgetsBindingObserver {
  int _currentIndex = 0;
  late final PageController _pageController;
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      try {
        ref.read(behaviorRepoProvider).recordAppOpen();
        ref.read(smartNotificationProvider).reschedule();
      } catch (_) {}
    }
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [DashboardScreen(), PlanScreen(), SettingsScreen()],
        onPageChanged: (i) => setState(() => _currentIndex = i),
      ),
      bottomNavigationBar: AnimatedNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
