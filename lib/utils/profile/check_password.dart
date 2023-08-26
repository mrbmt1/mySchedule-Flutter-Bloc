import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> checkPassword(User currentUser, String enteredPassword) async {
  final uid = currentUser.uid;
  final userSnapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final storedPassword = userSnapshot.get('password');
  final passwordHash = sha256.convert(enteredPassword.codeUnits).toString();
  return storedPassword == passwordHash;
}
