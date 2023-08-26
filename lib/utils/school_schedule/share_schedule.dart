import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myschedule/utils/school_schedule/create_schedule_documents.dart';

Future<void> shareSchedule(
    BuildContext context, List<String> sharedUsers) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final currentUserId = currentUser?.uid;
  final avatarURL =
      'https://firebasestorage.googleapis.com/v0/b/myschedule-3a44a.appspot.com/o/cropped_avatars%2F$currentUserId.jpg?alt=media';

  if (sharedUsers.isNotEmpty) {
    for (var sharedUser in sharedUsers) {
      final scheduleId = await createScheduleDocument(currentUserId!);
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleId)
          .update({
        'shareWith': sharedUsers,
      });

      final sharedScheduleId = '$scheduleId-$sharedUser';
      final sharedScheduleDoc = FirebaseFirestore.instance
          .collection('sharedSchedules')
          .doc(sharedScheduleId);

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();
      final fullName = userDoc['fullName'];
      final avatarURL = userDoc['avatarURL'] ?? '';

      await sharedScheduleDoc.set({
        'scheduleId': scheduleId,
        'sharedUserId': sharedUser,
        'fullName': fullName,
        'avatarURL': avatarURL,
      });

      // Remove excess shared schedules
      final excessSharedSchedulesSnapshot = await FirebaseFirestore.instance
          .collection('sharedSchedules')
          .where('scheduleId', isEqualTo: scheduleId)
          .get();

      for (var doc in excessSharedSchedulesSnapshot.docs) {
        final excessSharedUser = doc['sharedUserId'];
        if (!sharedUsers.contains(excessSharedUser)) {
          await doc.reference.delete();
        }
      }
    }
  } else {
    await FirebaseFirestore.instance
        .collection('schedules')
        .doc(currentUserId!)
        .update({
      'shareWith': [],
    });

    // Remove all shared schedules
    final sharedSchedulesSnapshot = await FirebaseFirestore.instance
        .collection('sharedSchedules')
        .where('scheduleId', isEqualTo: currentUserId)
        .get();

    for (var doc in sharedSchedulesSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Navigator.pop(context);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Danh sách chia sẻ đã được cập nhật thành công.'),
      backgroundColor: Colors.green,
    ),
  );
}
