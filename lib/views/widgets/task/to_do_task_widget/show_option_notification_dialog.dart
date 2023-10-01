import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myschedule/models/todo_item.dart';

showNotificationDialog(BuildContext context, TodoItem todo) async {
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
                  .collection('tasks')
                  .doc(todo.id)
                  .update({'isNotification': false});
              if (todo.isNotification) {
                AwesomeNotifications().cancel(todo.notificationID);
              }
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Đặt lại giờ thông báo'),
            onPressed: () async {
              var newTime = await showTimePicker(
                context: context,
                initialTime: todo.timeNotification ?? TimeOfDay.now(),
              );
              if (newTime != null) {
                var notificationTime = todo.getDateTime();
                notificationTime = DateTime(
                  notificationTime.year,
                  notificationTime.month,
                  notificationTime.day,
                  newTime.hour,
                  newTime.minute,
                );
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(todo.id)
                    .update({
                  'timeNotification': newTime.format(context),
                  'isNotification': true,
                });
                if (todo.isNotification) {
                  AwesomeNotifications().cancel(todo.notificationID);
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
