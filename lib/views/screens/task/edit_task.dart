import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/views/screens/task/todotask.dart';

class EditTaskScreen extends StatefulWidget {
  final TodoItem todo;

  const EditTaskScreen({Key? key, required this.todo}) : super(key: key);

  @override
  EditTaskScreenState createState() => EditTaskScreenState();
}

class EditTaskScreenState extends State<EditTaskScreen> {
  late String _content;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _contentController;
  late TimeOfDay _selectedTimeNotification;
  late bool _isNotification = false;
  late int newNotificationID;

  @override
  void initState() {
    super.initState();
    newNotificationID = widget.todo.notificationID;
    _content = widget.todo.content;
    _selectedDate = widget.todo.date!;
    _selectedTime = widget.todo.time!;
    _contentController = TextEditingController(text: _content);
    _selectedTimeNotification = widget.todo.timeNotification!;
    _isNotification = widget.todo.isNotification;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
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
      initialTime: _selectedTime,
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
      initialTime: _selectedTimeNotification,
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
        title: const Text('Chỉnh sửa task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              controller: _contentController,
            ),
            const SizedBox(height: 8),
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
          if (_content.isEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Chưa nhập nội dung"),
                  content: const Text("Vui lòng nhập nội dung trước khi lưu"),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Đóng"),
                    ),
                  ],
                );
              },
            );
          } else {
            User? currentUser = FirebaseAuth.instance.currentUser;
            if (currentUser != null) {
              await FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(widget.todo.id)
                  .update({
                'description': _content,
                'dueDate': _selectedDate,
                'updatedAt': DateTime.now(),
                'timeOfDueDay': _selectedTime.format(context),
                'isNotification': _isNotification,
                'timeNotification': _selectedTimeNotification.format(context),
              });
            }
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Cập nhật task thành công!'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green),
            );
          }
        },
      ),
    );
  }
}
