import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/blocs/birthday_task/edit_birthday/edit_birthday_bloc.dart';
import 'package:myschedule/blocs/birthday_task/edit_birthday/edit_birthday_event.dart';
import 'package:myschedule/blocs/birthday_task/edit_birthday/edit_birthday_state.dart';
import 'package:myschedule/models/birthday_item.dart';

class EditBirthDayTaskScreen extends StatefulWidget {
  final BirthDayItem birthdayTodo;

  const EditBirthDayTaskScreen({required this.birthdayTodo});

  @override
  EditBirthDayTaskScreenState createState() => EditBirthDayTaskScreenState();
}

class EditBirthDayTaskScreenState extends State<EditBirthDayTaskScreen> {
  late String _content;
  late DateTime _selectedDate;
  late TextEditingController _contentController;
  late TimeOfDay _selectedTimeNotification;
  late bool _isNotification = false;
  late int newNotificationID;

  @override
  void initState() {
    super.initState();
    newNotificationID = widget.birthdayTodo.notificationID;
    _content = widget.birthdayTodo.content;
    _selectedDate = widget.birthdayTodo.date!;
    _contentController = TextEditingController(text: _content);
    _selectedTimeNotification = widget.birthdayTodo.timeNotification!;
    _isNotification = widget.birthdayTodo.isNotification;
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editTaskBloc = BlocProvider.of<EditBirthDayTaskBloc>(context);

    return BlocConsumer<EditBirthDayTaskBloc, EditBirthDayTaskState>(
        listener: (context, state) {
      if (state is EditBirthDayTaskSuccess) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tạo sinh nhật thành công!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state is EditBirthDayTaskFailure) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error),
            backgroundColor: Colors.red,
          ),
        );
      }
    }, builder: (context, state) {
      if (state is DateSelectedState) {
        _selectedDate = state.selectedDate;
      } else if (state is TimeNotificationSelectedState) {
        _selectedTimeNotification = state.selectedTimeNotification;
        _isNotification = true;
      }
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chỉnh sửa ngày sinh nhật'),
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
                  hintText: 'Nhập nội dung ngày sinh nhật',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.cake_rounded),
                ),
                controller: _contentController,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  editTaskBloc.add(SelectDateEvent(_selectedDate, context));
                },
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                        'Sinh nhật: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}'),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              TextButton(
                onPressed: () {
                  editTaskBloc.add(SelectTimeNotificationEvent(
                      _selectedTimeNotification, context));
                },
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
                    .collection('birthdays')
                    .doc(widget.birthdayTodo.id)
                    .update({
                  'description': _content,
                  'updatedAt': DateTime.now(),
                  'birthDay': _selectedDate,
                  'isNotification': _isNotification,
                  'timeNotification': _selectedTimeNotification.format(context),
                });
              }
              Navigator.pop(context);
            }
          },
        ),
      );
    });
  }
}
