import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoItem {
  final String id;
  final String content;
  bool completed;
  DateTime? date;
  String? description;
  TimeOfDay? time;
  TimeOfDay? timeNotification;
  bool isNotification;
  int notificationID;

  TodoItem({
    required this.id,
    required this.content,
    this.completed = false,
    this.description,
    required this.notificationID,
    this.date,
    this.time,
    this.timeNotification,
    this.isNotification = false,
  }) : assert(id != null);

  DateTime getDateTime() {
    final now = DateTime.now();
    final year = date?.year ?? now.year;
    final month = date?.month ?? now.month;
    final day = date?.day ?? now.day;
    final hour = time?.hour ?? TimeOfDay.now().hour;
    final minute = time?.minute ?? TimeOfDay.now().minute;
    return DateTime(year, month, day, hour, minute);
  }

  factory TodoItem.fromSnapshot(DocumentSnapshot snapshot) {
    var timeFromSnapshot = snapshot['timeOfDueDay'];
    TimeOfDay? time;

    if (timeFromSnapshot is String) {
      time = TimeOfDay(
        hour: DateFormat('HH:mm').parse(timeFromSnapshot).hour,
        minute: DateFormat('HH:mm').parse(timeFromSnapshot).minute,
      );
    } else if (timeFromSnapshot != null) {
      time = TimeOfDay(
        hour: timeFromSnapshot.hour,
        minute: timeFromSnapshot.minute,
      );
    }

    var timeNotificationFromSnapshot = snapshot['timeNotification'];
    TimeOfDay? timeNotification;
    if (timeNotificationFromSnapshot is String) {
      timeNotification = TimeOfDay(
        hour: DateFormat('HH:mm').parse(timeNotificationFromSnapshot).hour,
        minute: DateFormat('HH:mm').parse(timeNotificationFromSnapshot).minute,
      );
    } else if (timeNotificationFromSnapshot != null) {
      timeNotification = TimeOfDay(
        hour: timeNotificationFromSnapshot.hour,
        minute: timeNotificationFromSnapshot.minute,
      );
    }

    return TodoItem(
      id: snapshot.id,
      notificationID: snapshot['notificationID'],
      content: snapshot['description'] ?? '',
      completed: snapshot['completed'] ?? false,
      date: snapshot['dueDate']?.toDate(),
      time: time,
      timeNotification: timeNotification,
      isNotification: snapshot['isNotification'],
    );
  }
}
