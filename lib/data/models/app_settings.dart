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

  @HiveField(13)
  bool smartNotificationsEnabled;

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
    this.smartNotificationsEnabled = true,
  });

  AppSettings copyWith({
    bool? weeknightNotificationsEnabled,
    int? weeknightNotificationHour,
    int? weeknightNotificationMinute,
    bool? weekendNotificationsEnabled,
    int? weekendNotificationHour,
    int? weekendNotificationMinute,
    String? calendarId,
    int? pomodoroMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    DateTime? planStartDate,
    bool? darkModeOverride,
    bool? midSessionNotificationsEnabled,
    bool? smartNotificationsEnabled,
  }) {
    return AppSettings(
      weeknightNotificationsEnabled: weeknightNotificationsEnabled ?? this.weeknightNotificationsEnabled,
      weeknightNotificationHour: weeknightNotificationHour ?? this.weeknightNotificationHour,
      weeknightNotificationMinute: weeknightNotificationMinute ?? this.weeknightNotificationMinute,
      weekendNotificationsEnabled: weekendNotificationsEnabled ?? this.weekendNotificationsEnabled,
      weekendNotificationHour: weekendNotificationHour ?? this.weekendNotificationHour,
      weekendNotificationMinute: weekendNotificationMinute ?? this.weekendNotificationMinute,
      calendarId: calendarId ?? this.calendarId,
      pomodoroMinutes: pomodoroMinutes ?? this.pomodoroMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      planStartDate: planStartDate ?? this.planStartDate,
      darkModeOverride: darkModeOverride ?? this.darkModeOverride,
      midSessionNotificationsEnabled: midSessionNotificationsEnabled ?? this.midSessionNotificationsEnabled,
      smartNotificationsEnabled: smartNotificationsEnabled ?? this.smartNotificationsEnabled,
    );
  }
}
