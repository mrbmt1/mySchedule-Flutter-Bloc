import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/profile/profile_event.dart';
import 'package:myschedule/blocs/profile/profile_state.dart';
import 'package:myschedule/utils/profile/role_check.dart';
import 'package:myschedule/views/widgets/profile/password_confirm_dialog.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _firebaseAuth;

  ProfileBloc(this._firebaseAuth) : super(ProfileInitial()) {
    on<EditProfileButtonPressed>(_onEditProfileButtonPressed);
    on<LoadUserData>(_onLoadUserData);
  }

  void _onEditProfileButtonPressed(
      EditProfileButtonPressed event, Emitter<ProfileState> emit) async {
    emit(ProfileInitial());

    bool requirePassword = await shouldSkipPasswordVerification();
    if (requirePassword) {
      emit(ProfileSuccess());
      return;
    }
    // ignore: use_build_context_synchronously
    await showDialog(
      context: event.context,
      builder: (BuildContext context) {
        return PasswordConfirmationDialog(scaffoldContext: event.context);
      },
    );
  }

  void _onLoadUserData(LoadUserData event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      final uid = currentUser.uid;
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final phone = userSnapshot['phone'];
      final email = userSnapshot['email'];

      final userData = Map<String, dynamic>.from(userSnapshot.data()!);

      if (phone != null && phone.length > 3) {
        final maskedPhone =
            phone.replaceRange(4, phone.length, '*' * (phone.length - 4));
        userData['phone'] = maskedPhone;
      }

      if (email != null && email.length > 3) {
        final maskedEmail =
            email.replaceRange(4, email.length, '*' * (email.length - 4));
        userData['email'] = maskedEmail;
      }

      emit(ProfileDataState(userData));
    }
  }
}
