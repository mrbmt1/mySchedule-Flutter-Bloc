import 'package:equatable/equatable.dart';

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
