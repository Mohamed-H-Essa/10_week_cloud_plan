import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/models/week_plan.dart';
import '../data/repositories/progress_repository.dart';

/// Bridges Flutter data to iOS WidgetKit via shared UserDefaults (App Group).
class WidgetService {
  static const _channel = MethodChannel('com.cloudstudy/widgets');
  static const _appGroup = 'group.com.cloudstudy.widgets';

  /// Update widget data whenever progress changes.
  static Future<void> updateWidgets({
    required List<WeekPlan> plans,
    required ProgressRepository progressRepo,
    required int currentWeek,
    required DateTime? planStartDate,
  }) async {
    try {
      // Calculate progress
      int totalTasks = 0;
      int completedTasks = 0;
      final completedIds = progressRepo.completedTaskIds();

      for (final plan in plans) {
        final ids = [
          ...plan.fridayTasks.map((t) => t.id),
          ...plan.saturdayTasks.map((t) => t.id),
        ];
        totalTasks += ids.length;
        completedTasks += ids.where((id) => completedIds.contains(id)).length;
      }

      final overallProgress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

      // Current week info
      final currentPlan = plans.isNotEmpty && currentWeek >= 1 && currentWeek <= plans.length
          ? plans[currentWeek - 1]
          : null;

      int weekCompleted = 0;
      int weekTotal = 0;
      if (currentPlan != null) {
        final weekIds = [
          ...currentPlan.fridayTasks.map((t) => t.id),
          ...currentPlan.saturdayTasks.map((t) => t.id),
        ];
        weekTotal = weekIds.length;
        weekCompleted = weekIds.where((id) => completedIds.contains(id)).length;
      }

      // Exam countdown
      int examDaysLeft = -1;
      if (planStartDate != null) {
        final examDate = planStartDate.add(const Duration(days: 6 * 7));
        examDaysLeft = examDate.difference(DateTime.now()).inDays;
      }

      // Motivation message based on day/time
      final motivation = _getMotivation(currentWeek, overallProgress);

      final data = {
        'overallProgress': overallProgress,
        'totalTasks': totalTasks,
        'completedTasks': completedTasks,
        'currentWeek': currentWeek,
        'weekTitle': currentPlan?.title ?? 'Week $currentWeek',
        'weekPhase': currentPlan?.phase ?? 'CONTAINERS',
        'weekProgress': weekTotal > 0 ? weekCompleted / weekTotal : 0.0,
        'weekCompleted': weekCompleted,
        'weekTotal': weekTotal,
        'examDaysLeft': examDaysLeft,
        'motivation': motivation,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await _channel.invokeMethod('updateWidgets', {
        'appGroup': _appGroup,
        'data': jsonEncode(data),
      });
    } catch (e) {
      // Widget updates are best-effort, don't crash the app
    }
  }

  static String _getMotivation(int currentWeek, double progress) {
    final now = DateTime.now();
    final hour = now.hour;
    final weekday = now.weekday;

    // Day-specific messages
    if (weekday == DateTime.friday || weekday == DateTime.saturday) {
      // Off days
      final offMessages = [
        "Rest today. War resumes Sunday.",
        "Recharge. The cluster doesn't deploy itself.",
        "Even AWS takes maintenance windows.",
        "Off day. But your competition might not be resting.",
      ];
      return offMessages[now.day % offMessages.length];
    }

    if (weekday == DateTime.sunday) {
      if (hour < 10) {
        return "It's Sunday. Time to build. No excuses.";
      } else if (hour < 14) {
        return "Build session is NOW. Open the terminal.";
      } else {
        return "Sunday's not over. Ship something before midnight.";
      }
    }

    if (weekday == DateTime.monday) {
      if (hour < 10) {
        return "Monday deploy day. Break what you built yesterday.";
      } else {
        return "Deploy, test, break it. That's the loop.";
      }
    }

    // Weeknight study (Tue-Thu)
    if (hour < 12) {
      final morningMessages = [
        "Tonight: SAA study. No Netflix. You chose this.",
        "Every skipped night = 1 more week stuck where you are.",
        "25 minutes tonight. That's it. You can do 25 minutes.",
      ];
      return morningMessages[now.day % morningMessages.length];
    }

    if (hour >= 18 && hour < 22) {
      final eveningMessages = [
        "It's study time. Open the course. NOW.",
        "15 minutes counts. Perfection is the enemy.",
        "The people getting hired are studying right now.",
        "Skip tonight and explain to future you why.",
        "Even 1 practice question > 0 practice questions.",
      ];
      return eveningMessages[now.minute % eveningMessages.length];
    }

    if (hour >= 22) {
      return "Late but not too late. Even 15 min counts.";
    }

    // Progress-based
    if (progress == 0) {
      return "Zero progress. The plan won't execute itself.";
    }
    if (progress < 0.2) {
      return "Week $currentWeek of 10. Momentum hasn't kicked in yet. Keep going.";
    }
    if (progress < 0.5) {
      return "${(progress * 100).round()}% done. You're in the thick of it. Don't quit now.";
    }
    if (progress < 0.8) {
      return "Past halfway. The hardest part is behind you.";
    }
    return "Almost there. Finish what you started.";
  }
}
