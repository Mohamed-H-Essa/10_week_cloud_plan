import 'package:hive/hive.dart';
import '../models/week_plan.dart';
import '../models/task_item.dart';
import '../seed/plan_seed.dart';

class StudyPlanRepository {
  static const _boxName = 'week_plans';

  late Box<WeekPlan> _box;

  Future<void> init() async {
    _box = await Hive.openBox<WeekPlan>(_boxName);
  }

  bool get isEmpty => _box.isEmpty;

  Future<void> seed() async {
    final weeks = buildSeedWeeks();
    for (final w in weeks) {
      await _box.put(w.weekNumber, w);
    }
  }

  List<WeekPlan> getAll() {
    final plans = <WeekPlan>[];
    for (int i = 1; i <= 10; i++) {
      final plan = _box.get(i);
      if (plan != null) plans.add(plan);
    }
    return plans;
  }

  WeekPlan? getWeek(int weekNumber) => _box.get(weekNumber);

  Future<void> saveWeek(WeekPlan plan) async {
    await _box.put(plan.weekNumber, plan);
  }

  Future<void> updateTasks(int weekNumber, List<TaskItem> fridayTasks, List<TaskItem> saturdayTasks) async {
    final plan = _box.get(weekNumber);
    if (plan == null) return;
    plan.fridayTasks = fridayTasks;
    plan.saturdayTasks = saturdayTasks;
    await plan.save();
  }

  Future<void> updateQuickNote(int weekNumber, String note) async {
    final plan = _box.get(weekNumber);
    if (plan == null) return;
    plan.quickNote = note;
    await plan.save();
  }
}
