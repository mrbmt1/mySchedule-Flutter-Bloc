import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CreateTaskEvent extends Equatable {
  const CreateTaskEvent();

  @override
  List<Object?> get props => [];
}

class SelectDateEvent extends CreateTaskEvent {
  final DateTime selectedDate;
  final BuildContext context;

  const SelectDateEvent(this.selectedDate, this.context);
  @override
  List<Object?> get props => [selectedDate, context];
}

class SelectTimeEvent extends CreateTaskEvent {
  final TimeOfDay selectedTime;
  final BuildContext context;

  const SelectTimeEvent(this.selectedTime, this.context);
  @override
  List<Object?> get props => [selectedTime, context];
}

class SelectTimeNotificationEvent extends CreateTaskEvent {
  final TimeOfDay selectedTimeNotification;
  final BuildContext context;

  const SelectTimeNotificationEvent(
      this.selectedTimeNotification, this.context);
  @override
  List<Object?> get props => [selectedTimeNotification, context];
}

class CreateTaskButtonPressed extends CreateTaskEvent {
  final String content;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TimeOfDay selectedTimeNotification;
  final bool isNotification;

  const CreateTaskButtonPressed({
    required this.content,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedTimeNotification,
    required this.isNotification,
  });

  @override
  List<Object?> get props => [
        content,
        selectedDate,
        selectedTime,
        selectedTimeNotification,
        isNotification,
      ];
}
