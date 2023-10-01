import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/forgot_password/set_new_password/set_new_password_event.dart';
import 'package:myschedule/blocs/forgot_password/set_new_password/set_new_password_state.dart';

class SetNewPasswordBloc
    extends Bloc<SetNewPasswordEvent, SetNewPasswordState> {
  final FirebaseAuth _firebaseAuth;
  bool isObscure = true;

  SetNewPasswordBloc(this._firebaseAuth) : super(SetNewPasswordInitial()) {
    on<SetNewPasswordButtonPressed>(_onSetNewPasswordButtonPressed);
    on<ToggleObscureText>(_onToggleObscureText);
  }

  void _onSetNewPasswordButtonPressed(SetNewPasswordButtonPressed event,
      Emitter<SetNewPasswordState> emit) async {
    emit(SetNewPasswordInitial());

    String newPassword = event.newPassword;

    if (newPassword.isNotEmpty && newPassword == event.confirmPassword) {
      var bytes = utf8.encode(newPassword);
      var digest = sha256.convert(bytes);
      String hashedPassword = digest.toString();

      try {
        QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: event.username)
            .get();

        if (userQuerySnapshot.docs.isNotEmpty) {
          DocumentSnapshot userSnapshot = userQuerySnapshot.docs.first;
          String uid = userSnapshot.id;
          DocumentReference userRef =
              FirebaseFirestore.instance.collection('users').doc(uid);
          await userRef.update({'password': hashedPassword});

          emit(SetNewPasswordSuccess());
        } else {
          throw Exception('Không tìm thấy người dùng');
        }
      } catch (error) {
        emit(SetNewPasswordFailure(error: "Đổi mật khẩu thất bại, $error"));
      }
    } else {
      emit(const SetNewPasswordFailure(error: "Mật khẩu không khớp nhau"));
    }
  }

  void _onToggleObscureText(
      ToggleObscureText event, Emitter<SetNewPasswordState> emit) {
    isObscure = !isObscure;
    emit(SetNewPasswordObscureToggled(isObscure: isObscure));
    print("${isObscure}");
  }
}
