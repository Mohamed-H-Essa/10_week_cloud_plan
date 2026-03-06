import 'package:hive/hive.dart';
import '../models/user_behavior.dart';

class BehaviorRepository {
  static const _boxName = 'behavior';
  static const _key = 'user_behavior';

  late Box<UserBehavior> _box;

  Future<void> init() async {
    _box = await Hive.openBox<UserBehavior>(_boxName);
    if (_box.get(_key) == null) {
      await _box.put(_key, UserBehavior());
    }
  }

  UserBehavior get behavior => _box.get(_key) ?? UserBehavior();

  Future<void> _save(UserBehavior b) async {
    await _box.put(_key, b);
  }

  Future<void> recordAppOpen() async {
    final b = behavior;
    final now = DateTime.now();
    b.lastAppOpen = now;
    b.activeHours[now.hour] = (b.activeHours[now.hour]) + 1;
    b.appOpenHistory.add(now);
    // Keep last 30 entries
    if (b.appOpenHistory.length > 30) {
      b.appOpenHistory = b.appOpenHistory.sublist(b.appOpenHistory.length - 30);
    }
    await _save(b);
  }

  Future<void> recordTaskCompletion() async {
    final b = behavior;
    final now = DateTime.now();
    b.lastTaskCompletion = now;
    b.consecutiveIgnoredDays = 0;
    b.comebackMessagesSent = 0;
    b.activeHours[now.hour] = (b.activeHours[now.hour]) + 1;
    b.taskCompletionHistory.add(now);
    // Keep last 50 entries
    if (b.taskCompletionHistory.length > 50) {
      b.taskCompletionHistory = b.taskCompletionHistory.sublist(b.taskCompletionHistory.length - 50);
    }
    await _save(b);
  }

  Future<void> recordNotificationTap() async {
    final b = behavior;
    b.consecutiveIgnoredDays = 0;
    await _save(b);
  }

  Future<void> updateLastMood(String mood) async {
    final b = behavior;
    b.lastNotificationMood = mood;
    await _save(b);
  }

  Future<void> updateLastScheduleRun() async {
    final b = behavior;
    b.lastScheduleRun = DateTime.now();
    await _save(b);
  }

  Future<void> incrementIgnoredDays() async {
    final b = behavior;
    b.consecutiveIgnoredDays++;
    await _save(b);
  }

  Future<void> incrementComebackMessages() async {
    final b = behavior;
    b.comebackMessagesSent++;
    await _save(b);
  }

  int peakHour() {
    final hours = behavior.activeHours;
    int maxVal = 0;
    int peakH = 20; // default 8pm
    for (int i = 0; i < 24; i++) {
      if (hours[i] > maxVal) {
        maxVal = hours[i];
        peakH = i;
      }
    }
    return peakH;
  }
}
