import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );
  }

  Future<void> scheduleMedicationReminder({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required List<int> daysOfWeek,
  }) async {
    // Schedule recurring reminders for each specified weekday
    final now = tz.TZDateTime.now(tz.local);
    for (final d in daysOfWeek) {
      // Build next date for given weekday at the specified time
      int daysUntil = (d - now.weekday) % 7;
      if (daysUntil < 0) daysUntil += 7;
      tz.TZDateTime scheduledDate = tz.TZDateTime.local(now.year, now.month, now.day, hour, minute)
          .add(Duration(days: daysUntil));
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 7));
      }

      final int uniqueId = id * 10 + d; // ensure unique IDs per day
      await _notificationsPlugin.zonedSchedule(
        id: uniqueId,
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Medication Reminders',
            channelDescription: 'Notifications for scheduled medication doses',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelReminder(int id) async {
    await _notificationsPlugin.cancel(id: id);
  }

  Future<void> cancelAllReminders() async {
    await _notificationsPlugin.cancelAll();
  }
}
