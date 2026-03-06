import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/progress_provider.dart';
import '../../providers/study_plan_provider.dart';
import '../../shared/constants/phase_colors.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/phase_badge.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWeek = ref.watch(currentWeekNumberProvider);
    final overallProgress = ref.watch(overallProgressProvider);
    final streak = ref.watch(streakProvider);
    final examCountdown = ref.watch(examCountdownProvider);
    final plans = ref.watch(weekPlansProvider);
    final weekPlan = plans.isNotEmpty && currentWeek >= 1 && currentWeek <= plans.length
        ? plans[currentWeek - 1]
        : null;
    final weekProgress = ref.watch(weekProgressProvider(currentWeek));
    final colors = weekPlan != null ? phaseColorMap[weekPlan.phase] : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Study', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // Overall Progress Card
          _SlideIn(
            controller: _animController,
            delay: 0.0,
            child: _ProgressHeroCard(
              progress: overallProgress,
              streak: streak,
              examCountdown: examCountdown,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 16),

          // Current Week Card
          if (weekPlan != null && colors != null)
            _SlideIn(
              controller: _animController,
              delay: 0.1,
              child: _CurrentWeekCard(
                plan: weekPlan,
                currentWeek: currentWeek,
                weekProgress: weekProgress,
                colors: colors,
                isDark: isDark,
              ),
            ),
          const SizedBox(height: 16),

          // Next Session
          _SlideIn(
            controller: _animController,
            delay: 0.2,
            child: _NextSessionCard(
              weekPlan: weekPlan,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 20),

          // Week Progress Grid
          _SlideIn(
            controller: _animController,
            delay: 0.3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WEEKLY PROGRESS',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                _WeekGrid(plans: plans, currentWeek: currentWeek, isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// Staggered slide-in animation wrapper
class _SlideIn extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _SlideIn({required this.controller, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, min(delay + 0.5, 1.0), curve: Curves.easeOutCubic),
    );
    return AnimatedBuilder(
      listenable: animation,
      builder: (context, _) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({super.key, required super.listenable, required this.builder});

  @override
  Widget build(BuildContext context) => builder(context, null);
}

class _ProgressHeroCard extends StatelessWidget {
  final double progress;
  final int streak;
  final int examCountdown;
  final bool isDark;

  const _ProgressHeroCard({
    required this.progress,
    required this.streak,
    required this.examCountdown,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)]
              : [primary.withValues(alpha: 0.08), primary.withValues(alpha: 0.02)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.2 : 0.15),
        ),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) {
              return ProgressRing(
                progress: value,
                size: 90,
                strokeWidth: 8,
                color: primary,
                child: Text(
                  '${(value * 100).round()}%',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Battle Plan',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '10-Week Cloud Engineering',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _GlassChip(
                      icon: Icons.local_fire_department,
                      label: '$streak day${streak == 1 ? '' : 's'}',
                      color: Colors.orange,
                    ),
                    if (examCountdown >= 0)
                      _GlassChip(
                        icon: Icons.event,
                        label: '${examCountdown}d to exam',
                        color: Colors.red.shade400,
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
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _GlassChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrentWeekCard extends StatelessWidget {
  final dynamic plan;
  final int currentWeek;
  final double weekProgress;
  final PhaseColors colors;
  final bool isDark;

  const _CurrentWeekCard({
    required this.plan,
    required this.currentWeek,
    required this.weekProgress,
    required this.colors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.4)),
        color: isDark ? colors.border.withValues(alpha: 0.08) : colors.bg,
      ),
      child: Column(
        children: [
          // Top accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.border,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'WEEK $currentWeek',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    PhaseBadge(phase: plan.phase, compact: true),
                    const Spacer(),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: weekProgress),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return Text(
                          '${(value * 100).round()}%',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.border,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  plan.title,
                  style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.tagline,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: weekProgress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 6,
                        backgroundColor: colors.border.withValues(alpha: 0.12),
                        valueColor: AlwaysStoppedAnimation(colors.border),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NextSessionCard extends StatelessWidget {
  final dynamic weekPlan;
  final bool isDark;

  const _NextSessionCard({required this.weekPlan, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (weekPlan == null) return const SizedBox.shrink();

    final (icon, label, subtitle) = _getNextSession();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade200,
        ),
        color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String, String) _getNextSession() {
    final now = DateTime.now();
    // Week starts Sunday. Off days: Friday & Saturday.
    // Build days: Sunday (build), Monday (deploy/test)
    // Study nights: Sun-Thu evenings
    return switch (now.weekday) {
      DateTime.sunday => (Icons.build, 'Today (Sunday)', weekPlan.tagline as String),
      DateTime.monday => (Icons.rocket_launch, 'Today (Monday)', weekPlan.tagline as String),
      DateTime.friday => (Icons.weekend, 'Off Day', 'Rest up — build day is Sunday'),
      DateTime.saturday => (Icons.weekend, 'Off Day', 'Recharge — tomorrow we build'),
      _ => (Icons.menu_book, 'Study Night', 'SAA-C03 session tonight'),
    };
  }
}

class _WeekGrid extends ConsumerWidget {
  final List plans;
  final int currentWeek;
  final bool isDark;

  const _WeekGrid({required this.plans, required this.currentWeek, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: plans.length,
      itemBuilder: (context, i) {
        final plan = plans[i];
        final progress = ref.watch(weekProgressProvider(plan.weekNumber));
        final pc = phaseColorMap[plan.phase];
        final isCurrent = plan.weekNumber == currentWeek;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (i * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: child,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? (pc?.border.withValues(alpha: 0.08) ?? Colors.grey.shade900)
                  : (pc?.bg ?? Colors.grey.shade50),
              border: Border.all(
                color: isCurrent
                    ? (pc?.border ?? Colors.blue)
                    : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200),
                width: isCurrent ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'W${plan.weekNumber}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: pc?.text ?? Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(progress * 100).round()}%',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: pc?.border ?? Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
