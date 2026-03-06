import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repositories_provider.dart';

enum TimerState { idle, running, paused, completed }

enum TimerMode { focus, shortBreak, longBreak }

class TimerData {
  final TimerState state;
  final TimerMode mode;
  final int remainingSeconds;
  final int totalSeconds;
  final int sessionsCompleted;

  const TimerData({
    this.state = TimerState.idle,
    this.mode = TimerMode.focus,
    this.remainingSeconds = 25 * 60,
    this.totalSeconds = 25 * 60,
    this.sessionsCompleted = 0,
  });

  TimerData copyWith({
    TimerState? state,
    TimerMode? mode,
    int? remainingSeconds,
    int? totalSeconds,
    int? sessionsCompleted,
  }) {
    return TimerData(
      state: state ?? this.state,
      mode: mode ?? this.mode,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      sessionsCompleted: sessionsCompleted ?? this.sessionsCompleted,
    );
  }

  double get progress {
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  String get timeDisplay {
    final m = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerData>((ref) {
  return TimerNotifier(ref);
});

class TimerNotifier extends StateNotifier<TimerData> {
  final Ref _ref;
  Timer? _timer;

  TimerNotifier(this._ref) : super(const TimerData()) {
    _syncFromSettings();
  }

  void _syncFromSettings() {
    final settings = _ref.read(settingsRepoProvider).settings;
    final totalSeconds = settings.pomodoroMinutes * 60;
    state = TimerData(totalSeconds: totalSeconds, remainingSeconds: totalSeconds);
  }

  void start() {
    if (state.state == TimerState.completed) return;
    _timer?.cancel();
    state = state.copyWith(state: TimerState.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds <= 1) {
        _timer?.cancel();
        final newSessions = state.mode == TimerMode.focus
            ? state.sessionsCompleted + 1
            : state.sessionsCompleted;
        state = state.copyWith(
          state: TimerState.completed,
          remainingSeconds: 0,
          sessionsCompleted: newSessions,
        );
      } else {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(state: TimerState.paused);
  }

  void reset() {
    _timer?.cancel();
    _syncFromSettings();
  }

  void startBreak() {
    _timer?.cancel();
    final settings = _ref.read(settingsRepoProvider).settings;
    final isLong = state.sessionsCompleted % 4 == 0 && state.sessionsCompleted > 0;
    final mode = isLong ? TimerMode.longBreak : TimerMode.shortBreak;
    final seconds = isLong ? settings.longBreakMinutes * 60 : settings.shortBreakMinutes * 60;
    state = state.copyWith(
      state: TimerState.idle,
      mode: mode,
      totalSeconds: seconds,
      remainingSeconds: seconds,
    );
  }

  void startFocus() {
    _timer?.cancel();
    final settings = _ref.read(settingsRepoProvider).settings;
    final seconds = settings.pomodoroMinutes * 60;
    state = state.copyWith(
      state: TimerState.idle,
      mode: TimerMode.focus,
      totalSeconds: seconds,
      remainingSeconds: seconds,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
