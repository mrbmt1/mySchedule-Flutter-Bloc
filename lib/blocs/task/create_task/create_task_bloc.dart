import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myschedule/blocs/task/create_task/create_task_event.dart';
import 'package:myschedule/blocs/task/create_task/create_task_state.dart';
import 'package:myschedule/models/todo_item.dart';

class CreateTaskBloc extends Bloc<CreateTaskEvent, CreateTaskState> {
  static int lastNotificationID = 0;
  int newNotificationID = ++lastNotificationID;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedTimeNotification = const TimeOfDay(hour: 0, minute: 0);
  bool isNotification = false;

  CreateTaskBloc() : super(const CreateTaskInitial()) {
    on<CreateTaskButtonPressed>(_onCreateTaskButtonPressed);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectTimeEvent>(_onSelectTime);
    on<SelectTimeNotificationEvent>(_onSelectTimeNotification);
  }

  void _onSelectDate(
      SelectDateEvent event, Emitter<CreateTaskState> emit) async {
    emit(const CreateTaskInitial());
    final DateTime? selectedDate = await showDatePicker(
      context: event.context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      emit(DateSelectedState(selectedDate));
    }
    print("$selectedDate");
  }

  void _onSelectTime(
      SelectTimeEvent event, Emitter<CreateTaskState> emit) async {
    emit(const CreateTaskInitial());
    final TimeOfDay? selectedTime = await showTimePicker(
        context: event.context, initialTime: TimeOfDay.now());
    if (selectedTime != null) {
      emit(TimeSelectedState(selectedTime));
    }
    print("$selectedTime");
  }

  void _onSelectTimeNotification(
      SelectTimeNotificationEvent event, Emitter<CreateTaskState> emit) async {
    emit(const CreateTaskInitial());

    final TimeOfDay? selectedTimeNotification = await showTimePicker(
      context: event.context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );
    if (selectedTimeNotification != null) {
      emit(TimeNotificationSelectedState(selectedTimeNotification));
    }
    print("$selectedTimeNotification");
  }

  void _onCreateTaskButtonPressed(
      CreateTaskButtonPressed event, Emitter<CreateTaskState> emit) async {
    emit(const CreateTaskLoading());
    try {
      if (event.content.isEmpty) {
        emit(const CreateTaskFailure(error: 'Vui lòng nhập nội dung task!'));
      } else {
        lastNotificationID++;
        TodoItem newTodo = TodoItem(
          id: '1',
          notificationID: newNotificationID,
          content: event.content!,
        );
        newTodo.date = selectedDate;
        newTodo.time = selectedTime;
        newTodo.timeNotification = selectedTimeNotification;
        newTodo.isNotification = isNotification;
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance.collection('tasks').add({
            'userID': currentUser.uid,
            'completed': false,
            'createdAt': DateTime.now(),
            'dueDate': event.selectedDate,
            'description': event.content,
            'timeOfDueDay':
                "${event.selectedTime.hour}:${event.selectedTime.minute}",
            'isNotification': event.isNotification,
            'timeNotification':
                "${event.selectedTimeNotification.hour}:${event.selectedTimeNotification.minute}",
            'notificationID': lastNotificationID,
          });
        }
        emit(const CreateTaskSuccess());
      }
    } catch (error) {
      emit(CreateTaskFailure(error: "Lỗi: $error"));
    }
  }
}
