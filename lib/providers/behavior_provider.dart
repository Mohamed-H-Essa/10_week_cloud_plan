import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/behavior_repository.dart';
import '../services/smart_notification_engine.dart';
import 'repositories_provider.dart';

final behaviorRepoProvider = Provider<BehaviorRepository>((ref) {
  throw UnimplementedError('Must be overridden in main');
});

final smartNotificationProvider = Provider((ref) {
  return _SmartNotificationHelper(ref);
});

class _SmartNotificationHelper {
  final Ref _ref;

  _SmartNotificationHelper(this._ref);

  Future<void> reschedule() async {
    final settings = _ref.read(settingsRepoProvider).settings;
    if (!settings.smartNotificationsEnabled) return;

    await SmartNotificationEngine.computeAndSchedule(
      behaviorRepo: _ref.read(behaviorRepoProvider),
      progressRepo: _ref.read(progressRepoProvider),
      studyPlanRepo: _ref.read(studyPlanRepoProvider),
      settingsRepo: _ref.read(settingsRepoProvider),
    );
  }
}
