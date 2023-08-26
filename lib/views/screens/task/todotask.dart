import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/views/screens/profile/profile.dart';
import 'package:myschedule/views/screens/task/search_task.dart';
import '../setting/setting/setting.dart';
import '../birthday_task/birthdaylist.dart';
import '../login/login.dart';
import '../school_schedule/school_schedule_navigator .dart';
import 'create_task.dart';
import 'task_widget.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

//log out function
void logout(BuildContext context) async {
  bool confirm = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Đăng xuất"),
      content: const Text("Bạn muốn đăng xuất khỏi tài khoản?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Không"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Có"),
        ),
      ],
    ),
  );
  if (confirm == true) {
    // Đăng xuất khỏi Firebase Authentication
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }
}

//Hàm hiển thị thông báo khi bấm vào icon chuông thông báo
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
      time: time, // assign parsed time directly to the time field
      timeNotification: timeNotification,
      isNotification: snapshot['isNotification'],
    );
  }
}

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  static void pushAndRemoveUntil(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TodoListScreen()),
      (route) => false,
    );
  }

  void _showNotification(
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
        child: Text('Vui lòng đăng nhập để xem danh sách task'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách lịch của tôi'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SearchScreen()),
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(),
              child: Text('Menu'),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Thông tin người dùng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.list_alt),
              title: const Text('Thời khóa biểu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SchoolScheduleNavigator()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cake),
              title: const Text('Sinh nhật'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BirthdayScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Cài đặt'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('userID', isEqualTo: currentUser.uid)
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

          List<TodoItem> todoList = snapshot.data!.docs
              .map((doc) => TodoItem.fromSnapshot(doc))
              .toList();
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
              _showNotification(
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
                  child: _buildSection(context, 'Những ngày trước', beforeList),
                ),
              if (todayList.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _buildSection(context, 'Hôm nay', todayList),
                ),
              if (afterList.isNotEmpty)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Bo tròn cạnh của Card
                  ),
                  child: _buildSection(context, 'Những ngày sau', afterList),
                ),
              if (emptyListWidget != null) emptyListWidget,
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.note_add_rounded),
        onPressed: () async {
          TodoItem? newTodo = await Navigator.push<TodoItem?>(
            context,
            MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
          );
          if (newTodo != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Đã thêm task mới'),
                  backgroundColor: Colors.green),
            );
          }
        },
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<TodoItem> todoList) {
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
          itemCount: todoList.length,
          itemBuilder: (context, index) {
            TodoItem todoItem = todoList[index];
            return TaskWidget(todo: todoItem);
          },
        ),
      ],
    );
  }
}
