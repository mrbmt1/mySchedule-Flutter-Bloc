import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/views/widgets/birthday/add_birthay_button.dart';
import 'package:myschedule/views/widgets/birthday/birthday_list.dart';
import '../task/todotask.dart';

class BirthdayScreen extends StatelessWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

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
      body: buildBirhDayTaskList(currentUser),
      floatingActionButton: addBirthDayButton(context),
    );
  }
}
