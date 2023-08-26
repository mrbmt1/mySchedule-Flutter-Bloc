import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> shouldSkipPasswordVerification() async {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    final uid = currentUser.uid;
    final userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = userSnapshot.get('role');
    return role == 'google' || role == 'facebook' || role == 'phone';
  }
  return false;
}
