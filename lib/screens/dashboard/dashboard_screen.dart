import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/progress_provider.dart';
import '../../providers/study_plan_provider.dart';
import '../../shared/constants/phase_colors.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../shared/widgets/phase_badge.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Cloud Study', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall Progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ProgressRing(
                    progress: overallProgress,
                    size: 80,
                    strokeWidth: 7,
                    child: Text(
                      '${(overallProgress * 100).round()}%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Overall Progress',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '10-Week Battle Plan',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _StatChip(
                              icon: Icons.local_fire_department,
                              label: '$streak day${streak == 1 ? '' : 's'}',
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            if (examCountdown >= 0)
                              _StatChip(
                                icon: Icons.event,
                                label: '${examCountdown}d to exam',
                                color: Colors.red,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Current Week Card
          if (weekPlan != null && colors != null)
            Card(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: colors.border, width: 4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'WEEK $currentWeek',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          PhaseBadge(phase: weekPlan.phase, compact: true),
                          const Spacer(),
                          Text(
                            '${(weekProgress * 100).round()}%',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: colors.border,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weekPlan.title,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        weekPlan.tagline,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: weekProgress,
                          minHeight: 6,
                          backgroundColor: colors.border.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation(colors.border),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Week Progress Grid
          Text(
            'WEEKLY PROGRESS',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
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

              return Container(
                decoration: BoxDecoration(
                  color: pc?.bg ?? Colors.grey.shade50,
                  border: Border.all(
                    color: isCurrent ? (pc?.border ?? Colors.blue) : Colors.grey.shade200,
                    width: isCurrent ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'W${plan.weekNumber}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: pc?.text ?? Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).round()}%',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: pc?.border ?? Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Next Session Card
          if (weekPlan != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 18, color: Colors.grey.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'NEXT SESSION',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nextSessionDay(),
                      style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      weekPlan.tagline,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  String _nextSessionDay() {
    final now = DateTime.now();
    switch (now.weekday) {
      case DateTime.friday:
        return 'Today (Friday)';
      case DateTime.saturday:
        return 'Today (Saturday)';
      case DateTime.sunday:
        return 'Weeknight Study Tonight';
      default:
        if (now.weekday < DateTime.friday) {
          final daysUntilFriday = DateTime.friday - now.weekday;
          if (daysUntilFriday == 1) return 'Tomorrow (Friday)';
          return 'Weeknight Study Tonight';
        }
        return 'Weeknight Study Tonight';
    }
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
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
