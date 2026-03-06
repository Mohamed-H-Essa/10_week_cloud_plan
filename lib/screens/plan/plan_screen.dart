import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/week_plan.dart';
import '../../providers/study_plan_provider.dart';
import '../../providers/progress_provider.dart';
import '../../shared/constants/phase_colors.dart';
import '../../shared/widgets/phase_badge.dart';
import '../../screens/edit/edit_week_screen.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  final _expandedSections = <String, bool>{
    'friday': true,
    'saturday': false,
    'weeknights': false,
    'meta': false,
  };

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !(_expandedSections[key] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(weekPlansProvider);
    final selectedWeek = ref.watch(selectedWeekProvider);
    final plan = ref.watch(currentWeekPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Study Plan', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'about') {
                _showAboutPlan(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'about', child: Text('About This Plan')),
            ],
          ),
        ],
      ),
      body: plans.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _WeekSelector(
                  plans: plans,
                  selectedWeek: selectedWeek,
                  onSelect: (w) {
                    ref.read(selectedWeekProvider.notifier).state = w;
                    setState(() {
                      _expandedSections['friday'] = true;
                      _expandedSections['saturday'] = false;
                      _expandedSections['weeknights'] = false;
                      _expandedSections['meta'] = false;
                    });
                  },
                ),
                if (plan != null)
                  Expanded(
                    child: _WeekCard(
                      plan: plan,
                      expandedSections: _expandedSections,
                      onToggleSection: _toggleSection,
                      onEdit: () => _editWeek(context, plan),
                    ),
                  ),
              ],
            ),
    );
  }

  void _editWeek(BuildContext context, WeekPlan plan) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditWeekScreen(weekNumber: plan.weekNumber),
      ),
    );
  }

  void _showAboutPlan(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const _AboutPlanScreen()),
    );
  }
}

class _WeekSelector extends StatelessWidget {
  final List<WeekPlan> plans;
  final int selectedWeek;
  final ValueChanged<int> onSelect;

  const _WeekSelector({required this.plans, required this.selectedWeek, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: plans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final plan = plans[i];
          final isSelected = plan.weekNumber == selectedWeek;
          final colors = phaseColorMap[plan.phase];
          return GestureDetector(
            onTap: () => onSelect(plan.weekNumber),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? (colors?.bg ?? Colors.blue.shade50) : null,
                border: Border.all(
                  color: isSelected ? (colors?.border ?? Colors.blue) : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'W${plan.weekNumber}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? (colors?.border ?? Colors.blue) : Colors.grey.shade600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WeekCard extends ConsumerWidget {
  final WeekPlan plan;
  final Map<String, bool> expandedSections;
  final ValueChanged<String> onToggleSection;
  final VoidCallback onEdit;

  const _WeekCard({
    required this.plan,
    required this.expandedSections,
    required this.onToggleSection,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = phaseColorMap[plan.phase]!;
    final completed = ref.watch(completedTaskIdsProvider);
    final progress = ref.watch(weekProgressProvider(plan.weekNumber));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colors.border, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bg,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border(bottom: BorderSide(color: colors.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        PhaseBadge(phase: plan.phase),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.border,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'WEEK ${plan.weekNumber}',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(progress * 100).round()}%',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.title,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.tagline,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.why,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    // Progress bar
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: colors.border.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(colors.border),
                      ),
                    ),
                  ],
                ),
              ),
              // Sections
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _ExpandableSection(
                      title: 'Friday',
                      icon: Icons.build,
                      sectionKey: 'friday',
                      isExpanded: expandedSections['friday'] ?? false,
                      onToggle: onToggleSection,
                      colors: colors,
                      child: _TaskList(
                        tasks: plan.fridayTasks,
                        weekNumber: plan.weekNumber,
                        completedIds: completed,
                        colors: colors,
                      ),
                    ),
                    _ExpandableSection(
                      title: 'Saturday',
                      icon: Icons.rocket_launch,
                      sectionKey: 'saturday',
                      isExpanded: expandedSections['saturday'] ?? false,
                      onToggle: onToggleSection,
                      colors: colors,
                      child: _TaskList(
                        tasks: plan.saturdayTasks,
                        weekNumber: plan.weekNumber,
                        completedIds: completed,
                        colors: colors,
                      ),
                    ),
                    _ExpandableSection(
                      title: 'Weeknight Study (Mon-Fri)',
                      icon: Icons.menu_book,
                      sectionKey: 'weeknights',
                      isExpanded: expandedSections['weeknights'] ?? false,
                      onToggle: onToggleSection,
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SAA-C03 COURSE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(plan.weeknightSaa, style: const TextStyle(fontSize: 13, height: 1.5)),
                          const SizedBox(height: 12),
                          Text(
                            'SCHEDULE',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(plan.weeknightSchedule, style: const TextStyle(fontSize: 13, height: 1.5)),
                        ],
                      ),
                    ),
                    _ExpandableSection(
                      title: 'Cost + Output + LinkedIn',
                      icon: Icons.receipt_long,
                      sectionKey: 'meta',
                      isExpanded: expandedSections['meta'] ?? false,
                      onToggle: onToggleSection,
                      colors: colors,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MetaRow(label: 'Cost', value: plan.cost, colors: colors),
                          const SizedBox(height: 8),
                          _MetaRow(label: 'Output', value: plan.output, colors: colors),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'LINKEDIN POST',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: colors.text,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '"${plan.linkedinPost}"',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  plan.linkedinAngle,
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Quick note
        _QuickNoteField(plan: plan),
        const SizedBox(height: 12),
        // Edit button
        OutlinedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Week Tasks'),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final String sectionKey;
  final bool isExpanded;
  final ValueChanged<String> onToggle;
  final PhaseColors colors;
  final Widget child;

  const _ExpandableSection({
    required this.title,
    required this.icon,
    required this.sectionKey,
    required this.isExpanded,
    required this.onToggle,
    required this.colors,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          InkWell(
            onTap: () => onToggle(sectionKey),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isExpanded ? colors.bg : Colors.grey.shade50,
                border: Border.all(
                  color: isExpanded ? colors.border : Colors.grey.shade200,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 16, color: isExpanded ? colors.text : Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isExpanded ? colors.text : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              margin: const EdgeInsets.only(left: 16, top: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border(left: BorderSide(color: colors.border, width: 2)),
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _TaskList extends ConsumerWidget {
  final List tasks;
  final int weekNumber;
  final Set<String> completedIds;
  final PhaseColors colors;

  const _TaskList({
    required this.tasks,
    required this.weekNumber,
    required this.completedIds,
    required this.colors,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: tasks.map<Widget>((task) {
        final isDone = completedIds.contains(task.id);
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () => ref.read(completedTaskIdsProvider.notifier).toggle(task.id, weekNumber),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: isDone,
                      onChanged: (_) => ref.read(completedTaskIdsProvider.notifier).toggle(task.id, weekNumber),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      activeColor: colors.border,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.text,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDone ? Colors.grey.shade400 : Colors.grey.shade800,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  final PhaseColors colors;

  const _MetaRow({required this.label, required this.value, required this.colors});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
        children: [
          TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.w700, color: colors.text)),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _QuickNoteField extends ConsumerStatefulWidget {
  final WeekPlan plan;
  const _QuickNoteField({required this.plan});

  @override
  ConsumerState<_QuickNoteField> createState() => _QuickNoteFieldState();
}

class _QuickNoteFieldState extends ConsumerState<_QuickNoteField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.plan.quickNote);
  }

  @override
  void didUpdateWidget(_QuickNoteField old) {
    super.didUpdateWidget(old);
    if (old.plan.weekNumber != widget.plan.weekNumber) {
      _controller.text = widget.plan.quickNote;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: 3,
      minLines: 1,
      decoration: InputDecoration(
        hintText: 'Quick note for Week ${widget.plan.weekNumber}...',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.all(12),
        isDense: true,
      ),
      onChanged: (value) {
        ref.read(weekPlansProvider.notifier).updateQuickNote(widget.plan.weekNumber, value);
      },
    );
  }
}

// About This Plan screen
class _AboutPlanScreen extends StatelessWidget {
  const _AboutPlanScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About This Plan', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Rules
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'THE RULES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade100,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(
                  _rules.length,
                  (i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(i + 1).toString().padLeft(2, '0')} ',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _rules[i],
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade300, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Buffer Notes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BUFFER WEEKS',
                  style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ..._bufferNotes.map((note) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('— ', style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.w700)),
                          Expanded(
                            child: Text(note, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.5)),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Cost Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COST BREAKDOWN',
                  style: GoogleFonts.jetBrainsMono(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ..._costs.asMap().entries.map((entry) {
                  final isTotal = entry.key == _costs.length - 1;
                  return Container(
                    padding: EdgeInsets.only(top: isTotal ? 8 : 0),
                    decoration: BoxDecoration(
                      border: isTotal ? Border(top: BorderSide(color: Colors.grey.shade300)) : null,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.value['label']!,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                          Text(
                            entry.value['value']!,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 12,
                              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '10 weekends. 5 repos. 1 cert. 10 LinkedIn posts.\n~\$300 total. Your ticket out.',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                color: Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

const _rules = [
  'AI scaffolds. You break it, fix it, explain it out loud. That\'s the loop.',
  'terraform destroy every Saturday night. Rebuild next Friday in minutes. No surprise bills.',
  'Post on LinkedIn every weekend. No excuses. Consistency compounds.',
  'Every repo: README + architecture diagram or it doesn\'t count.',
  '15 min mock interviews with AI after each weekend. If you can\'t explain it, break it again.',
  'Weeknights = SAA study (Weeks 1-7) then job applications (Weeks 8+). Protect this time.',
  'GitHub commits every weekend. The green squares graph is your proof of work.',
  'Target: remote EU, Gulf startups (Dubai/Riyadh), US companies hiring EMEA timezone.',
];

const _bufferNotes = [
  'If a weekend goes badly (sick, family, burnout), push that week\'s work to the following weekend. The plan survives 2-3 slips.',
  'Weeks 1-5 are sequential (each builds on the last). Weeks 7-9 are more independent — you can reorder if needed.',
  'If SAA exam needs to move: shift Weeks 7+ back accordingly. The cert matters more than the project timeline.',
  'If you\'re ahead of schedule: start CKA prep earlier. CKA + SAA is the combo that gets interviews.',
  'Real timeline: plan says 10 weeks, expect 12-14 with life getting in the way. That\'s still fast.',
];

const _costs = [
  {'label': 'Hetzner k3s cluster (3 nodes, months 3-10)', 'value': '~\$90'},
  {'label': 'AWS free tier usage (Weeks 2-8)', 'value': '~\$15-30'},
  {'label': 'EKS weekend (Week 8 only, destroy after)', 'value': '~\$10'},
  {'label': 'SAA-C03 exam fee', 'value': '\$150'},
  {'label': 'Tutorials Dojo practice exams', 'value': '\$15'},
  {'label': 'Domain (if not already owned)', 'value': '\$10-15/yr'},
  {'label': 'TOTAL (10 weeks)', 'value': '~\$300 USD'},
];
