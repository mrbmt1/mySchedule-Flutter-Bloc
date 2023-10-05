import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myschedule/models/birthday_item.dart';

showBDNotificationDialog(
    BuildContext context, BirthDayItem birthdayTodo) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Thông báo'),
        content:
            const Text('Bạn muốn tắt thông báo hay đặt lại giờ thông báo?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Tắt thông báo'),
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('birthdays')
                  .doc(birthdayTodo.id)
                  .update({'isNotification': false});
              if (birthdayTodo.isNotification) {
                AwesomeNotifications().cancel(birthdayTodo.notificationID);
              }
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Đặt lại giờ thông báo'),
            onPressed: () async {
              var newTime = await showTimePicker(
                context: context,
                initialTime: birthdayTodo.timeNotification ?? TimeOfDay.now(),
              );
              if (newTime != null) {
                var notificationTime = birthdayTodo.getDateTime();
                notificationTime = DateTime(
                  notificationTime.year,
                  notificationTime.month,
                  notificationTime.day,
                  newTime.hour,
                  newTime.minute,
                );
                FirebaseFirestore.instance
                    .collection('birthdays')
                    .doc(birthdayTodo.id)
                    .update({
                  'timeNotification': newTime.format(context),
                  'isNotification': true,
                });
                if (birthdayTodo.isNotification) {
                  AwesomeNotifications().cancel(birthdayTodo.notificationID);
                }
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
