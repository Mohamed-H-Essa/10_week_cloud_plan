import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories_provider.dart';
import 'study_plan_provider.dart';

final completedTaskIdsProvider = StateNotifierProvider<CompletedTaskIdsNotifier, Set<String>>((ref) {
  return CompletedTaskIdsNotifier(ref);
});

class CompletedTaskIdsNotifier extends StateNotifier<Set<String>> {
  final Ref _ref;

  CompletedTaskIdsNotifier(this._ref) : super({}) {
    _load();
  }

  void _load() {
    state = _ref.read(progressRepoProvider).completedTaskIds();
  }

  Future<void> toggle(String taskId, int weekNumber) async {
    await _ref.read(progressRepoProvider).toggleTask(taskId, weekNumber);
    _load();
  }
}

final weekProgressProvider = Provider.family<double, int>((ref, weekNumber) {
  final completed = ref.watch(completedTaskIdsProvider);
  final plans = ref.watch(weekPlansProvider);
  try {
    final plan = plans.firstWhere((p) => p.weekNumber == weekNumber);
    final allIds = [
      ...plan.fridayTasks.map((t) => t.id),
      ...plan.saturdayTasks.map((t) => t.id),
    ];
    if (allIds.isEmpty) return 0;
    return allIds.where((id) => completed.contains(id)).length / allIds.length;
  } catch (_) {
    return 0;
  }
});

final overallProgressProvider = Provider<double>((ref) {
  final plans = ref.watch(weekPlansProvider);
  final completed = ref.watch(completedTaskIdsProvider);
  int total = 0;
  int done = 0;
  for (final plan in plans) {
    final ids = [
      ...plan.fridayTasks.map((t) => t.id),
      ...plan.saturdayTasks.map((t) => t.id),
    ];
    total += ids.length;
    done += ids.where((id) => completed.contains(id)).length;
  }
  if (total == 0) return 0;
  return done / total;
});

final streakProvider = Provider<int>((ref) {
  final entries = ref.read(progressRepoProvider).allEntries();
  if (entries.isEmpty) return 0;

  entries.sort((a, b) => b.completedAt.compareTo(a.completedAt));

  final days = <DateTime>{};
  for (final e in entries) {
    days.add(DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day));
  }

  final sortedDays = days.toList()..sort((a, b) => b.compareTo(a));
  int streak = 0;
  var check = DateTime.now();
  check = DateTime(check.year, check.month, check.day);

  for (final day in sortedDays) {
    final diff = check.difference(day).inDays;
    if (diff <= 1) {
      streak++;
      check = day;
    } else {
      break;
    }
  }
  return streak;
});

final currentWeekNumberProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsRepoProvider).settings;
  final startDate = settings.planStartDate;
  if (startDate == null) return 1;
  final now = DateTime.now();
  final diff = now.difference(startDate).inDays;
  final week = (diff / 7).floor() + 1;
  return week.clamp(1, 10);
});

final examCountdownProvider = Provider<int>((ref) {
  final settings = ref.watch(settingsRepoProvider).settings;
  final startDate = settings.planStartDate;
  if (startDate == null) return -1;
  final examDate = startDate.add(const Duration(days: 6 * 7)); // Start of week 7
  final now = DateTime.now();
  return examDate.difference(now).inDays;
});

final saturdayCompletionProvider = Provider.family<double, int>((ref, weekNumber) {
  final completed = ref.watch(completedTaskIdsProvider);
  final plans = ref.watch(weekPlansProvider);
  try {
    final plan = plans.firstWhere((p) => p.weekNumber == weekNumber);
    final satIds = plan.saturdayTasks.map((t) => t.id).toList();
    if (satIds.isEmpty) return 0;
    return satIds.where((id) => completed.contains(id)).length / satIds.length;
  } catch (_) {
    return 0;
  }
});
