import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/study_plan_provider.dart';
import '../providers/progress_provider.dart';

class ExportService {
  static Future<void> exportProgress(WidgetRef ref) async {
    final plans = ref.read(weekPlansProvider);
    final completed = ref.read(completedTaskIdsProvider);

    final buffer = StringBuffer();
    buffer.writeln('# Cloud Study - Progress Report');
    buffer.writeln();
    buffer.writeln('Generated: ${DateTime.now().toIso8601String().split('T').first}');
    buffer.writeln();

    int totalTasks = 0;
    int totalDone = 0;

    for (final plan in plans) {
      final allIds = [
        ...plan.fridayTasks.map((t) => t.id),
        ...plan.saturdayTasks.map((t) => t.id),
      ];
      final done = allIds.where((id) => completed.contains(id)).length;
      totalTasks += allIds.length;
      totalDone += done;

      final pct = allIds.isEmpty ? 0 : (done / allIds.length * 100).round();
      buffer.writeln('## Week ${plan.weekNumber}: ${plan.title} ($pct%)');
      buffer.writeln();

      buffer.writeln('### Friday');
      for (final task in plan.fridayTasks) {
        final check = completed.contains(task.id) ? 'x' : ' ';
        buffer.writeln('- [$check] ${task.text}');
      }
      buffer.writeln();

      buffer.writeln('### Saturday');
      for (final task in plan.saturdayTasks) {
        final check = completed.contains(task.id) ? 'x' : ' ';
        buffer.writeln('- [$check] ${task.text}');
      }
      buffer.writeln();
    }

    final overallPct = totalTasks == 0 ? 0 : (totalDone / totalTasks * 100).round();
    buffer.writeln('---');
    buffer.writeln('**Overall: $totalDone/$totalTasks tasks ($overallPct%)**');

    await Share.share(buffer.toString());
  }
}
