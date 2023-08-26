import 'package:equatable/equatable.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordButtonPressed extends ForgotPasswordEvent {
  final String username;
  final String phone;
  final String email;

  const ForgotPasswordButtonPressed({
    required this.username,
    required this.phone,
    required this.email,
  });

  @override
  List<Object?> get props => [
        username,
        phone,
        email,
      ];
}
