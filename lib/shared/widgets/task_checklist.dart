import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/task_item.dart';
import '../../providers/progress_provider.dart';
import '../../shared/constants/phase_colors.dart';

class TaskChecklist extends ConsumerWidget {
  final List<TaskItem> tasks;
  final int weekNumber;
  final Set<String> completedIds;
  final PhaseColors colors;
  final bool compact;

  const TaskChecklist({
    super.key,
    required this.tasks,
    required this.weekNumber,
    required this.completedIds,
    required this.colors,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: tasks.map<Widget>((task) {
        final isDone = completedIds.contains(task.id);
        return Padding(
          padding: EdgeInsets.only(bottom: compact ? 6 : 8),
          child: InkWell(
            onTap: () => ref
                .read(completedTaskIdsProvider.notifier)
                .toggle(task.id, weekNumber),
            borderRadius: BorderRadius.circular(8),
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
                      onChanged: (_) => ref
                          .read(completedTaskIdsProvider.notifier)
                          .toggle(task.id, weekNumber),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      activeColor: colors.border,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 200),
                    style: TextStyle(
                      fontSize: compact ? 12.5 : 13,
                      height: 1.5,
                      color: isDone
                          ? (isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400)
                          : (isDark
                              ? Colors.grey.shade300
                              : Colors.grey.shade800),
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                    child: Text(task.text),
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
