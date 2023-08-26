import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class DeleteAccountButtonPressed extends SettingEvent {
  const DeleteAccountButtonPressed();

  @override
  List<Object?> get props => [];
}

class LoadAppVersionEvent extends SettingEvent {
  const LoadAppVersionEvent();

  @override
  List<Object?> get props => [];
}
