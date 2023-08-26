import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

Future getAvatar(Map<String, dynamic> userData, BuildContext context) async {
  if (userData.containsKey('avatarURL')) {
    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .refFromURL(userData['avatarURL']);
      final url = await ref.getDownloadURL();
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'imageHero',
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 30,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      }));
    } catch (e) {
      // print('Error loading image: $e');
    }
  }
}
