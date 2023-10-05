import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/models/birthday_item.dart';
import 'package:myschedule/utils/birthday/birthday_list/dialog_notification_widget.dart';
import 'edit_birthday_task.dart';

class BirthDayWidget extends StatelessWidget {
  final BirthDayItem birthdayTodo;

  const BirthDayWidget({Key? key, required this.birthdayTodo})
      : super(key: key);

  String getRemainingTime() {
    DateTime now = DateTime.now();
    DateTime birthday = DateTime(birthdayTodo.date!.year,
        birthdayTodo.date!.month, birthdayTodo.date!.day);

    if (now.day == birthday.day && now.month == birthday.month) {
      // ngày tháng hiện tại trùng với ngày sinh nhật
      return 'Hôm nay là sinh nhật!';
    } else {
      DateTime nextBirthday = DateTime(now.year, birthday.month, birthday.day);
      if (now.isAfter(nextBirthday)) {
        // sinh nhật đã qua, tính số ngày đến sinh nhật trong năm sau
        nextBirthday = DateTime(now.year + 1, birthday.month, birthday.day);
      }
      Duration remainingDuration = nextBirthday.difference(now);
      int days = remainingDuration.inDays;
      int hours = remainingDuration.inHours.remainder(24);
      int minutes = remainingDuration.inMinutes.remainder(60);
      return 'Còn lại: $days ngày $hours giờ $minutes phút';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10, // Độ nâng của Card
      // color: Color.fromARGB(255, 253, 227, 245), //
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Bo tròn cạnh của Card
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 15,
            bottom: 22,
            right: 25,
            left: 50), //4 phía của card với content
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () =>
                        showBDNotificationDialog(context, birthdayTodo),
                    child: Row(
                      children: [
                        if (birthdayTodo.isNotification)
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
                                  '${birthdayTodo.timeNotification != null ? DateFormat('HH:mm').format(DateTime(2000, 1, 1, birthdayTodo.timeNotification!.hour, birthdayTodo.timeNotification!.minute)) : ""}',
                                ), // Hiển thị giá trị của timeNotification
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    birthdayTodo.content,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  if (birthdayTodo.date != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Sinh nhật: ',
                            style: TextStyle(
                                // color: Color.fromARGB(255, 255, 15, 155),
                                ),
                          ),
                          TextSpan(
                            text: DateFormat('dd/MM/yyyy')
                                .format(birthdayTodo.date!),
                          ),
                        ],
                      ),
                    ),
                  Text(
                    '${getRemainingTime()}',
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 0, 170),
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
                    builder: (_) =>
                        EditBirthDayTaskScreen(birthdayTodo: birthdayTodo),
                  ),
                );
              },
              icon: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 5, 154, 241),
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
                                .collection('birthdays')
                                .doc(birthdayTodo.id)
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
