import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/blocs/birthday_task/create_birthday/create_birthday_bloc.dart';
import 'package:myschedule/blocs/birthday_task/create_birthday/create_birthday_state.dart';
import 'package:myschedule/models/todo_item.dart';

import '../../../blocs/birthday_task/create_birthday/create_birthday_event.dart';
import 'birthdaylist.dart';

class CreateBirthDayTaskScreen extends StatefulWidget {
  const CreateBirthDayTaskScreen({Key? key}) : super(key: key);

  @override
  CreateBirthDayTaskScreenState createState() =>
      CreateBirthDayTaskScreenState();
}

class CreateBirthDayTaskScreenState extends State<CreateBirthDayTaskScreen> {
  static int _lastNotificationID = 0;
  int newNotificationID = ++_lastNotificationID;
  String? _content;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTimeNotification = const TimeOfDay(hour: 0, minute: 0);
  bool _isNotification = false;

  @override
  Widget build(BuildContext context) {
    final createBirthDayTaskBloc =
        BlocProvider.of<CreateBirthDayTaskBloc>(context);

    return BlocConsumer<CreateBirthDayTaskBloc, CreateBirthDayTaskState>(
        listener: (context, state) {
      if (state is CreateBirthDayTaskSuccess) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tạo task thành công!'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      } else if (state is CreateBirthDayTaskFailure) {
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
          title: const Text('Sinh nhật'),
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
                  hintText: 'Đó là sinh nhật của?',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.cake),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  createBirthDayTaskBloc
                      .add(SelectDateEvent(_selectedDate, context));
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
                onPressed: () async {
                  createBirthDayTaskBloc.add(SelectTimeNotificationEvent(
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
            if (_content == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vui lòng cho biết sinh nhật của ai'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              _lastNotificationID++;
              TodoItem newTodo = TodoItem(
                id: '1',
                notificationID: newNotificationID,
                content: _content!,
              );
              newTodo.date = _selectedDate;
              newTodo.timeNotification = _selectedTimeNotification;
              newTodo.isNotification = _isNotification;
              User? currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                await FirebaseFirestore.instance.collection('birthdays').add({
                  'userID': currentUser.uid,
                  'createdAt': DateTime.now(),
                  'birthDay': newTodo.date,
                  'description': newTodo.content,
                  'isNotification': newTodo.isNotification,
                  'timeNotification':
                      "${newTodo.timeNotification!.hour}:${newTodo.timeNotification!.minute}",
                  'notificationID': _lastNotificationID,
                });
              }
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const BirthdayScreen()),
                (route) => false,
              );
            }
          },
        ),
      );
    });
  }
}
