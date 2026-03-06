import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/models/week_plan.dart';
import 'data/models/task_item.dart';
import 'data/models/progress_entry.dart';
import 'data/models/app_settings.dart';
import 'data/models/reflection.dart';
import 'data/repositories/study_plan_repository.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/settings_repository.dart';
import 'data/repositories/reflection_repository.dart';
import 'providers/repositories_provider.dart';
import 'services/notification_service.dart';
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

  // Initialize repositories
  final studyPlanRepo = StudyPlanRepository();
  final progressRepo = ProgressRepository();
  final settingsRepo = SettingsRepository();
  final reflectionRepo = ReflectionRepository();

  await Future.wait([
    studyPlanRepo.init(),
    progressRepo.init(),
    settingsRepo.init(),
    reflectionRepo.init(),
  ]);

  // Seed on first run
  if (studyPlanRepo.isEmpty) {
    await studyPlanRepo.seed();
  }

  // Initialize notifications
  await NotificationService.init();

  runApp(
    ProviderScope(
      overrides: [
        studyPlanRepoProvider.overrideWithValue(studyPlanRepo),
        progressRepoProvider.overrideWithValue(progressRepo),
        settingsRepoProvider.overrideWithValue(settingsRepo),
        reflectionRepoProvider.overrideWithValue(reflectionRepo),
      ],
      child: const CloudStudyApp(),
    ),
  );
}
