import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BirthDayItem {
  final String id;
  final String content;
  DateTime? date;
  String? description;
  TimeOfDay? timeNotification;
  bool isNotification;
  int notificationID;

  BirthDayItem({
    required this.id,
    required this.content,
    this.description,
    required this.notificationID,
    this.date,
    this.timeNotification,
    this.isNotification = false,
  });

  DateTime getDateTime() {
    final now = DateTime.now();
    final year = date?.year ?? now.year;
    final month = date?.month ?? now.month;
    final day = date?.day ?? now.day;
    return DateTime(year, month, day);
  }

  factory BirthDayItem.fromSnapshot(DocumentSnapshot snapshot) {
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

    return BirthDayItem(
      id: snapshot.id,
      notificationID: snapshot['notificationID'],
      content: snapshot['description'] ?? '',
      date: snapshot['birthDay']?.toDate(),
      timeNotification: timeNotification,
      isNotification: snapshot['isNotification'],
    );
  }
}
