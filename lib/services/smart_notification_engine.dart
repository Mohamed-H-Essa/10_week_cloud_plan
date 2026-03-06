import 'dart:math';
import 'package:timezone/timezone.dart' as tz;
import '../data/models/user_behavior.dart';
import '../data/models/week_plan.dart';
import '../data/repositories/behavior_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/study_plan_repository.dart';
import '../data/repositories/settings_repository.dart';
import 'notification_messages.dart';
import 'notification_service.dart';

enum EngagementState { engaged, coasting, slipping, absent, ghosting }

class SmartNotificationEngine {
  static final _rng = Random();

  static EngagementState computeState(UserBehavior behavior) {
    final now = DateTime.now();
    final lastActivity = _latestOf(behavior.lastTaskCompletion, behavior.lastAppOpen);
    if (lastActivity == null) return EngagementState.coasting;

    final hoursSince = now.difference(lastActivity).inHours;

    if (hoursSince <= 24) return EngagementState.engaged;
    if (hoursSince <= 48) return EngagementState.coasting;
    if (hoursSince <= 96) return EngagementState.slipping;
    if (hoursSince <= 168) return EngagementState.absent;
    return EngagementState.ghosting;
  }

  static bool isOverwhelmed({
    required int currentWeek,
    required int expectedWeek,
    required double weekProgress,
    required int pendingTasks,
    required DateTime now,
  }) {
    // Behind 2+ weeks
    if (expectedWeek - currentWeek >= 2) return true;
    // <20% on Fri/Sat evening
    final isBuildDay = now.weekday == DateTime.friday || now.weekday == DateTime.saturday;
    if (isBuildDay && now.hour >= 17 && weekProgress < 0.2) return true;
    // 6+ tasks remaining late in weekend
    if (now.weekday == DateTime.saturday && now.hour >= 16 && pendingTasks >= 6) return true;
    return false;
  }

  static Future<void> computeAndSchedule({
    required BehaviorRepository behaviorRepo,
    required ProgressRepository progressRepo,
    required StudyPlanRepository studyPlanRepo,
    required SettingsRepository settingsRepo,
  }) async {
    // 1. Cancel all smart notifications (IDs 1000-1063)
    await NotificationService.cancelSmartRange();

    final behavior = behaviorRepo.behavior;
    final state = computeState(behavior);
    final plans = studyPlanRepo.getAll();
    final completedIds = progressRepo.completedTaskIds();
    final settings = settingsRepo.settings;
    final now = DateTime.now();

    // Determine current week
    int currentWeek = 1;
    final startDate = settings.planStartDate;
    if (startDate != null) {
      currentWeek = ((now.difference(startDate).inDays / 7).floor() + 1).clamp(1, 10);
    }
    final expectedWeek = currentWeek;

    // Get current week plan
    WeekPlan? currentPlan;
    try {
      currentPlan = plans.firstWhere((p) => p.weekNumber == currentWeek);
    } catch (_) {
      if (plans.isNotEmpty) currentPlan = plans.last;
    }
    if (currentPlan == null) return;

    final allTaskIds = [
      ...currentPlan.fridayTasks.map((t) => t.id),
      ...currentPlan.saturdayTasks.map((t) => t.id),
    ];
    final pendingCount = allTaskIds.where((id) => !completedIds.contains(id)).length;
    final weekProgress = allTaskIds.isEmpty ? 0.0 : (allTaskIds.length - pendingCount) / allTaskIds.length;

    final overwhelmed = isOverwhelmed(
      currentWeek: currentWeek,
      expectedWeek: expectedWeek,
      weekProgress: weekProgress,
      pendingTasks: pendingCount,
      now: now,
    );

    // Find next uncompleted task name
    String nextTask = '';
    for (final task in [...currentPlan.fridayTasks, ...currentPlan.saturdayTasks]) {
      if (!completedIds.contains(task.id)) {
        nextTask = task.text;
        break;
      }
    }

    // Compute streak
    final entries = progressRepo.allEntries();
    int streak = 0;
    if (entries.isNotEmpty) {
      final days = <DateTime>{};
      for (final e in entries) {
        days.add(DateTime(e.completedAt.year, e.completedAt.month, e.completedAt.day));
      }
      final sortedDays = days.toList()..sort((a, b) => b.compareTo(a));
      var check = DateTime(now.year, now.month, now.day);
      for (final day in sortedDays) {
        if (check.difference(day).inDays <= 1) {
          streak++;
          check = day;
        } else {
          break;
        }
      }
    }

    // Exam countdown
    int examDays = -1;
    if (startDate != null) {
      final examDate = startDate.add(const Duration(days: 6 * 7));
      examDays = examDate.difference(now).inDays;
    }

    // Token map for templates
    final tokens = <String, String>{
      'week': currentWeek.toString(),
      'phase': currentPlan.phase,
      'streak': streak.toString(),
      'pendingTasks': pendingCount.toString(),
      'nextTask': nextTask.length > 40 ? '${nextTask.substring(0, 37)}...' : nextTask,
      'examDays': examDays >= 0 ? examDays.toString() : '??',
      'daysAway': _daysAway(behavior).toString(),
      'progress': (weekProgress * 100).round().toString(),
      'taskCount': (allTaskIds.length - pendingCount).toString(),
    };

    // 2. Compute budget for 14 days
    final peakHour = behaviorRepo.peakHour();
    final stateStr = state.name;
    int notifId = 1000;

    for (int dayOffset = 0; dayOffset < 14 && notifId < 1064; dayOffset++) {
      final targetDate = now.add(Duration(days: dayOffset));
      final weekday = targetDate.weekday;
      final isFriday = weekday == DateTime.friday;
      final isSaturday = weekday == DateTime.saturday;
      final isBuildDay = isFriday || isSaturday;
      final isWeeknight = !isBuildDay;

      // Determine how many notifications for this day
      final slots = _daySlots(state, isBuildDay, overwhelmed);

      for (final hourMinute in slots) {
        if (notifId >= 1064) break;

        int hour = hourMinute[0];
        int minute = hourMinute[1];

        // Adjust based on learned peak hour for evening slots
        if (hour >= 19 && hour <= 22) {
          hour = (peakHour >= 18 && peakHour <= 23) ? peakHour : hour;
        }

        final mood = NotificationMessages.pickMood(
          stateStr,
          behavior.lastNotificationMood,
          isFriday: isFriday,
          isSaturday: isSaturday,
          isWeeknight: isWeeknight,
          isOverwhelmed: overwhelmed,
        );

        final template = NotificationMessages.pickTemplate(mood, tokens);

        final scheduledTime = tz.TZDateTime(
          tz.local,
          targetDate.year,
          targetDate.month,
          targetDate.day,
          hour,
          minute,
        );

        // Skip if in the past
        if (scheduledTime.isBefore(tz.TZDateTime.now(tz.local))) continue;

        await NotificationService.scheduleExact(
          id: notifId,
          title: template['title']!,
          body: template['body']!,
          dateTime: scheduledTime,
          badge: pendingCount,
        );

        notifId++;
      }
    }

    // Update behavior tracking
    await behaviorRepo.updateLastMood(stateStr);
    await behaviorRepo.updateLastScheduleRun();
  }

  static List<List<int>> _daySlots(EngagementState state, bool isBuildDay, bool overwhelmed) {
    if (overwhelmed) {
      // Halved frequency
      if (isBuildDay) {
        return [[9, 0 + _rng.nextInt(30)]];
      } else {
        return [[20, _rng.nextInt(30)]];
      }
    }

    switch (state) {
      case EngagementState.engaged:
        if (isBuildDay) {
          return [[9, _rng.nextInt(30)]];
        } else {
          return [[20, _rng.nextInt(30)]];
        }
      case EngagementState.coasting:
        if (isBuildDay) {
          return [
            [9, _rng.nextInt(30)],
            [13, _rng.nextInt(30)],
          ];
        } else {
          return [[20, _rng.nextInt(30)]];
        }
      case EngagementState.slipping:
        if (isBuildDay) {
          return [
            [9, _rng.nextInt(20)],
            [13, _rng.nextInt(30)],
            [17, _rng.nextInt(30)],
          ];
        } else {
          return [
            [20, _rng.nextInt(20)],
            [22, 30 + _rng.nextInt(15)],
          ];
        }
      case EngagementState.absent:
        if (isBuildDay) {
          return [
            [10, _rng.nextInt(30)],
            [16, _rng.nextInt(30)],
          ];
        } else {
          return [[20, _rng.nextInt(30)]];
        }
      case EngagementState.ghosting:
        // Every other day for weeknights, 1/day for build days
        if (isBuildDay) {
          return [[10, _rng.nextInt(30)]];
        } else {
          // 50% chance of skipping
          if (_rng.nextBool()) return [];
          return [[20, _rng.nextInt(30)]];
        }
    }
  }

  static DateTime? _latestOf(DateTime? a, DateTime? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a.isAfter(b) ? a : b;
  }

  static int _daysAway(UserBehavior behavior) {
    final last = _latestOf(behavior.lastTaskCompletion, behavior.lastAppOpen);
    if (last == null) return 0;
    return DateTime.now().difference(last).inDays;
  }
}
