import 'package:flutter/material.dart';
import 'package:myschedule/models/todo_item.dart';
import 'package:myschedule/views/widgets/task/to_do_task_widget/task_widget.dart';

Widget buildSection(
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
