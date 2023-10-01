import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myschedule/models/todo_item.dart';
import 'package:myschedule/views/screens/task/create_task.dart';

Widget addTask(BuildContext context) {
  return FloatingActionButton(
    child: const Icon(Icons.note_add_rounded),
    onPressed: () async {
      TodoItem? newTodo = await Navigator.push<TodoItem?>(
        context,
        MaterialPageRoute(builder: (context) => const CreateTaskScreen()),
      );
      if (newTodo != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Đã thêm task mới'), backgroundColor: Colors.green),
        );
      }
    },
  );
}
