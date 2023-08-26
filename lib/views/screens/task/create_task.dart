import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/views/screens/task/todotask.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({Key? key}) : super(key: key);

  @override
  CreateTaskScreenState createState() => CreateTaskScreenState();
}

class CreateTaskScreenState extends State<CreateTaskScreen> {
  static int _lastNotificationID = 0;
  int newNotificationID = ++_lastNotificationID;
  String? _content;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _selectedTimeNotification = const TimeOfDay(hour: 0, minute: 0);
  bool _isNotification = false;

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        _selectedTime = selectedTime;
      });
    }
  }

  Future<void> _selectTimeNotification() async {
    final TimeOfDay? selectedTimeNotification = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );
    if (selectedTimeNotification != null) {
      setState(() {
        _selectedTimeNotification = selectedTimeNotification;
        _isNotification = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo task mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  _content = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Nhập nội dung task',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.edit_document),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: _selectDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(
                      'Ngày đến hạn: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                ],
              ),
            ),
            const SizedBox(height: 0),
            TextButton(
              onPressed: _selectTime,
              child: Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 8),
                  Text('Giờ đến hạn: ${_selectedTime.format(context)}'),
                ],
              ),
            ),
            const SizedBox(height: 0),
            TextButton(
              onPressed: _selectTimeNotification,
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_outlined),
                  const SizedBox(width: 8),
                  Text(_isNotification
                      ? 'Bật thông báo: ${_selectedTimeNotification.format(context)}'
                      : 'Bật thông báo: Không'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          if (_content == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Vui lòng nhập nội dung task!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red),
            );
          } else {
            _lastNotificationID++;
            TodoItem newTodo = TodoItem(
              id: '1',
              notificationID: newNotificationID,
              content: _content!,
            );
            newTodo.date = _selectedDate;
            newTodo.time = _selectedTime;
            newTodo.timeNotification = _selectedTimeNotification;
            newTodo.isNotification = _isNotification;
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await FirebaseFirestore.instance.collection('tasks').add({
                'userID': currentUser.uid,
                'completed': false,
                'createdAt': DateTime.now(),
                'dueDate': newTodo.date,
                'description': newTodo.content,
                'timeOfDueDay': "${newTodo.time!.hour}:${newTodo.time!.minute}",
                'isNotification': newTodo.isNotification,
                'timeNotification':
                    "${newTodo.timeNotification!.hour}:${newTodo.timeNotification!.minute}",
                'notificationID': _lastNotificationID,
              });
            }
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const TodoListScreen()),
              (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Tạo task thành công!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green),
            );
          }
        },
      ),
    );
  }
}
