import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/week_plan.dart';
import 'data/models/task_item.dart';
import 'data/models/progress_entry.dart';
import 'data/models/app_settings.dart';
import 'data/models/reflection.dart';
import 'data/models/user_behavior.dart';
import 'data/repositories/study_plan_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/reflection_repository.dart';
import 'data/repositories/behavior_repository.dart';
import 'providers/behavior_provider.dart';
import 'providers/repositories_provider.dart';
import 'services/notification_service.dart';
import 'services/smart_notification_engine.dart';
import 'services/widget_service.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskItemAdapter());
  Hive.registerAdapter(WeekPlanAdapter());
  Hive.registerAdapter(ProgressEntryAdapter());
  Hive.registerAdapter(AppSettingsAdapter());
  Hive.registerAdapter(ReflectionAdapter());
  Hive.registerAdapter(UserBehaviorAdapter());

  // Initialize repositories
  final studyPlanRepo = StudyPlanRepository();
  final progressRepo = ProgressRepository();
  final settingsRepo = SettingsRepository();
  final reflectionRepo = ReflectionRepository();
  final behaviorRepo = BehaviorRepository();

  await Future.wait([
    studyPlanRepo.init(),
    progressRepo.init(),
    settingsRepo.init(),
    reflectionRepo.init(),
    behaviorRepo.init(),
  ]);

  // Seed on first run
  if (studyPlanRepo.isEmpty) {
    await studyPlanRepo.seed();
  }

  // Initialize notifications
  await NotificationService.init();

  final settingsForNotif = settingsRepo.settings;

  // Always record app open for behavior tracking
  await behaviorRepo.recordAppOpen();

  // Smart notifications: schedule if enabled
  if (settingsForNotif.smartNotificationsEnabled) {
    await SmartNotificationEngine.computeAndSchedule(
      behaviorRepo: behaviorRepo,
      progressRepo: progressRepo,
      studyPlanRepo: studyPlanRepo,
      settingsRepo: settingsRepo,
    );
  }

  // Fallback: simple recurring notifications when smart mode is off
  if (!settingsForNotif.smartNotificationsEnabled) {
    if (settingsForNotif.weeknightNotificationsEnabled) {
      await NotificationService.scheduleWeeknight(
        hour: settingsForNotif.weeknightNotificationHour,
        minute: settingsForNotif.weeknightNotificationMinute,
      );
    }
    if (settingsForNotif.weekendNotificationsEnabled) {
      await NotificationService.scheduleWeekend(
        hour: settingsForNotif.weekendNotificationHour,
        minute: settingsForNotif.weekendNotificationMinute,
      );
    }
  }

  // Update iOS widgets with current data
  final startDate = settingsRepo.settings.planStartDate;
  int currentWeek = 1;
  if (startDate != null) {
    currentWeek = ((DateTime.now().difference(startDate).inDays / 7).floor() + 1).clamp(1, 10);
  }
  WidgetService.updateWidgets(
    plans: studyPlanRepo.getAll(),
    progressRepo: progressRepo,
    currentWeek: currentWeek,
    planStartDate: startDate,
  );

  runApp(
    ProviderScope(
      overrides: [
        studyPlanRepoProvider.overrideWithValue(studyPlanRepo),
        progressRepoProvider.overrideWithValue(progressRepo),
        settingsRepoProvider.overrideWithValue(settingsRepo),
        reflectionRepoProvider.overrideWithValue(reflectionRepo),
        behaviorRepoProvider.overrideWithValue(behaviorRepo),
      ],
      child: const CloudStudyApp(),
    ),
  );
}
