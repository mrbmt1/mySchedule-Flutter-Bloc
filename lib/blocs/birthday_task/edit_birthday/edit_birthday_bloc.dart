import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myschedule/blocs/birthday_task/edit_birthday/edit_birthday_event.dart';
import 'package:myschedule/blocs/birthday_task/edit_birthday/edit_birthday_state.dart';

class EditBirthDayTaskBloc
    extends Bloc<EditBirthDayTaskEvent, EditBirthDayTaskState> {
  static int lastNotificationID = 0;
  int newNotificationID = ++lastNotificationID;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  TimeOfDay selectedTimeNotification = const TimeOfDay(hour: 0, minute: 0);
  bool isNotification = false;

  EditBirthDayTaskBloc() : super(const EditBirthDayTaskInitial()) {
    on<EditBirthDayTaskButtonPressed>(_onEditBirthDayTaskButtonPressed);
    on<SelectDateEvent>(_onSelectDate);
    on<SelectTimeNotificationEvent>(_onSelectTimeNotification);
  }

  void _onSelectDate(
      SelectDateEvent event, Emitter<EditBirthDayTaskState> emit) async {
    emit(const EditBirthDayTaskInitial());

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

  void _onSelectTimeNotification(SelectTimeNotificationEvent event,
      Emitter<EditBirthDayTaskState> emit) async {
    emit(const EditBirthDayTaskInitial());

    final TimeOfDay? selectedTimeNotification = await showTimePicker(
      context: event.context,
      initialTime: event.selectedTimeNotification,
    );
    if (selectedTimeNotification != null) {
      emit(TimeNotificationSelectedState(selectedTimeNotification));
    }
  }

  void _onEditBirthDayTaskButtonPressed(EditBirthDayTaskButtonPressed event,
      Emitter<EditBirthDayTaskState> emit) async {
    emit(const EditBirthDayTaskInitial());
    try {
      if (event.content.isEmpty) {
        emit(const EditBirthDayTaskFailure(
            error: 'Vui lòng nhập nội dung sinh nhật!'));
      } else {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          await FirebaseFirestore.instance
              .collection('birthdays')
              .doc(event.id)
              .update({
            'description': event.content,
            'birthDay': event.selectedDate,
            'updatedAt': DateTime.now(),
            'isNotification': event.isNotification,
            'timeNotification':
                "${event.selectedTimeNotification.hour}:${event.selectedTimeNotification.minute}",
          });
        }
        emit(const EditBirthDayTaskSuccess());
      }
    } catch (error) {
      emit(EditBirthDayTaskFailure(error: "Lỗi: $error"));
    }
  }
}
