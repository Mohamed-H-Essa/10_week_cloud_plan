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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: 'PLAN'),
          _AnimatedSettingsTile(
            leading: const Icon(Icons.calendar_today),
            title: 'Plan Start Date',
            subtitle: settings.planStartDate != null
                ? DateFormat.yMMMd().format(settings.planStartDate!)
                : 'Tap to set your start date',
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

          const Divider(height: 1),
          _SectionHeader(title: 'NOTIFICATIONS'),
          SwitchListTile(
            secondary: const Icon(Icons.nights_stay),
            title: const Text('Weeknight Reminders'),
            subtitle: Text('Sun–Thu at ${_formatTime(settings.weeknightNotificationHour, settings.weeknightNotificationMinute)}'),
            value: settings.weeknightNotificationsEnabled,
            onChanged: (v) => notifier.setWeeknightNotifications(v),
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
                  await notifier.setWeeknightTime(time.hour, time.minute);
                }
              },
            ),
          SwitchListTile(
            secondary: const Icon(Icons.wb_sunny),
            title: const Text('Weekend Reminders'),
            subtitle: Text('Fri & Sat at ${_formatTime(settings.weekendNotificationHour, settings.weekendNotificationMinute)}'),
            value: settings.weekendNotificationsEnabled,
            onChanged: (v) => notifier.setWeekendNotifications(v),
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
                  await notifier.setWeekendTime(time.hour, time.minute);
                }
              },
            ),
          SwitchListTile(
            secondary: const Icon(Icons.notification_important_outlined),
            title: const Text('Mid-Session Check'),
            subtitle: const Text('Halfway through study session'),
            value: settings.midSessionNotificationsEnabled,
            onChanged: (v) => notifier.setMidSessionNotifications(v),
          ),

          const Divider(height: 1),
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

          const Divider(height: 1),
          _SectionHeader(title: 'DATA'),
          _AnimatedSettingsTile(
            leading: const Icon(Icons.ios_share),
            title: 'Export Progress',
            subtitle: 'Share as markdown',
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ExportService.exportProgress(ref),
          ),

          const Divider(height: 1),
          _SectionHeader(title: 'GOOGLE CALENDAR'),
          _AnimatedSettingsTile(
            leading: Icon(Icons.event, color: isDark ? Colors.grey.shade600 : Colors.grey.shade400),
            title: 'Connect Google Calendar',
            subtitle: 'Coming soon',
            trailing: const Icon(Icons.chevron_right),
            onTap: null,
          ),

          const SizedBox(height: 40),
          Center(
            child: Text(
              'Cloud Study v1.0.0',
              style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.grey.shade500),
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
}

class _AnimatedSettingsTile extends StatefulWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _AnimatedSettingsTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  State<_AnimatedSettingsTile> createState() => _AnimatedSettingsTileState();
}

class _AnimatedSettingsTileState extends State<_AnimatedSettingsTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: ListTile(
          leading: widget.leading,
          title: Text(widget.title),
          subtitle: Text(widget.subtitle),
          trailing: widget.trailing,
          enabled: widget.onTap != null,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        title,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
