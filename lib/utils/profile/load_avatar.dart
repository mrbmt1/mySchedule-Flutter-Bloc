import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future<Widget> getImage(Map<String, dynamic> userData) async {
  if (userData.containsKey('avatarURL')) {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .refFromURL(userData['avatarURL']);
      final url = await ref.getDownloadURL();
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.person),
        ),
      );
    } catch (e) {
      // print('Error loading image: $e');
      return const Text('Chưa có avatar');
    }
  } else {
    return const ClipOval(
      child: Icon(Icons.person, size: 120),
    );
  }
}
