import 'package:equatable/equatable.dart';

abstract class SchoolScheduleState extends Equatable {
  const SchoolScheduleState();

  @override
  List<Object?> get props => [];
}

class SchoolScheduleInitial extends SchoolScheduleState {}

class SchoolScheduleLoading extends SchoolScheduleState {}

class SchoolScheduleFailure extends SchoolScheduleState {
  final String error;

  const SchoolScheduleFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class SchoolScheduleSuccess extends SchoolScheduleState {}

class LoadSharedUserState extends SchoolScheduleState {
  final List<String> sharedUsers;

  const LoadSharedUserState({required this.sharedUsers});

  @override
  List<Object?> get props => [sharedUsers];
}

class SearchSuggestionsLoaded extends SchoolScheduleState {
  final List<String> suggestions;

  const SearchSuggestionsLoaded({required this.suggestions});

  @override
  List<Object?> get props => [suggestions];
}

class SearchError extends SchoolScheduleState {
  final String error;

  const SearchError({required this.error});

  @override
  List<Object?> get props => [error];
}
