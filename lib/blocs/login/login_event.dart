import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class LoginButtonPressed extends LoginEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const LoginButtonPressed(
      {required this.username,
      required this.password,
      required this.rememberMe});

  @override
  List<Object?> get props => [username, password, rememberMe];
}

class GoogleLoginButtonPressed extends LoginEvent {
  final String accessToken;
  final String idToken;
  final bool rememberMe;

  const GoogleLoginButtonPressed(
      {required this.accessToken,
      required this.idToken,
      required this.rememberMe});

  @override
  List<Object?> get props => [accessToken, idToken, rememberMe];
}

class FacebookLoginButtonPressed extends LoginEvent {
  final bool rememberMe;

  const FacebookLoginButtonPressed({required this.rememberMe});

  @override
  List<Object?> get props => [rememberMe];
}

class PhoneNumberLoginButtonPressed extends LoginEvent {
  final String phoneNumber;

  const PhoneNumberLoginButtonPressed({
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [phoneNumber];
}

class RememberMeButtonPressed extends LoginEvent {
  final String username;
  final String password;
  final bool rememberMe;

  const RememberMeButtonPressed({
    required this.username,
    required this.password,
    required this.rememberMe,
  });

  @override
  List<Object?> get props => [username, password, rememberMe];
}
