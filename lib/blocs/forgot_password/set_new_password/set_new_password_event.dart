import 'package:equatable/equatable.dart';

abstract class SetNewPasswordEvent extends Equatable {
  const SetNewPasswordEvent();

  @override
  List<Object?> get props => [];
}

class SetNewPasswordButtonPressed extends SetNewPasswordEvent {
  final String username;
  final String newPassword;
  final String confirmPassword;

  const SetNewPasswordButtonPressed({
    required this.username,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
        username,
        newPassword,
        confirmPassword,
      ];
}

class ToggleObscureText extends SetNewPasswordEvent {}
