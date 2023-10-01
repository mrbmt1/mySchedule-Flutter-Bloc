import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/views/screens/task/search_task.dart';
import 'package:myschedule/views/widgets/task/to_do_task_widget/create_task_button.dart';
import 'package:myschedule/views/widgets/task/to_do_task_widget/task_list_widget.dart';
import 'package:myschedule/views/widgets/task/to_do_task_widget/drawer_widget.dart';

class TodoListScreen extends StatelessWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  static void pushAndRemoveUntil(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const TodoListScreen()),
      (route) => false,
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
      drawer: todoTaskDrawer(context),
      body: buildTaskList(currentUser),
      floatingActionButton: addTask(context),
    );
  }
}
