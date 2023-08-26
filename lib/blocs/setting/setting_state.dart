import 'package:equatable/equatable.dart';

abstract class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitial extends SettingState {}

class SettingLoading extends SettingState {}

class SettingFailure extends SettingState {
  final String error;

  const SettingFailure({required this.error});

  @override
  List<Object?> get props => [error];
}

class SettingSuccess extends SettingState {
  const SettingSuccess();

  @override
  List<Object?> get props => [];
}

class LoadAppVersionState extends SettingState {
  final String appVersion;

  const LoadAppVersionState({required this.appVersion});

  @override
  List<Object?> get props => [appVersion];
}
