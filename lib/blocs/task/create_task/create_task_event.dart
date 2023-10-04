import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CreateTaskEvent extends Equatable {
  const CreateTaskEvent();

  @override
  List<Object?> get props => [];
}

class UpdateTaskDateEvent extends CreateTaskEvent {
  final DateTime selectedDate;

  const UpdateTaskDateEvent({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

class UpdateTaskTimeEvent extends CreateTaskEvent {
  final TimeOfDay selectedTime;

  const UpdateTaskTimeEvent({required this.selectedTime});

  @override
  List<Object?> get props => [selectedTime];
}

class UpdateTaskNotificationTimeEvent extends CreateTaskEvent {
  final TimeOfDay selectedTimeNotification;

  const UpdateTaskNotificationTimeEvent(
      {required this.selectedTimeNotification});

  @override
  List<Object?> get props => [selectedTimeNotification];
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
