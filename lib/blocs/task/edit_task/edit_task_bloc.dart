import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myschedule/blocs/task/edit_task/edit_task_event.dart';
import 'package:myschedule/blocs/task/edit_task/edit_task_state.dart';

class EditTaskBloc extends Bloc<EditTaskEvent, EditTaskState> {
  static int lastNotificationID = 0;
  int newNotificationID = ++lastNotificationID;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedTimeNotification = const TimeOfDay(hour: 0, minute: 0);
  bool isNotification = false;

  EditTaskBloc() : super(const EditTaskInitial()) {
    on<EditTaskButtonPressed>(_onEditTaskButtonPressed);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectTimeEvent>(_onSelectTime);
    on<SelectTimeNotificationEvent>(_onSelectTimeNotification);
  }

  void _onSelectDate(SelectDateEvent event, Emitter<EditTaskState> emit) async {
    emit(const EditTaskInitial());

    final DateTime? selectedDate = await showDatePicker(
      context: event.context,
      initialDate: event.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selectedDate != null) {
      emit(DateSelectedState(selectedDate));
    }
  }

  void _onSelectTime(SelectTimeEvent event, Emitter<EditTaskState> emit) async {
    emit(const EditTaskInitial());

    final TimeOfDay? selectedTime = await showTimePicker(
      context: event.context,
      initialTime: event.selectedTime,
    );
    if (selectedTime != null) {
      emit(TimeSelectedState(selectedTime));
    }
  }

  void _onSelectTimeNotification(
      SelectTimeNotificationEvent event, Emitter<EditTaskState> emit) async {
    emit(const EditTaskInitial());

    final TimeOfDay? selectedTimeNotification = await showTimePicker(
      context: event.context,
      initialTime: event.selectedTimeNotification,
    );
    if (selectedTimeNotification != null) {
      emit(TimeNotificationSelectedState(selectedTimeNotification));
    }
  }

  void _onEditTaskButtonPressed(
      EditTaskButtonPressed event, Emitter<EditTaskState> emit) async {
    emit(const EditTaskInitial());
    try {
      if (event.content.isEmpty) {
        emit(const EditTaskFailure(error: 'Vui lòng nhập nội dung task!'));
      } else {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance
              .collection('tasks')
              .doc(event.id)
              .update({
            'description': event.content,
            'dueDate': event.selectedDate,
            'updatedAt': DateTime.now(),
            'timeOfDueDay':
                "${event.selectedTime.hour}:${event.selectedTime.minute}",
            'isNotification': event.isNotification,
            'timeNotification':
                "${event.selectedTimeNotification.hour}:${event.selectedTimeNotification.minute}",
          });
        }
        emit(const EditTaskSuccess());
      }
    } catch (error) {
      emit(EditTaskFailure(error: "Lỗi: $error"));
    }
  }
}
