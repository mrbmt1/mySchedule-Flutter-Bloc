import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myschedule/models/birthday_item.dart';
import 'package:myschedule/views/screens/birthday_task/create_birthday_taks.dart';

Widget addBirthDayButton(BuildContext context) {
  return FloatingActionButton(
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
            content: Text('Đã thêm sinh nhật mới'),
            backgroundColor: Colors.green,
          ),
        );
      }
    },
  );
}
