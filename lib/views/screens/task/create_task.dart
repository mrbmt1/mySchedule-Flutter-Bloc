import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/blocs/task/create_task/create_task_bloc.dart';
import 'package:myschedule/blocs/task/create_task/create_task_event.dart';
import 'package:myschedule/blocs/task/create_task/create_task_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final createTaskBloc = BlocProvider.of<CreateTaskBloc>(context);

    return BlocConsumer<CreateTaskBloc, CreateTaskState>(
      listener: (context, state) {
        if (state is CreateTaskSuccess) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tạo task thành công!'),
              duration: Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is CreateTaskFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is DateSelectedState) {
          _selectedDate = state.selectedDate;
        } else if (state is TimeSelectedState) {
          _selectedTime = state.selectedTime;
        } else if (state is TimeNotificationSelectedState) {
          _selectedTimeNotification = state.selectedTimeNotification;
          _isNotification = true;
        }
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
                    _content = value;
                  },
                  decoration: const InputDecoration(
                    hintText: 'Nhập nội dung task',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.edit_document),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    createTaskBloc.add(SelectDateEvent(_selectedDate, context));
                  },
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
                  onPressed: () async {
                    createTaskBloc.add(SelectTimeEvent(_selectedTime, context));
                  },
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
                  onPressed: () async {
                    createTaskBloc.add(SelectTimeNotificationEvent(
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
              createTaskBloc.add(CreateTaskButtonPressed(
                content: _content ?? "",
                selectedDate: _selectedDate,
                selectedTime: _selectedTime,
                selectedTimeNotification: _selectedTimeNotification,
                isNotification: _isNotification,
              ));
            },
          ),
        );
      },
    );
  }
}
