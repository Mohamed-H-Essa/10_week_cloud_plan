import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/week_plan.dart';
import '../data/models/task_item.dart';
import 'repositories_provider.dart';

final weekPlansProvider = StateNotifierProvider<WeekPlansNotifier, List<WeekPlan>>((ref) {
  return WeekPlansNotifier(ref);
});

final selectedWeekProvider = StateProvider<int>((ref) => 1);

final currentWeekPlanProvider = Provider<WeekPlan?>((ref) {
  final selectedWeek = ref.watch(selectedWeekProvider);
  final plans = ref.watch(weekPlansProvider);
  try {
    return plans.firstWhere((p) => p.weekNumber == selectedWeek);
  } catch (_) {
    return null;
  }
});

class WeekPlansNotifier extends StateNotifier<List<WeekPlan>> {
  final Ref _ref;

  WeekPlansNotifier(this._ref) : super([]) {
    _load();
  }

  void _load() {
    state = _ref.read(studyPlanRepoProvider).getAll();
  }

  void refresh() => _load();

  Future<void> updateTasks(int weekNumber, List<TaskItem> friday, List<TaskItem> saturday) async {
    await _ref.read(studyPlanRepoProvider).updateTasks(weekNumber, friday, saturday);
    _load();
  }

  Future<void> updateQuickNote(int weekNumber, String note) async {
    await _ref.read(studyPlanRepoProvider).updateQuickNote(weekNumber, note);
    _load();
  }
}
