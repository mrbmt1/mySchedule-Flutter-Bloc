import 'package:flutter/material.dart';

class NotificationHelper {
  static Future<TimeOfDay?> selectTimeNotification(
      BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }
}
