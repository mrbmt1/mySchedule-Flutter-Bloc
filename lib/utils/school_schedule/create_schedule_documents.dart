import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> createScheduleDocument(String sharedUserId) async {
  final scheduleDocRef =
      FirebaseFirestore.instance.collection('schedules').doc(sharedUserId);
  final scheduleId = scheduleDocRef.id;

  await scheduleDocRef.set({}, SetOptions(merge: true));

  return scheduleId;
}
