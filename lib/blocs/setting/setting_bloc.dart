import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/setting/setting_event.dart';
import 'package:myschedule/blocs/setting/setting_state.dart';
import 'package:package_info/package_info.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  final FirebaseAuth _firebaseAuth;

  SettingBloc(this._firebaseAuth) : super(SettingInitial()) {
    on<DeleteAccountButtonPressed>(_onDeleteAccountButtonPressed);
    on<LoadAppVersionEvent>(_onLoadAppVersion);
  }

  void _onDeleteAccountButtonPressed(
      DeleteAccountButtonPressed event, Emitter<SettingState> emit) async {
    emit(SettingInitial());

    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    try {
      final avatarRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final userData = await avatarRef.get();
      final avatarURL = userData.data()?['avatarURL'];

      if (avatarURL != null && avatarURL.isNotEmpty) {
        final storageRef = FirebaseStorage.instance.refFromURL(avatarURL);
        await storageRef.delete();
      }
    } catch (error) {
      print("Error deleting avatar: $error");
    }

    try {
      final tasksRef = FirebaseFirestore.instance
          .collection('tasks')
          .where('userID', isEqualTo: uid);
      final taskDocs = await tasksRef.get();
      for (final doc in taskDocs.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      print("Error deleting tasks: $error");
    }

    try {
      final birthdaysRef = FirebaseFirestore.instance
          .collection('birthdays')
          .where('userID', isEqualTo: uid);
      final birthdayDocs = await birthdaysRef.get();
      for (final doc in birthdayDocs.docs) {
        await doc.reference.delete();
      }
    } catch (error) {
      print("Error deleting birthdays: $error");
    }

    try {
      final schedulesRef = FirebaseFirestore.instance.collection('schedules');
      final scheduleDocs = await schedulesRef.get();
      for (final doc in scheduleDocs.docs) {
        if (doc.id == uid) {
          await doc.reference.delete();
        }
      }
    } catch (error) {
      print("Error deleting schedules: $error");
    }

    try {
      final sharedSchedulesRef =
          FirebaseFirestore.instance.collection('sharedSchedules');
      final sharedScheduleDocs = await sharedSchedulesRef.get();

      for (final doc in sharedScheduleDocs.docs) {
        final data = doc.data();
        if (data['scheduleId'] == uid) {
          await doc.reference.delete();
        }
      }
    } catch (error) {
      print("Error deleting shared schedules: $error");
    }

    final userDocumentRef =
        FirebaseFirestore.instance.collection('users').doc(uid);
    try {
      await userDocumentRef.delete();
    } catch (error) {
      print("Error deleting user document: $error");
    }

    try {
      await user?.delete();
      emit(const SettingSuccess());
    } catch (error) {
      print("Error deleting user account: $error");
      emit(const SettingFailure(
          error: "Xóa tài khoản không thành công, vui lòng thử lại"));
    }
  }

  void _onLoadAppVersion(
      LoadAppVersionEvent event, Emitter<SettingState> emit) async {
    emit(SettingLoading());

    final packageInfo = await PackageInfo.fromPlatform();
    final appVersion = packageInfo.version;

    emit(LoadAppVersionState(appVersion: appVersion));
  }
}
