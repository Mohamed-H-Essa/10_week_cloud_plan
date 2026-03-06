import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../providers/settings_provider.dart';
import '../../services/export_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        children: [
          // Plan Start Date
          _SectionHeader(title: 'PLAN'),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Plan Start Date'),
            subtitle: Text(
              settings.planStartDate != null
                  ? DateFormat.yMMMd().format(settings.planStartDate!)
                  : 'Not set',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: settings.planStartDate ?? DateTime.now(),
                firstDate: DateTime(2024),
                lastDate: DateTime(2027),
              );
              if (date != null) {
                await notifier.setPlanStartDate(date);
              }
            },
          ),

          const Divider(),
          _SectionHeader(title: 'NOTIFICATIONS'),
          SwitchListTile(
            secondary: const Icon(Icons.nights_stay),
            title: const Text('Weeknight Reminders'),
            subtitle: Text('Mon-Fri at ${_formatTime(settings.weeknightNotificationHour, settings.weeknightNotificationMinute)}'),
            value: settings.weeknightNotificationsEnabled,
            onChanged: (v) async {
              await notifier.update((s) => s.weeknightNotificationsEnabled = v);
            },
          ),
          if (settings.weeknightNotificationsEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Reminder Time'),
              trailing: Text(
                _formatTime(settings.weeknightNotificationHour, settings.weeknightNotificationMinute),
                style: GoogleFonts.jetBrainsMono(fontSize: 14),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.weeknightNotificationHour,
                    minute: settings.weeknightNotificationMinute,
                  ),
                );
                if (time != null) {
                  await notifier.update((s) {
                    s.weeknightNotificationHour = time.hour;
                    s.weeknightNotificationMinute = time.minute;
                  });
                }
              },
            ),
          SwitchListTile(
            secondary: const Icon(Icons.wb_sunny),
            title: const Text('Weekend Reminders'),
            subtitle: Text('Fri & Sat at ${_formatTime(settings.weekendNotificationHour, settings.weekendNotificationMinute)}'),
            value: settings.weekendNotificationsEnabled,
            onChanged: (v) async {
              await notifier.update((s) => s.weekendNotificationsEnabled = v);
            },
          ),
          if (settings.weekendNotificationsEnabled)
            ListTile(
              leading: const SizedBox(width: 24),
              title: const Text('Reminder Time'),
              trailing: Text(
                _formatTime(settings.weekendNotificationHour, settings.weekendNotificationMinute),
                style: GoogleFonts.jetBrainsMono(fontSize: 14),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: settings.weekendNotificationHour,
                    minute: settings.weekendNotificationMinute,
                  ),
                );
                if (time != null) {
                  await notifier.update((s) {
                    s.weekendNotificationHour = time.hour;
                    s.weekendNotificationMinute = time.minute;
                  });
                }
              },
            ),
          SwitchListTile(
            secondary: const Icon(Icons.timer),
            title: const Text('Mid-Session Check'),
            subtitle: const Text('Halfway through study session'),
            value: settings.midSessionNotificationsEnabled,
            onChanged: (v) async {
              await notifier.update((s) => s.midSessionNotificationsEnabled = v);
            },
          ),

          const Divider(),
          _SectionHeader(title: 'TIMER'),
          ListTile(
            leading: const Icon(Icons.work_history),
            title: const Text('Focus Duration'),
            trailing: Text('${settings.pomodoroMinutes} min', style: GoogleFonts.jetBrainsMono(fontSize: 14)),
            onTap: () => _showDurationPicker(context, 'Focus Duration', settings.pomodoroMinutes, (v) => notifier.setPomodoroMinutes(v)),
          ),
          ListTile(
            leading: const Icon(Icons.coffee),
            title: const Text('Short Break'),
            trailing: Text('${settings.shortBreakMinutes} min', style: GoogleFonts.jetBrainsMono(fontSize: 14)),
            onTap: () => _showDurationPicker(context, 'Short Break', settings.shortBreakMinutes, (v) => notifier.setShortBreakMinutes(v)),
          ),
          ListTile(
            leading: const Icon(Icons.self_improvement),
            title: const Text('Long Break'),
            trailing: Text('${settings.longBreakMinutes} min', style: GoogleFonts.jetBrainsMono(fontSize: 14)),
            onTap: () => _showDurationPicker(context, 'Long Break', settings.longBreakMinutes, (v) => notifier.setLongBreakMinutes(v)),
          ),

          const Divider(),
          _SectionHeader(title: 'APPEARANCE'),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            trailing: SegmentedButton<bool?>(
              segments: const [
                ButtonSegment(value: null, label: Text('Auto')),
                ButtonSegment(value: false, label: Text('Light')),
                ButtonSegment(value: true, label: Text('Dark')),
              ],
              selected: {settings.darkModeOverride},
              onSelectionChanged: (v) => notifier.setDarkMode(v.first),
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                textStyle: WidgetStatePropertyAll(GoogleFonts.jetBrainsMono(fontSize: 11)),
              ),
            ),
          ),

          const Divider(),
          _SectionHeader(title: 'DATA'),
          ListTile(
            leading: const Icon(Icons.ios_share),
            title: const Text('Export Progress'),
            subtitle: const Text('Share as markdown'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ExportService.exportProgress(ref),
          ),

          const Divider(),
          _SectionHeader(title: 'GOOGLE CALENDAR'),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('Connect Google Calendar'),
            subtitle: const Text('Coming soon'),
            trailing: const Icon(Icons.chevron_right),
            enabled: false,
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Cloud Study v1.0.0',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final amPm = hour >= 12 ? 'PM' : 'AM';
    return '$h:${minute.toString().padLeft(2, '0')} $amPm';
  }

  void _showDurationPicker(BuildContext context, String title, int currentValue, ValueChanged<int> onChanged) {
    showDialog(
      context: context,
      builder: (context) {
        int value = currentValue;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text(title),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: value > 1 ? () => setState(() => value--) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(
                  '$value min',
                  style: GoogleFonts.jetBrainsMono(fontSize: 24, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  onPressed: value < 120 ? () => setState(() => value++) : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  onChanged(value);
                  Navigator.pop(context);
                },
                child: const Text('Set'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
