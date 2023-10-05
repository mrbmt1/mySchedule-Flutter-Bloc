import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class EditBirthDayTaskEvent extends Equatable {
  const EditBirthDayTaskEvent();

  @override
  List<Object?> get props => [];
}

class EditBirthDayTaskButtonPressed extends EditBirthDayTaskEvent {
  final String id;
  final String content;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TimeOfDay selectedTimeNotification;
  final bool isNotification;

  const EditBirthDayTaskButtonPressed({
    required this.id,
    required this.content,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedTimeNotification,
    required this.isNotification,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        selectedDate,
        selectedTime,
        selectedTimeNotification,
        isNotification,
      ];
}

class SelectDateEvent extends EditBirthDayTaskEvent {
  final DateTime selectedDate;
  final BuildContext context;

  const SelectDateEvent(this.selectedDate, this.context);
  @override
  List<Object?> get props => [selectedDate, context];
}

class SelectTimeEvent extends EditBirthDayTaskEvent {
  final TimeOfDay selectedTime;
  final BuildContext context;

  const SelectTimeEvent(this.selectedTime, this.context);
  @override
  List<Object?> get props => [selectedTime, context];
}

class SelectTimeNotificationEvent extends EditBirthDayTaskEvent {
  final TimeOfDay selectedTimeNotification;
  final BuildContext context;

  const SelectTimeNotificationEvent(
      this.selectedTimeNotification, this.context);
  @override
  List<Object?> get props => [selectedTimeNotification, context];
}
