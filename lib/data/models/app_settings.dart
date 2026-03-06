import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool weeknightNotificationsEnabled;

  @HiveField(1)
  int weeknightNotificationHour;

  @HiveField(2)
  int weeknightNotificationMinute;

  @HiveField(3)
  bool weekendNotificationsEnabled;

  @HiveField(4)
  int weekendNotificationHour;

  @HiveField(5)
  int weekendNotificationMinute;

  @HiveField(6)
  String? calendarId;

  @HiveField(7)
  int pomodoroMinutes;

  @HiveField(8)
  int shortBreakMinutes;

  @HiveField(9)
  int longBreakMinutes;

  @HiveField(10)
  DateTime? planStartDate;

  @HiveField(11)
  bool? darkModeOverride;

  @HiveField(12)
  bool midSessionNotificationsEnabled;

  AppSettings({
    this.weeknightNotificationsEnabled = false,
    this.weeknightNotificationHour = 20,
    this.weeknightNotificationMinute = 0,
    this.weekendNotificationsEnabled = false,
    this.weekendNotificationHour = 9,
    this.weekendNotificationMinute = 0,
    this.calendarId,
    this.pomodoroMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.planStartDate,
    this.darkModeOverride,
    this.midSessionNotificationsEnabled = false,
  });
}
