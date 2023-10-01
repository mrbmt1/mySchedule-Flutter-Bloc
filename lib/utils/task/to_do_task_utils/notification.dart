import 'package:awesome_notifications/awesome_notifications.dart';

void notificationConfig(
  String title,
  String message,
  DateTime notificationTime,
  int notificationId,
) async {
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: notificationId,
      channelKey: 'channel_key',
      title: title,
      body: message,
    ),
    schedule: NotificationCalendar(
      day: notificationTime.day,
      month: notificationTime.month,
      year: notificationTime.year,
      hour: notificationTime.hour,
      minute: notificationTime.minute,
      second: 0,
      millisecond: 0,
      allowWhileIdle: true,
      repeats: false,
    ),
  );
}
