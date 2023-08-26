import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_event.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_state.dart';
import 'package:myschedule/views/widgets/school_schedule_widgets/shared_schedules_dialog_widget.dart';

class SchoolScheduleBloc
    extends Bloc<SchoolScheduleEvent, SchoolScheduleState> {
  final FirebaseAuth _firebaseAuth;

  SchoolScheduleBloc(this._firebaseAuth) : super(SchoolScheduleInitial()) {
    on<UpdateScheduleButtonPressed>(_onUpdateScheduleButtonPressed);
    on<ShowSharedSchedulesDialogButtonPressed>(
        _onShowSharedSchedulesDialogButtonPressed);
    on<LoadSharedUserEvent>(_onLoadSharedUserState);
    on<SearchValueChanged>(_onSearchValueChanged);
  }

  void _onUpdateScheduleButtonPressed(UpdateScheduleButtonPressed event,
      Emitter<SchoolScheduleState> emit) async {
    emit(SchoolScheduleInitial());

    event.day;
    event.subjectControllers;
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .doc(currentUser?.uid)
        .get();
    final data = snapshot.data();

    Map<String, dynamic> scheduleData = {
      event.day: {
        for (var i = 0; i < 12; i++)
          'subject${i + 1}': event.subjectControllers[i].text,
      },
    };

    try {
      if (data != null) {
        await FirebaseFirestore.instance
            .collection('schedules')
            .doc(currentUser?.uid)
            .update(scheduleData);
      } else {
        await FirebaseFirestore.instance
            .collection('schedules')
            .doc(currentUser?.uid)
            .set(scheduleData);
      }
      emit(SchoolScheduleSuccess());
    } catch (e) {
      emit(const SchoolScheduleFailure(error: "Cập nhật thất bại!"));
    }
  }

  void _onShowSharedSchedulesDialogButtonPressed(
      ShowSharedSchedulesDialogButtonPressed event,
      Emitter<SchoolScheduleState> emit) async {
    emit(SchoolScheduleInitial());

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid;

      final sharedSchedulesCollection =
          FirebaseFirestore.instance.collection('sharedSchedules');
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final schedulesCollection =
          FirebaseFirestore.instance.collection('schedules');

      final currentUserDoc = await usersCollection.doc(currentUserId).get();
      final currentUsername = currentUserDoc.data()?['username'] as String?;

      final sharedSchedulesSnapshot = await sharedSchedulesCollection
          .where('sharedUserId', isEqualTo: currentUsername)
          .get();

      final sharedSchedules =
          sharedSchedulesSnapshot.docs.map((doc) => doc.data()).toList();

      // ignore: use_build_context_synchronously
      showDialog(
        context: event.context,
        builder: (context) {
          return SharedSchedulesDialog(
            sharedSchedules: sharedSchedules,
            subjectControllers: event.subjectControllers,
            usersCollection: usersCollection,
            sharedSchedulesCollection: sharedSchedulesCollection,
            schedulesCollection: schedulesCollection,
            currentUsername: currentUsername.toString(),
            scaffoldKey: event.scaffoldKey,
            day: event.day,
          );
        },
      );
    } catch (e) {
      emit(const SchoolScheduleFailure(
          error: "Lỗi hiển thị thời khóa biểu chia sẻ!"));
    }
  }

  void _onLoadSharedUserState(
      LoadSharedUserEvent event, Emitter<SchoolScheduleState> emit) async {
    emit(SchoolScheduleInitial());

    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    final sharedSchedulesSnapshot = await FirebaseFirestore.instance
        .collection('schedules')
        .where('shareWith')
        .where(FieldPath.documentId, isEqualTo: currentUserId)
        .get();

    final List<String> loadedSharedUsers = [];

    for (var doc in sharedSchedulesSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('shareWith')) {
        final shareWith = data['shareWith'];
        if (shareWith is List) {
          loadedSharedUsers.addAll(shareWith.map((user) => user.toString()));
        } else if (shareWith is Map) {
          loadedSharedUsers
              .addAll(shareWith.values.map((user) => user.toString()));
        }
      }
    }
    emit(LoadSharedUserState(sharedUsers: loadedSharedUsers));
  }

  void _onSearchValueChanged(
      SearchValueChanged event, Emitter<SchoolScheduleState> emit) async {
    emit(SchoolScheduleInitial());

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final suggestionQuery = usersCollection
        .where('username', isGreaterThanOrEqualTo: event.value)
        .where('username', isLessThanOrEqualTo: '${event.value}\uf8ff')
        .limit(5);

    try {
      final querySnapshot = await suggestionQuery.get();
      if (querySnapshot.docs.isNotEmpty) {
        final suggestions = querySnapshot.docs
            .map((doc) => doc['username'].toString())
            .where((username) => !event.sharedUsers.contains(username))
            .toList();
        emit(SearchSuggestionsLoaded(suggestions: suggestions));
      } else {
        emit(const SearchSuggestionsLoaded(suggestions: []));
      }
    } catch (e) {
      emit(const SearchError(error: "Error loading search suggestions"));
    }
  }
}
