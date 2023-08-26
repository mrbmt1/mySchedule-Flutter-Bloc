import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileFailure extends ProfileState {
  final String error;

  const ProfileFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class ProfileSuccess extends ProfileState {}

class ProfileDataState extends ProfileState {
  final Map<String, dynamic> userData;

  const ProfileDataState(this.userData);

  @override
  List<Object?> get props => [userData];
}
