import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SchoolScheduleEvent extends Equatable {
  const SchoolScheduleEvent();

  @override
  List<Object?> get props => [];
}

class UpdateScheduleButtonPressed extends SchoolScheduleEvent {
  final String day;
  final List<TextEditingController> subjectControllers;

  const UpdateScheduleButtonPressed({
    required this.day,
    required this.subjectControllers,
  });

  @override
  List<Object?> get props => [
        day,
        subjectControllers,
      ];
}

class ShowSharedSchedulesDialogButtonPressed extends SchoolScheduleEvent {
  final String day;
  final List<TextEditingController> subjectControllers;
  final BuildContext context;
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ShowSharedSchedulesDialogButtonPressed({
    required this.day,
    required this.subjectControllers,
    required this.context,
    required this.scaffoldKey,
  });

  @override
  List<Object?> get props => [day, subjectControllers, context, scaffoldKey];
}

class LoadSharedUserEvent extends SchoolScheduleEvent {}

class SearchValueChanged extends SchoolScheduleEvent {
  final String value;
  final List<String> sharedUsers;

  const SearchValueChanged({
    required this.value,
    required this.sharedUsers,
  });

  @override
  List<Object?> get props => [value, sharedUsers];
}
