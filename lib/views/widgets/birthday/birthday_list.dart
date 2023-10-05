import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/models/birthday_item.dart';
import 'package:myschedule/utils/task/to_do_task_utils/notification.dart';
import 'package:myschedule/views/widgets/birthday/birthday_section_widget.dart';
import 'package:timezone/timezone.dart' as tz;

Widget buildBirhDayTaskList(User? currentUser) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('birthdays')
        .where('userID', isEqualTo: currentUser?.uid)
        .orderBy('birthDay')
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

      List<BirthDayItem> birthdayList = snapshot.data!.docs
          .map((doc) => BirthDayItem.fromSnapshot(doc))
          .toList();

      List<List<BirthDayItem>> birthDayItemsByMonth =
          List.generate(12, (index) => []);

      for (var item in birthdayList) {
        DateTime itemDate =
            DateTime(item.date!.year, item.date!.month, item.date!.day);

        if (item.isNotification) {
          final now = DateTime.now();
          final notificationTime = tz.TZDateTime(
            tz.local,
            now.year,
            item.date!.month,
            item.date!.day,
            item.timeNotification!.hour,
            item.timeNotification!.minute,
          );
          final notificationId = item.notificationID;

          final dateFormat = DateFormat('dd/MM/yyyy');
          notificationConfig(
            'Hôm nay là sinh nhật của ${item.content}',
            'Sinh nhật ngày: ${dateFormat.format(item.date!)}',
            notificationTime,
            notificationId,
          );
        }
        if (itemDate.month <= 12 && itemDate.month >= 1) {
          birthDayItemsByMonth[itemDate.month - 1].add(item);
        }
      }
      Widget? emptyListWidget;
      if (birthdayList.isEmpty) {
        emptyListWidget = const Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Text('Không có sinh nhật nào trong danh sách'),
          ),
        );
      }
      return ListView(
        children: [
          for (int i = 0; i < 12; i++)
            if (birthDayItemsByMonth[i].isNotEmpty)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: buildBirthDaySection(
                    context, 'Tháng ${i + 1}', birthDayItemsByMonth[i]),
              ),
          if (emptyListWidget != null) emptyListWidget,
        ],
      );
    },
  );
}
