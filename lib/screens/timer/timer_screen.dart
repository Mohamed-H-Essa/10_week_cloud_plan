import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/timer_provider.dart';
import '../../shared/widgets/progress_ring.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);

    final modeLabel = switch (timer.mode) {
      TimerMode.focus => 'Focus',
      TimerMode.shortBreak => 'Short Break',
      TimerMode.longBreak => 'Long Break',
    };

    final modeColor = switch (timer.mode) {
      TimerMode.focus => Theme.of(context).colorScheme.primary,
      TimerMode.shortBreak => Colors.green,
      TimerMode.longBreak => Colors.teal,
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('Timer', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode selector
            SegmentedButton<TimerMode>(
              segments: const [
                ButtonSegment(value: TimerMode.focus, label: Text('Focus')),
                ButtonSegment(value: TimerMode.shortBreak, label: Text('Short')),
                ButtonSegment(value: TimerMode.longBreak, label: Text('Long')),
              ],
              selected: {timer.mode},
              onSelectionChanged: (modes) {
                final mode = modes.first;
                if (mode == TimerMode.focus) {
                  notifier.startFocus();
                } else {
                  notifier.startBreak();
                }
              },
            ),
            const SizedBox(height: 48),

            // Timer ring
            ProgressRing(
              progress: timer.progress,
              size: 240,
              strokeWidth: 10,
              color: modeColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    timer.timeDisplay,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    modeLabel,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: modeColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Reset
                IconButton.outlined(
                  onPressed: notifier.reset,
                  icon: const Icon(Icons.refresh),
                  iconSize: 28,
                ),
                const SizedBox(width: 24),

                // Play/Pause
                if (timer.state == TimerState.completed)
                  FilledButton.icon(
                    onPressed: timer.mode == TimerMode.focus
                        ? notifier.startBreak
                        : notifier.startFocus,
                    icon: const Icon(Icons.skip_next),
                    label: Text(timer.mode == TimerMode.focus ? 'Break' : 'Focus'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 56),
                      backgroundColor: modeColor,
                    ),
                  )
                else
                  FilledButton.icon(
                    onPressed: timer.state == TimerState.running
                        ? notifier.pause
                        : notifier.start,
                    icon: Icon(
                      timer.state == TimerState.running ? Icons.pause : Icons.play_arrow,
                    ),
                    label: Text(
                      timer.state == TimerState.running ? 'Pause' : 'Start',
                    ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(140, 56),
                      backgroundColor: modeColor,
                    ),
                  ),
                const SizedBox(width: 24),

                // Skip
                IconButton.outlined(
                  onPressed: timer.mode == TimerMode.focus
                      ? notifier.startBreak
                      : notifier.startFocus,
                  icon: const Icon(Icons.skip_next),
                  iconSize: 28,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Session counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: modeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${timer.sessionsCompleted} session${timer.sessionsCompleted == 1 ? '' : 's'} completed',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: modeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
