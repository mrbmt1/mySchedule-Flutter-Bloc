import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> isEmailUsed(String email) async {
  final QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('email', isEqualTo: email)
      .limit(1)
      .get();

  return snapshot.docs.isNotEmpty;
}
