import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/study_plan_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/reflection_repository.dart';

final studyPlanRepoProvider = Provider<StudyPlanRepository>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final progressRepoProvider = Provider<ProgressRepository>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final reflectionRepoProvider = Provider<ReflectionRepository>((ref) {
  throw UnimplementedError('Must be overridden in main');
});
