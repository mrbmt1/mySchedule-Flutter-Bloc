import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/models/todo_item.dart';
import 'package:myschedule/utils/task/to_do_task_utils/notification.dart';
import 'package:myschedule/views/widgets/task/to_do_task_widget/section.dart';
import 'package:timezone/timezone.dart' as tz;

Widget buildTaskList(User? currentUser) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('tasks')
        .where('userID', isEqualTo: currentUser?.uid)
        .orderBy('timeOfDueDay')
        .orderBy('dueDate')
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.hasError) {
        return Center(
          child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
        );
      }

      if (!snapshot.hasData) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      List<TodoItem> todoList =
          snapshot.data!.docs.map((doc) => TodoItem.fromSnapshot(doc)).toList();
//sắp xếp các task theo sections
      final now = DateTime.now();
      List<TodoItem> beforeList = [];
      List<TodoItem> todayList = [];
      List<TodoItem> afterList = [];

      for (var item in todoList) {
        DateTime itemDate =
            DateTime(item.date!.year, item.date!.month, item.date!.day);
        DateTime nowDate = DateTime(now.year, now.month, now.day);

        if (itemDate.isBefore(nowDate)) {
          beforeList.add(item);
        } else if (itemDate.isAtSameMomentAs(nowDate)) {
          todayList.add(item);
        } else {
          afterList.add(item);
        }

//thông báo của từng task nếu isNotification = true

        if (item.isNotification) {
          final notificationTime = tz.TZDateTime(
            tz.local,
            item.date!.year,
            item.date!.month,
            item.date!.day,
            item.timeNotification!.hour,
            item.timeNotification!.minute,
          );
          final notificationId = item.notificationID;
          final time = DateTime(
            item.date!.year,
            item.date!.month,
            item.date!.day,
            item.time!.hour,
            item.time!.minute,
          );
          final timeFormat = DateFormat.Hm();
          final dateFormat = DateFormat('dd/MM/yyyy');
          notificationConfig(
            'Bạn có lịch: ${item.content}',
            'Hạn chót lúc: ${timeFormat.format(time)} ${dateFormat.format(item.date!)}',
            notificationTime,
            notificationId,
          );
        }
      }

// Sắp xếp danh sách theo ngày hạn
      beforeList.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
      todayList.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
      afterList.sort((a, b) => a.getDateTime().compareTo(b.getDateTime()));
      // Kiểm tra xem phần đang hiển thị có phải là phần trống hay không
      Widget? emptyListWidget;
      if (todoList.isEmpty) {
        emptyListWidget = const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text('Không có công việc nào trong danh sách'),
          ),
        );
      }

// Các sections
      return ListView(
        children: [
          if (beforeList.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: buildSection(context, 'Những ngày trước', beforeList),
            ),
          if (todayList.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: buildSection(context, 'Hôm nay', todayList),
            ),
          if (afterList.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Bo tròn cạnh của Card
              ),
              child: buildSection(context, 'Những ngày sau', afterList),
            ),
          if (emptyListWidget != null) emptyListWidget,
        ],
      );
    },
  );
}
