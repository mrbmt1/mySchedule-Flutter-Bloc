import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/views/screens/task/todotask.dart';
import 'edit_task.dart';

class TaskWidget extends StatelessWidget {
  final TodoItem todo;

  const TaskWidget({Key? key, required this.todo}) : super(key: key);

  String getRemainingTime() {
    DateTime now = DateTime.now();
    DateTime deadline = DateTime(todo.date!.year, todo.date!.month,
        todo.date!.day, todo.time!.hour, todo.time!.minute);
    Duration remainingDuration = deadline.difference(now);

    if (remainingDuration.inSeconds < 0) {
      return 'Đã hết hạn';
    } else if (remainingDuration.inDays > 0) {
      return '${remainingDuration.inDays} ngày ${remainingDuration.inHours.remainder(24)} giờ';
    } else {
      return '${remainingDuration.inHours.remainder(24)} giờ ${remainingDuration.inMinutes.remainder(60)} phút';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10, // Độ nâng của Card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Bo tròn cạnh của Card
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 15,
            bottom: 20,
            right: 20,
            left: 20), //4 phía của card với content
        child: Row(
          children: [
            Checkbox(
              value: todo.completed,
              shape: const CircleBorder(),
              checkColor: Colors.white,
              activeColor: Colors.green,
              onChanged: (bool? value) async {
                if (value != null) {
                  bool isCompleted = value;
                  bool isNotification = !isCompleted;
                  await FirebaseFirestore.instance
                      .collection('tasks')
                      .doc(todo.id)
                      .update({
                    'completed': isCompleted,
                    'isNotification': isNotification,
                  });
                  AwesomeNotifications().cancel(todo.notificationID);
                }
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => showNotificationDialog(context, todo),
                    child: Row(
                      children: [
                        if (todo.isNotification)
                          Padding(
                            padding: const EdgeInsets.only(top: 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Icon(Icons.notifications_active,
                                    color: Colors.orange,
                                    size: 20), // Kích thước icon là 20
                                const SizedBox(
                                  width:
                                      7, // Khoảng cách giữa icon và text thời gian thông báo
                                ),
                                Text(
                                  todo.timeNotification != null
                                      ? DateFormat('HH:mm').format(DateTime(
                                          2000,
                                          1,
                                          1,
                                          todo.timeNotification!.hour,
                                          todo.timeNotification!.minute))
                                      : "",
                                ), // Hiển thị giá trị của timeNotification
                              ],
                            ),
                          ),
                        if (todo.date != null &&
                            !todo.completed &&
                            DateTime.now().isAfter(DateTime(
                                todo.date!.year,
                                todo.date!.month,
                                todo.date!.day,
                                todo.time!.hour,
                                todo.time!.minute)))
                          const Padding(
                            padding: EdgeInsets.only(left: 7),
                            child: Text(
                              'Quá hạn',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 204, 123, 1)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    todo.content,
                    style: TextStyle(
                        decoration:
                            todo.completed ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                  if (todo.date != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hạn chót: ',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 221, 6, 6),
                              decoration: todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (todo.time != null)
                            TextSpan(
                              text: DateFormat('HH:mm - ').format(DateTime(2000,
                                  1, 1, todo.time!.hour, todo.time!.minute)),
                            ),
                          TextSpan(
                            text: DateFormat('dd/MM/yyyy').format(todo.date!),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        decoration:
                            todo.completed ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  Text(
                    'Còn lại:  ${getRemainingTime()}',
                    style: TextStyle(
                      decoration:
                          todo.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditTaskScreen(todo: todo),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 16, 44, 206),
              ),
            ),
            IconButton(
              onPressed: () async {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content:
                          const Text('Bạn có chắc muốn xóa task này không?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () async {
                            await FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(todo.id)
                                .delete();
                            Navigator.pop(context);
                          },
                          child: const Text('Xác nhận'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Hủy bỏ'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromARGB(255, 255, 27, 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
