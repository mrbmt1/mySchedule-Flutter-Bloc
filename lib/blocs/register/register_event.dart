import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterButtonPressed extends RegisterEvent {
  final String username;
  final String password;
  final String fullName;
  final String phone;
  final String email;
  final String dob;
  final String gender;

  const RegisterButtonPressed({
    required this.username,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.dob,
    required this.gender,
  });

  @override
  List<Object?> get props =>
      [username, password, fullName, phone, email, dob, gender];
}
