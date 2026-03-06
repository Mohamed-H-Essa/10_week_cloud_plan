import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  static Future<bool> requestPermissions() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  static Future<void> scheduleWeeknight({
    required int hour,
    required int minute,
  }) async {
    await cancelGroup('weeknight');

    // Study nights: Sun-Thu evenings (workday evenings for SAA-C03)
    final studyNights = [DateTime.sunday, DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday];
    for (final weekday in studyNights) {
      await _plugin.zonedSchedule(
        100 + weekday,
        'Study Time',
        'Time for your study session',
        _nextInstanceOfWeekdayTime(weekday, hour, minute),
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> scheduleWeekend({
    required int hour,
    required int minute,
  }) async {
    await cancelGroup('weekend');

    // Build days: Friday (build) & Saturday (deploy/test)
    for (final weekday in [DateTime.friday, DateTime.saturday]) {
      await _plugin.zonedSchedule(
        200 + weekday,
        'Build Day',
        weekday == DateTime.friday ? 'Friday build session!' : 'Saturday deploy session!',
        _nextInstanceOfWeekdayTime(weekday, hour, minute),
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  static Future<void> showTimerComplete() async {
    await _plugin.show(
      300,
      'Timer Complete!',
      'Great work! Time for a break.',
      const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> scheduleExact({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime dateTime,
    int badge = 0,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      dateTime,
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: badge,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelSmartRange() async {
    for (int i = 1000; i < 1064; i++) {
      await _plugin.cancel(i);
    }
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  static Future<void> cancelGroup(String group) async {
    final int start = group == 'weeknight' ? 100 : 200;
    for (int i = start; i < start + 8; i++) {
      await _plugin.cancel(i);
    }
  }

  static tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    return scheduled;
  }
}
