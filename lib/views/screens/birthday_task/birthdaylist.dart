import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../task/todotask.dart';
import 'birthday_widget.dart';
import 'create_birthday_taks.dart';

//Hàm hiển thị thông báo khi bấm vào icon chuông thông báo
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
  }) : assert(id != null);

  DateTime getDateTime() {
    final now = DateTime.now();
    final year = date?.year ?? now.year;
    final month = date?.month ?? now.month;
    final day = date?.day ?? now.day;
    return DateTime(year, month, day);
  }

  factory BirthDayItem.fromSnapshot(DocumentSnapshot snapshot) {
    // var timeFromSnapshot = snapshot['birthDay'];
    // TimeOfDay? time;

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

class BirthdayScreen extends StatelessWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

  static void pushAndRemoveUntil(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BirthdayScreen()),
      (route) => false,
    );
  }

  void _showBirthDayNotification(
    String title,
    String message,
    DateTime notificationTime,
    int notificationId,
  ) async {
    // final timeFormat = DateFormat.Hm();
    // final dateFormat = DateFormat('dd/MM/yyyy');

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

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text('Vui lòng đăng nhập để xem danh sách sinh nhật'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sinh nhật'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TodoListScreen()),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('birthdays')
            .where('userID', isEqualTo: currentUser.uid)
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

          // final now = DateTime.now();
          List<List<BirthDayItem>> birthDayItemsByMonth =
              List.generate(12, (index) => []);

          for (var item in birthdayList) {
            DateTime itemDate =
                DateTime(item.date!.year, item.date!.month, item.date!.day);
            // DateTime nowDate = DateTime(now.year, now.month, now.day);

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
              // final time = DateTime(
              //   item.date!.year,
              //   item.date!.month,
              //   item.date!.day,
              // );
              // final timeFormat = DateFormat.Hm();
              final dateFormat = DateFormat('dd/MM/yyyy');
              _showBirthDayNotification(
                'Hôm nay có ${item.content}',
                'Sinh nhật ngày: ${dateFormat.format(item.date!)}',
                notificationTime,
                notificationId,
              );
            }
            if (itemDate.month <= 12 && itemDate.month >= 1) {
              birthDayItemsByMonth[itemDate.month - 1].add(item);
            }

            // List<BirthDayItem> birthdayList = snapshot.data!.docs
            //     .map((doc) => BirthDayItem.fromSnapshot(doc))
            //     .toList();
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
                    child: _buildBirthDaySection(
                        context, 'Tháng ${i + 1}', birthDayItemsByMonth[i]),
                  ),
              if (emptyListWidget != null) emptyListWidget,
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.cake),
        onPressed: () async {
          BirthDayItem? newTodo = await Navigator.push<BirthDayItem?>(
            context,
            MaterialPageRoute(
                builder: (context) => const CreateBirthDayTaskScreen()),
          );
          if (newTodo != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã thêm task mới'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildBirthDaySection(
      BuildContext context, String title, List<BirthDayItem> birthdayList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(13.0),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: birthdayList.length,
          itemBuilder: (context, index) {
            BirthDayItem birthayItem = birthdayList[index];
            return BirthDayWidget(birthdayTodo: birthayItem);
          },
        ),
      ],
    );
  }
}
