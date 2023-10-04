import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/blocs/task/edit_task/edit_task_bloc.dart';
import 'package:myschedule/blocs/task/edit_task/edit_task_event.dart';
import 'package:myschedule/blocs/task/edit_task/edit_task_state.dart';
import 'package:myschedule/models/todo_item.dart';

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
    final editTaskBloc = BlocProvider.of<EditTaskBloc>(context);

    return BlocListener<EditTaskBloc, EditTaskState>(
      listener: (context, state) {
        if (state is EditTaskSuccess) {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Tạo task thành công!'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green),
          );
        } else if (state is EditTaskFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
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
                  _content = value;
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
            editTaskBloc.add(EditTaskButtonPressed(
              id: widget.todo.id,
              content: _content,
              selectedDate: _selectedDate,
              selectedTime: _selectedTime,
              selectedTimeNotification: _selectedTimeNotification,
              isNotification: _isNotification,
            ));
          },
        ),
      ),
    );
  }
}
