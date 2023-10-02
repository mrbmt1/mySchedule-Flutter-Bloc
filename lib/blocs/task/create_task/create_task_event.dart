import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CreateTaskEvent extends Equatable {
  const CreateTaskEvent();

  @override
  List<Object?> get props => [];
}

class CreateTaskButtonPressed extends CreateTaskEvent {
  final String content;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TimeOfDay selectedTimeNotification;
  final bool isNotification;

  CreateTaskButtonPressed({
    required this.content,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedTimeNotification,
    required this.isNotification,
  });
}
