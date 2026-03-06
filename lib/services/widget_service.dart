import 'dart:convert';
import 'package:flutter/services.dart';
import '../data/models/week_plan.dart';
import '../data/repositories/progress_repository.dart';
import 'motivation_service.dart' as motivation;

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
    int streak = 0,
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
      final motivationMsg = motivation.getMotivation(currentWeek, overallProgress);

      // Day type and today's tasks
      final now = DateTime.now();
      final dayType = switch (now.weekday) {
        DateTime.friday => 'friday',
        DateTime.saturday => 'saturday',
        _ => 'weeknight',
      };

      final saaTopic = currentPlan?.weeknightSaa ?? '';

      List<Map<String, dynamic>> todayTasks = [];
      String nextTask = '';
      if (currentPlan != null) {
        final tasks = dayType == 'friday'
            ? currentPlan.fridayTasks
            : dayType == 'saturday'
                ? currentPlan.saturdayTasks
                : [];
        todayTasks = tasks
            .map((t) => {
                  'text': t.text,
                  'completed': completedIds.contains(t.id),
                })
            .toList();
        try {
          nextTask = tasks
              .firstWhere((t) => !completedIds.contains(t.id))
              .text;
        } catch (_) {}
      }

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
        'motivation': motivationMsg,
        'updatedAt': DateTime.now().toIso8601String(),
        'streak': streak,
        'dayType': dayType,
        'saaTopic': saaTopic,
        'todayTasks': todayTasks,
        'nextTask': nextTask,
      };

      await _channel.invokeMethod('updateWidgets', {
        'appGroup': _appGroup,
        'data': jsonEncode(data),
      });
    } catch (e) {
      // Widget updates are best-effort, don't crash the app
    }
  }

  // Motivation logic extracted to motivation_service.dart

  // ── Live Activity (Dynamic Island) ──

  /// Start a Live Activity for the current study session.
  /// [sessionType]: "build", "deploy", or "study"
  static Future<void> startLiveActivity({
    required String sessionType,
    required int weekNumber,
    required String weekTitle,
    required String phase,
    required int totalMinutes,
    required int tasksCompleted,
    required int tasksTotal,
  }) async {
    try {
      await _channel.invokeMethod('startLiveActivity', {
        'sessionType': sessionType,
        'weekNumber': weekNumber,
        'weekTitle': weekTitle,
        'phase': phase,
        'totalMinutes': totalMinutes,
        'elapsedMinutes': 0,
        'tasksCompleted': tasksCompleted,
        'tasksTotal': tasksTotal,
        'motivation': motivation.getMotivation(weekNumber, 0),
      });
    } catch (e) {
      // Best-effort
    }
  }

  /// Update the Live Activity with new elapsed time / task count.
  static Future<void> updateLiveActivity({
    required int elapsedMinutes,
    required int totalMinutes,
    required int tasksCompleted,
    required int tasksTotal,
    required String motivation,
  }) async {
    try {
      await _channel.invokeMethod('updateLiveActivity', {
        'elapsedMinutes': elapsedMinutes,
        'totalMinutes': totalMinutes,
        'tasksCompleted': tasksCompleted,
        'tasksTotal': tasksTotal,
        'motivation': motivation,
      });
    } catch (e) {
      // Best-effort
    }
  }

  /// End the Live Activity.
  static Future<void> endLiveActivity() async {
    try {
      await _channel.invokeMethod('endLiveActivity');
    } catch (e) {
      // Best-effort
    }
  }
}
