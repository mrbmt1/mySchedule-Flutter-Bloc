import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myschedule/blocs/birthday_task/create_birthday/create_birthday_event.dart';
import 'package:myschedule/blocs/birthday_task/create_birthday/create_birthday_state.dart';
import 'package:myschedule/models/todo_item.dart';

class CreateBirthDayTaskBloc
    extends Bloc<CreateBirthDayTaskEvent, CreateBirthDayTaskState> {
  static int lastNotificationID = 0;
  int newNotificationID = ++lastNotificationID;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedTimeNotification = const TimeOfDay(hour: 0, minute: 0);
  bool isNotification = false;

  CreateBirthDayTaskBloc() : super(const CreateBirthDayTaskInitial()) {
    on<CreateBirthDayTaskButtonPressed>(_onCreateBirthDayTaskButtonPressed);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectTimeNotificationEvent>(_onSelectTimeNotification);
  }

  void _onSelectDate(
      SelectDateEvent event, Emitter<CreateBirthDayTaskState> emit) async {
    emit(const CreateBirthDayTaskInitial());
    final DateTime? selectedDate = await showDatePicker(
      context: event.context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      emit(DateSelectedState(selectedDate));
    }
    print("$selectedDate");
  }

  void _onSelectTimeNotification(SelectTimeNotificationEvent event,
      Emitter<CreateBirthDayTaskState> emit) async {
    emit(const CreateBirthDayTaskInitial());

    final TimeOfDay? selectedTimeNotification = await showTimePicker(
      context: event.context,
      initialTime: const TimeOfDay(hour: 0, minute: 0),
    );
    if (selectedTimeNotification != null) {
      emit(TimeNotificationSelectedState(selectedTimeNotification));
    }
    print("$selectedTimeNotification");
  }

  void _onCreateBirthDayTaskButtonPressed(CreateBirthDayTaskButtonPressed event,
      Emitter<CreateBirthDayTaskState> emit) async {
    emit(const CreateBirthDayTaskLoading());
    try {
      if (event.content.isEmpty) {
        emit(const CreateBirthDayTaskFailure(
            error: 'Vui lòng cho biết sinh nhật của ai'));
      } else {
        lastNotificationID++;
        TodoItem newTodo = TodoItem(
          id: '1',
          notificationID: newNotificationID,
          content: event.content,
        );
        newTodo.date = selectedDate;
        newTodo.timeNotification = selectedTimeNotification;
        newTodo.isNotification = isNotification;
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance.collection('birthdays').add({
            'userID': currentUser.uid,
            'createdAt': DateTime.now(),
            'birthDay': event.selectedDate,
            'description': event.content,
            'isNotification': event.isNotification,
            'timeNotification':
                "${event.selectedTimeNotification.hour}:${event.selectedTimeNotification.minute}",
            'notificationID': lastNotificationID,
          });
        }
        emit(const CreateBirthDayTaskSuccess());
      }
    } catch (error) {
      emit(CreateBirthDayTaskFailure(error: "Lỗi: $error"));
    }
  }
}
