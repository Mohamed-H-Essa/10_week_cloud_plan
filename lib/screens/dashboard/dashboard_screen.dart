import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/progress_provider.dart';
import '../../providers/study_plan_provider.dart';
import '../../providers/today_provider.dart';
import '../../services/motivation_service.dart' as motivation;
import '../../shared/constants/phase_colors.dart';
import '../../shared/widgets/phase_badge.dart';
import '../../shared/widgets/task_checklist.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  String _motivationQuote = '';
  bool _weekGridExpanded = false;

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
    final weekPlan =
        plans.isNotEmpty && currentWeek >= 1 && currentWeek <= plans.length
            ? plans[currentWeek - 1]
            : null;
    final weekProgress = ref.watch(weekProgressProvider(currentWeek));
    final colors = weekPlan != null
        ? getPhaseColors(weekPlan.phase, Theme.of(context).brightness)
        : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dayType = ref.watch(todayDayTypeProvider);
    final timeCtx = ref.watch(timeOfDayContextProvider);
    final todayTasks = ref.watch(todayTasksProvider);
    final saaTopic = ref.watch(todaySaaTopicProvider);
    final saaSchedule = ref.watch(todaySaaScheduleProvider);
    final completedIds = ref.watch(completedTaskIdsProvider);
    final todayDone = todayTasks.where((t) => t.completed).length;

    if (_motivationQuote.isEmpty) {
      _motivationQuote = motivation.getMotivation(currentWeek, overallProgress);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cloud Study',
          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          // 1. Today's Mission Header
          _SlideIn(
            controller: _animController,
            delay: 0.0,
            child: _MissionHeader(
              dayType: dayType,
              timeContext: timeCtx,
              phaseColors: colors,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),

          // 2. Quick Stats Row
          _SlideIn(
            controller: _animController,
            delay: 0.08,
            child: _QuickStatsRow(
              overallProgress: overallProgress,
              streak: streak,
              examCountdown: examCountdown,
              todayDone: todayDone,
              todayTotal: todayTasks.length,
              dayType: dayType,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),

          // 3. Today's Tasks Card
          _SlideIn(
            controller: _animController,
            delay: 0.16,
            child: dayType == DayType.studyNight
                ? _SaaSessionCard(
                    topic: saaTopic ?? '',
                    schedule: saaSchedule ?? '',
                    phaseColors: colors,
                    isDark: isDark,
                  )
                : _TodayTasksCard(
                    dayType: dayType,
                    weekPlan: weekPlan,
                    completedIds: completedIds,
                    todayDone: todayDone,
                    todayTotal: todayTasks.length,
                    phaseColors: colors,
                    isDark: isDark,
                  ),
          ),
          const SizedBox(height: 14),

          // 4. Motivation Card
          _SlideIn(
            controller: _animController,
            delay: 0.24,
            child: _MotivationCard(
              quote: _motivationQuote,
              phaseColors: colors,
              isDark: isDark,
              onRefresh: () {
                setState(() {
                  _motivationQuote = motivation.getMotivation(
                    currentWeek,
                    overallProgress,
                  );
                });
              },
            ),
          ),
          const SizedBox(height: 14),

          // 5. Current Week Card
          if (weekPlan != null && colors != null)
            _SlideIn(
              controller: _animController,
              delay: 0.32,
              child: _CurrentWeekCard(
                plan: weekPlan,
                currentWeek: currentWeek,
                weekProgress: weekProgress,
                colors: colors,
                isDark: isDark,
              ),
            ),
          const SizedBox(height: 14),

          // 6. Week Grid (expandable)
          _SlideIn(
            controller: _animController,
            delay: 0.40,
            child: Column(
              children: [
                InkWell(
                  onTap: () =>
                      setState(() => _weekGridExpanded = !_weekGridExpanded),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Text(
                          'ALL WEEKS',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const Spacer(),
                        AnimatedRotation(
                          turns: _weekGridExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                            color: isDark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _WeekGrid(
                      plans: plans,
                      currentWeek: currentWeek,
                      isDark: isDark,
                    ),
                  ),
                  crossFadeState: _weekGridExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Staggered slide-in animation wrapper ──

class _SlideIn extends StatelessWidget {
  final AnimationController controller;
  final double delay;
  final Widget child;

  const _SlideIn({
    required this.controller,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(delay, (delay + 0.5).clamp(0, 1), curve: Curves.easeOutCubic),
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

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}

// ── 1. Mission Header ──

class _MissionHeader extends StatelessWidget {
  final DayType dayType;
  final TimeContext timeContext;
  final PhaseColors? phaseColors;
  final bool isDark;

  const _MissionHeader({
    required this.dayType,
    required this.timeContext,
    required this.phaseColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (dayType) {
      DayType.buildFriday => ('BUILD FRIDAY', Icons.build),
      DayType.deploySaturday => ('DEPLOY SATURDAY', Icons.rocket_launch),
      DayType.studyNight => ('STUDY NIGHT', Icons.menu_book),
    };

    final subtitle = switch (timeContext) {
      TimeContext.morning => 'Good morning',
      TimeContext.afternoon => 'Afternoon push',
      TimeContext.evening => 'Evening push',
      TimeContext.lateNight => 'Late night grind',
    };

    final accentColor = phaseColors?.border ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: isDark ? 0.2 : 0.1),
            accentColor.withValues(alpha: isDark ? 0.05 : 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 28, color: accentColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: accentColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Quick Stats Row ──

class _QuickStatsRow extends StatelessWidget {
  final double overallProgress;
  final int streak;
  final int examCountdown;
  final int todayDone;
  final int todayTotal;
  final DayType dayType;
  final bool isDark;

  const _QuickStatsRow({
    required this.overallProgress,
    required this.streak,
    required this.examCountdown,
    required this.todayDone,
    required this.todayTotal,
    required this.dayType,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _GlassChip(
            icon: Icons.trending_up,
            label: '${(overallProgress * 100).round()}%',
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _GlassChip(
            icon: Icons.local_fire_department,
            label: '$streak day${streak == 1 ? '' : 's'}',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        if (examCountdown >= 0) ...[
          Expanded(
            child: _GlassChip(
              icon: Icons.event,
              label: '${examCountdown}d',
              color: Colors.red.shade400,
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (dayType != DayType.studyNight)
          Expanded(
            child: _GlassChip(
              icon: Icons.check_circle_outline,
              label: '$todayDone/$todayTotal',
              color: Colors.green,
            ),
          ),
      ],
    );
  }
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _GlassChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── 3A. Today's Tasks Card (Fri/Sat) ──

class _TodayTasksCard extends ConsumerWidget {
  final DayType dayType;
  final dynamic weekPlan;
  final Set<String> completedIds;
  final int todayDone;
  final int todayTotal;
  final PhaseColors? phaseColors;
  final bool isDark;

  const _TodayTasksCard({
    required this.dayType,
    required this.weekPlan,
    required this.completedIds,
    required this.todayDone,
    required this.todayTotal,
    required this.phaseColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (weekPlan == null) return const SizedBox.shrink();

    final tasks = dayType == DayType.buildFriday
        ? weekPlan.fridayTasks
        : weekPlan.saturdayTasks;
    final dayLabel = dayType == DayType.buildFriday
        ? 'Friday Build Tasks'
        : 'Saturday Deploy Tasks';
    final colors = phaseColors ??
        const PhaseColors(
          bg: Color(0xFFEFF6FF),
          border: Color(0xFF0EA5E9),
          text: Color(0xFF0369A1),
        );

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : colors.bg.withValues(alpha: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Text(
                  dayLabel,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: todayDone == todayTotal && todayTotal > 0
                        ? Colors.green.withValues(alpha: 0.15)
                        : colors.border.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$todayDone/$todayTotal',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: todayDone == todayTotal && todayTotal > 0
                          ? Colors.green
                          : colors.border,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Task list
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TaskChecklist(
              tasks: tasks,
              weekNumber: weekPlan.weekNumber,
              completedIds: completedIds,
              colors: colors,
              compact: true,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 3B. SAA Session Card (Sun-Thu) ──

class _SaaSessionCard extends StatelessWidget {
  final String topic;
  final String schedule;
  final PhaseColors? phaseColors;
  final bool isDark;

  const _SaaSessionCard({
    required this.topic,
    required this.schedule,
    required this.phaseColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        phaseColors?.border ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
        ),
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.grey.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.menu_book, size: 20, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tonight's SAA-C03 Session",
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '25 min focused study',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (topic.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'TOPIC',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              topic,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ],
          if (schedule.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'SCHEDULE',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentColor,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              schedule,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 4. Motivation Card ──

class _MotivationCard extends StatelessWidget {
  final String quote;
  final PhaseColors? phaseColors;
  final bool isDark;
  final VoidCallback onRefresh;

  const _MotivationCard({
    required this.quote,
    required this.phaseColors,
    required this.isDark,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor =
        phaseColors?.border ?? Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onRefresh,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: isDark ? 0.15 : 0.08),
              accentColor.withValues(alpha: isDark ? 0.05 : 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.format_quote,
              size: 20,
              color: accentColor.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                quote,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 5. Current Week Card ──

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
        color: colors.bg,
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: colors.border,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
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
                const SizedBox(height: 8),
                Text(
                  plan.title,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: weekProgress),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: value,
                        minHeight: 5,
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

// ── 6. Week Grid ──

class _WeekGrid extends ConsumerWidget {
  final List plans;
  final int currentWeek;
  final bool isDark;

  const _WeekGrid({
    required this.plans,
    required this.currentWeek,
    required this.isDark,
  });

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
        final pc = getPhaseColors(plan.phase, Theme.of(context).brightness);
        final isCurrent = plan.weekNumber == currentWeek;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + (i * 80)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(scale: 0.8 + (0.2 * value), child: child),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color:
                  pc?.bg ??
                  (isDark ? Colors.grey.shade900 : Colors.grey.shade50),
              border: Border.all(
                color: isCurrent
                    ? (pc?.border ?? Colors.blue)
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.shade200),
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
