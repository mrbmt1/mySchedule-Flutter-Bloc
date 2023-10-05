import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class CreateBirthDayTaskState extends Equatable {
  const CreateBirthDayTaskState();

  @override
  List<Object?> get props => [];
}

class CreateBirthDayTaskInitial extends CreateBirthDayTaskState {
  const CreateBirthDayTaskInitial();

  @override
  List<Object?> get props => [];
}

class CreateBirthDayTaskLoading extends CreateBirthDayTaskState {
  const CreateBirthDayTaskLoading();

  @override
  List<Object?> get props => [];
}

class CreateBirthDayTaskSuccess extends CreateBirthDayTaskState {
  const CreateBirthDayTaskSuccess();

  @override
  List<Object?> get props => [];
}

class CreateBirthDayTaskFailure extends CreateBirthDayTaskState {
  final String error;

  const CreateBirthDayTaskFailure({
    required this.error,
  });

  @override
  List<Object?> get props => [error];
}

class DateSelectedState extends CreateBirthDayTaskState {
  final DateTime selectedDate;

  const DateSelectedState(this.selectedDate);
  @override
  List<Object?> get props => [selectedDate];
}

class TimeSelectedState extends CreateBirthDayTaskState {
  final TimeOfDay selectedTime;

  const TimeSelectedState(this.selectedTime);
  @override
  List<Object?> get props => [selectedTime];
}

class TimeNotificationSelectedState extends CreateBirthDayTaskState {
  final TimeOfDay selectedTimeNotification;

  const TimeNotificationSelectedState(this.selectedTimeNotification);
  @override
  List<Object?> get props => [selectedTimeNotification];
}
