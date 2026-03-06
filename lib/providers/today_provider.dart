import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/task_item.dart';
import 'progress_provider.dart';
import 'study_plan_provider.dart';

enum DayType { buildFriday, deploySaturday, studyNight }

enum TimeContext { morning, afternoon, evening, lateNight }

final todayDayTypeProvider = Provider<DayType>((ref) {
  final weekday = DateTime.now().weekday;
  return switch (weekday) {
    DateTime.friday => DayType.buildFriday,
    DateTime.saturday => DayType.deploySaturday,
    _ => DayType.studyNight,
  };
});

final todayTasksProvider =
    Provider<List<({TaskItem task, bool completed})>>((ref) {
  final dayType = ref.watch(todayDayTypeProvider);
  if (dayType == DayType.studyNight) return [];

  final currentWeek = ref.watch(currentWeekNumberProvider);
  final plans = ref.watch(weekPlansProvider);
  final completedIds = ref.watch(completedTaskIdsProvider);

  try {
    final plan = plans.firstWhere((p) => p.weekNumber == currentWeek);
    final tasks = dayType == DayType.buildFriday
        ? plan.fridayTasks
        : plan.saturdayTasks;
    return tasks
        .map((t) => (task: t, completed: completedIds.contains(t.id)))
        .toList();
  } catch (_) {
    return [];
  }
});

final todayPendingCountProvider = Provider<int>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  return tasks.where((t) => !t.completed).length;
});

final nextUncompletedTaskProvider = Provider<TaskItem?>((ref) {
  final tasks = ref.watch(todayTasksProvider);
  try {
    return tasks.firstWhere((t) => !t.completed).task;
  } catch (_) {
    return null;
  }
});

final todaySaaTopicProvider = Provider<String?>((ref) {
  final dayType = ref.watch(todayDayTypeProvider);
  if (dayType != DayType.studyNight) return null;

  final currentWeek = ref.watch(currentWeekNumberProvider);
  final plans = ref.watch(weekPlansProvider);
  try {
    final plan = plans.firstWhere((p) => p.weekNumber == currentWeek);
    return plan.weeknightSaa;
  } catch (_) {
    return null;
  }
});

final todaySaaScheduleProvider = Provider<String?>((ref) {
  final dayType = ref.watch(todayDayTypeProvider);
  if (dayType != DayType.studyNight) return null;

  final currentWeek = ref.watch(currentWeekNumberProvider);
  final plans = ref.watch(weekPlansProvider);
  try {
    final plan = plans.firstWhere((p) => p.weekNumber == currentWeek);
    return plan.weeknightSchedule;
  } catch (_) {
    return null;
  }
});

final timeOfDayContextProvider = Provider<TimeContext>((ref) {
  final hour = DateTime.now().hour;
  if (hour < 12) return TimeContext.morning;
  if (hour < 17) return TimeContext.afternoon;
  if (hour < 22) return TimeContext.evening;
  return TimeContext.lateNight;
});
