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
  String? content;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedTimeNotification = const TimeOfDay(hour: 0, minute: 0);
  bool isNotification = false;

  CreateTaskBloc() : super(CreateTaskInitial()) {
    on<CreateTaskButtonPressed>(_onCreateTaskButtonPressed);
  }

  void _onCreateTaskButtonPressed(
      CreateTaskButtonPressed event, Emitter<CreateTaskState> emit) async {
    emit(CreateTaskLoading());
    try {
      if (content == null) {
        emit(const CreateTaskFailure(error: 'Vui lòng nhập nội dung task!'));
      } else {
        lastNotificationID++;
        TodoItem newTodo = TodoItem(
          id: '1',
          notificationID: newNotificationID,
          content: content!,
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
          });
        }
        emit(CreateTaskSuccess());
      }
    } catch (error) {
      emit(CreateTaskFailure(error: "Lỗi: $error"));
    }
  }
}
