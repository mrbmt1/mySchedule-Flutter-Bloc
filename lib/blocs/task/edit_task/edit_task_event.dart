import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class EditTaskEvent extends Equatable {
  const EditTaskEvent();

  @override
  List<Object?> get props => [];
}

class EditTaskButtonPressed extends EditTaskEvent {
  final String id;
  final String content;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TimeOfDay selectedTimeNotification;
  final bool isNotification;

  const EditTaskButtonPressed({
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
