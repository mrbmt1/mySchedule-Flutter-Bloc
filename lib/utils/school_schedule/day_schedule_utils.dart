import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void loadDataForDay(String day, List<TextEditingController> controllers) async {
  final currentUser = FirebaseAuth.instance.currentUser;
  final snapshot = await FirebaseFirestore.instance
      .collection('schedules')
      .doc(currentUser?.uid)
      .get();
  final data = snapshot.data();

  if (data != null && data[day] != null) {
    for (var i = 0; i < 12; i++) {
      controllers[i].text = data[day]['subject${i + 1}'] ?? '';
    }
  }
}
