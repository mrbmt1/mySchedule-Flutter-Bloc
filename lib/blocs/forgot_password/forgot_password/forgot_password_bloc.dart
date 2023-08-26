import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/forgot_password/forgot_password/forgot_password_event.dart';
import 'package:myschedule/blocs/forgot_password/forgot_password/forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final FirebaseAuth _firebaseAuth;

  ForgotPasswordBloc(this._firebaseAuth) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordButtonPressed>(_onForgotPasswordButtonPressed);
  }

  void _onForgotPasswordButtonPressed(ForgotPasswordButtonPressed event,
      Emitter<ForgotPasswordState> emit) async {
    emit(ForgotPasswordInitial());

    try {
      final username = event.username;
      final phone = event.phone;
      final email = event.email;

      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .where('phone', isEqualTo: phone)
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.length == 1) {
        final Map<String, dynamic> data =
            result.docs[0].data() as Map<String, dynamic>;
        final String username = data['username'] as String;
        // Show success message
        emit(ForgotPasswordSuccess());
      } else {
        emit(const ForgotPasswordFailure(
            error: "Thông tin tài khoản không chính xác"));
      }
    } catch (error) {
      emit(ForgotPasswordFailure(error: error.toString()));
    }
  }
}
