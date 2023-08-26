import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/blocs/register/register_event.dart';
import 'package:myschedule/blocs/register/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final FirebaseAuth _firebaseAuth;

  RegisterBloc(this._firebaseAuth) : super(RegisterInitial()) {
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
  }

  void _onRegisterButtonPressed(
      RegisterButtonPressed event, Emitter<RegisterState> emit) async {
    emit(RegisterInitial());

    try {
      // Kiểm tra trùng lặp tên đăng nhập hoặc email
      final signInMethods =
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(event.email);
      if (signInMethods.isNotEmpty) {
        emit(const RegisterFailure(error: "Email đã được sử dụng"));
        return;
      }

      final userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: event.phone)
          .get();
      if (userQuery.docs.isNotEmpty) {
        emit(const RegisterFailure(error: "Số điện thoại đã được sử dụng"));
        return;
      }

      final dob = DateFormat('yyyy-MM-dd').parse(event.dob);
      final formattedDob = DateFormat('dd/MM/yyyy').format(dob);

      final usernameQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: event.username)
          .get();
      if (usernameQuery.docs.isNotEmpty) {
        emit(const RegisterFailure(error: "Tên đăng nhập đã được sử dụng'"));
        return;
      }

      final signInResult =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (signInResult.user == null) {
        emit(const RegisterFailure(error: "Đăng ký không thành công"));
        return;
      }

      final passwordHash =
          sha256.convert(utf8.encode(event.password)).toString();

      final user = {
        'uid': signInResult.user!.uid,
        'username': event.username,
        'password': passwordHash,
        'fullName': event.fullName,
        'phone': event.phone,
        'email': event.email,
        'dob': formattedDob,
        'gender': event.gender,
        'role': 'default',
        'bio': '',
        'avatarURL': '',
      };
      await FirebaseFirestore.instance
          .collection('users')
          .doc(signInResult.user!.uid)
          .set(user);
      emit(RegisterSuccess());
    } on FirebaseAuthException catch (e) {
      emit(const RegisterFailure(error: "Đăng ký không thành công"));
    } catch (e) {
      emit(const RegisterFailure(error: "Đăng ký không thành công"));
    }
  }
}
