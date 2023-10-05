import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class EditTaskState extends Equatable {
  const EditTaskState();

  @override
  List<Object?> get props => [];
}

class EditTaskInitial extends EditTaskState {
  const EditTaskInitial();

  @override
  List<Object?> get props => [];
}

class EditTaskLoading extends EditTaskState {
  const EditTaskLoading();

  @override
  List<Object?> get props => [];
}

class EditTaskSuccess extends EditTaskState {
  const EditTaskSuccess();

  @override
  List<Object?> get props => [];
}

class EditTaskFailure extends EditTaskState {
  final String error;

  const EditTaskFailure({
    required this.error,
  });

  @override
  List<Object?> get props => [error];
}

class DateSelectedState extends EditTaskState {
  final DateTime selectedDate;

  const DateSelectedState(this.selectedDate);
  @override
  List<Object?> get props => [selectedDate];
}

class TimeSelectedState extends EditTaskState {
  final TimeOfDay selectedTime;

  const TimeSelectedState(this.selectedTime);
  @override
  List<Object?> get props => [selectedTime];
}

class TimeNotificationSelectedState extends EditTaskState {
  final TimeOfDay selectedTimeNotification;

  const TimeNotificationSelectedState(this.selectedTimeNotification);
  @override
  List<Object?> get props => [selectedTimeNotification];
}
