import 'package:hive/hive.dart';

part 'user_behavior.g.dart';

@HiveType(typeId: 5)
class UserBehavior extends HiveObject {
  @HiveField(0)
  DateTime? lastAppOpen;

  @HiveField(1)
  DateTime? lastTaskCompletion;

  @HiveField(2)
  List<int> activeHours;

  @HiveField(3)
  List<DateTime> appOpenHistory;

  @HiveField(4)
  List<DateTime> taskCompletionHistory;

  @HiveField(5)
  int consecutiveIgnoredDays;

  @HiveField(6)
  String? lastNotificationMood;

  @HiveField(7)
  DateTime? lastScheduleRun;

  @HiveField(8)
  int comebackMessagesSent;

  UserBehavior({
    this.lastAppOpen,
    this.lastTaskCompletion,
    List<int>? activeHours,
    List<DateTime>? appOpenHistory,
    List<DateTime>? taskCompletionHistory,
    this.consecutiveIgnoredDays = 0,
    this.lastNotificationMood,
    this.lastScheduleRun,
    this.comebackMessagesSent = 0,
  })  : activeHours = activeHours ?? List.filled(24, 0),
        appOpenHistory = appOpenHistory ?? [],
        taskCompletionHistory = taskCompletionHistory ?? [];
}
