import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
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
}
