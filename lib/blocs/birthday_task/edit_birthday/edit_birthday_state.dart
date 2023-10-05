import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class EditBirthDayTaskState extends Equatable {
  const EditBirthDayTaskState();

  @override
  List<Object?> get props => [];
}

class EditBirthDayTaskInitial extends EditBirthDayTaskState {
  const EditBirthDayTaskInitial();

  @override
  List<Object?> get props => [];
}

class EditBirthDayTaskLoading extends EditBirthDayTaskState {
  const EditBirthDayTaskLoading();

  @override
  List<Object?> get props => [];
}

class EditBirthDayTaskSuccess extends EditBirthDayTaskState {
  const EditBirthDayTaskSuccess();

  @override
  List<Object?> get props => [];
}

class EditBirthDayTaskFailure extends EditBirthDayTaskState {
  final String error;

  const EditBirthDayTaskFailure({
    required this.error,
  });

  @override
  List<Object?> get props => [error];
}

class DateSelectedState extends EditBirthDayTaskState {
  final DateTime selectedDate;

  const DateSelectedState(this.selectedDate);
  @override
  List<Object?> get props => [selectedDate];
}

class TimeSelectedState extends EditBirthDayTaskState {
  final TimeOfDay selectedTime;

  const TimeSelectedState(this.selectedTime);
  @override
  List<Object?> get props => [selectedTime];
}

class TimeNotificationSelectedState extends EditBirthDayTaskState {
  final TimeOfDay selectedTimeNotification;

  const TimeNotificationSelectedState(this.selectedTimeNotification);
  @override
  List<Object?> get props => [selectedTimeNotification];
}
