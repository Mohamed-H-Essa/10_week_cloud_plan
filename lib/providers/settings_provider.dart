import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import '../services/notification_service.dart';
import 'repositories_provider.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  return SettingsNotifier(ref);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(AppSettings()) {
    state = _ref.read(settingsRepoProvider).settings;
  }

  Future<void> update(void Function(AppSettings s) updater) async {
    await _ref.read(settingsRepoProvider).update(updater);
    state = _ref.read(settingsRepoProvider).settings;
  }

  Future<void> setPlanStartDate(DateTime date) async {
    await update((s) => s.planStartDate = date);
  }

  Future<void> setDarkMode(bool? value) async {
    await update((s) => s.darkModeOverride = value);
  }

  Future<void> setPomodoroMinutes(int minutes) async {
    await update((s) => s.pomodoroMinutes = minutes);
  }

  Future<void> setShortBreakMinutes(int minutes) async {
    await update((s) => s.shortBreakMinutes = minutes);
  }

  Future<void> setLongBreakMinutes(int minutes) async {
    await update((s) => s.longBreakMinutes = minutes);
  }

  Future<void> setWeeknightNotifications(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.requestPermissions();
      if (!granted) return;
    }
    await update((s) => s.weeknightNotificationsEnabled = enabled);
    if (enabled) {
      await NotificationService.scheduleWeeknight(
        hour: state.weeknightNotificationHour,
        minute: state.weeknightNotificationMinute,
      );
    } else {
      await NotificationService.cancelGroup('weeknight');
    }
  }

  Future<void> setWeekendNotifications(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService.requestPermissions();
      if (!granted) return;
    }
    await update((s) => s.weekendNotificationsEnabled = enabled);
    if (enabled) {
      await NotificationService.scheduleWeekend(
        hour: state.weekendNotificationHour,
        minute: state.weekendNotificationMinute,
      );
    } else {
      await NotificationService.cancelGroup('weekend');
    }
  }

  Future<void> setWeeknightTime(int hour, int minute) async {
    await update((s) {
      s.weeknightNotificationHour = hour;
      s.weeknightNotificationMinute = minute;
    });
    if (state.weeknightNotificationsEnabled) {
      await NotificationService.scheduleWeeknight(hour: hour, minute: minute);
    }
  }

  Future<void> setWeekendTime(int hour, int minute) async {
    await update((s) {
      s.weekendNotificationHour = hour;
      s.weekendNotificationMinute = minute;
    });
    if (state.weekendNotificationsEnabled) {
      await NotificationService.scheduleWeekend(hour: hour, minute: minute);
    }
  }

  Future<void> setMidSessionNotifications(bool enabled) async {
    if (enabled) {
      await NotificationService.requestPermissions();
    }
    await update((s) => s.midSessionNotificationsEnabled = enabled);
  }

  /// Re-schedule all enabled notifications (call on app startup)
  Future<void> restoreNotifications() async {
    if (state.weeknightNotificationsEnabled) {
      await NotificationService.scheduleWeeknight(
        hour: state.weeknightNotificationHour,
        minute: state.weeknightNotificationMinute,
      );
    }
    if (state.weekendNotificationsEnabled) {
      await NotificationService.scheduleWeekend(
        hour: state.weekendNotificationHour,
        minute: state.weekendNotificationMinute,
      );
    }
  }
}
