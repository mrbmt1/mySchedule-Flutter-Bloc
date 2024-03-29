import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CreateTaskState extends Equatable {
  const CreateTaskState();

  @override
  List<Object?> get props => [];
}

class CreateTaskInitial extends CreateTaskState {
  const CreateTaskInitial();

  @override
  List<Object?> get props => [];
}

class CreateTaskLoading extends CreateTaskState {
  const CreateTaskLoading();

  @override
  List<Object?> get props => [];
}

class CreateTaskSuccess extends CreateTaskState {
  const CreateTaskSuccess();

  @override
  List<Object?> get props => [];
}

class CreateTaskFailure extends CreateTaskState {
  final String error;

  const CreateTaskFailure({
    required this.error,
  });

  @override
  List<Object?> get props => [error];
}

class DateSelectedState extends CreateTaskState {
  final DateTime selectedDate;

  const DateSelectedState(this.selectedDate);
  @override
  List<Object?> get props => [selectedDate];
}

class TimeSelectedState extends CreateTaskState {
  final TimeOfDay selectedTime;

  const TimeSelectedState(this.selectedTime);
  @override
  List<Object?> get props => [selectedTime];
}

class TimeNotificationSelectedState extends CreateTaskState {
  final TimeOfDay selectedTimeNotification;

  const TimeNotificationSelectedState(this.selectedTimeNotification);
  @override
  List<Object?> get props => [selectedTimeNotification];
}
