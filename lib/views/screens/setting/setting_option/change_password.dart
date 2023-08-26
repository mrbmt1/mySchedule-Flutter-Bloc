import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool enableFields = true;

  @override
  void initState() {
    super.initState();
    checkUserRole();
  }

  Future<void> checkUserRole() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    final usersCollection = FirebaseFirestore.instance.collection('users');
    final currentUserDoc = await usersCollection.doc(currentUserId).get();
    final userRole = currentUserDoc.data()?['role'] as String?;

    if (userRole == 'google' || userRole == 'facebook' || userRole == 'phone') {
      setState(() {
        enableFields = false;
      });
    } else {
      setState(() {
        enableFields = true;
      });
    }
  }

  Future<void> _updatePassword() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser?.uid)
        .get();
    final data = snapshot.data();
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final passwordHash =
          sha256.convert(utf8.encode(currentPassword)).toString();
      if (passwordHash == data!['password']) {
        if (newPassword == _confirmPasswordController.text.trim()) {
          final newHashedPassword =
              sha256.convert(utf8.encode(newPassword)).toString();
          FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser?.uid)
              .update({'password': newHashedPassword}).then((value) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật mật khẩu thành công'),
                backgroundColor: Colors.green,
              ),
            );
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Có lỗi xảy ra khi cập nhật mật khẩu'),
                backgroundColor: Colors.red,
              ),
            );
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xác nhận mật khẩu không khớp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu hiện tại không đúng'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _currentPasswordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(),
              ),
              obscureText: !_showCurrentPassword,
              enabled: enableFields,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _newPasswordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(),
              ),
              obscureText: !_showNewPassword,
              enabled: enableFields,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
                focusedBorder: const OutlineInputBorder(),
              ),
              obscureText: !_showConfirmPassword,
              enabled: enableFields,
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: !enableFields,
              child: const Text(
                'Vì bạn là người dùng đăng nhập bằng Google, Facebook hoặc số điện thoại nên không thể sử dụng chức năng này.',
                style: TextStyle(color: Colors.red),
              ),
            ),
            Visibility(
              visible: !enableFields,
              child: const SizedBox(height: 10),
            ),
            ElevatedButton(
              onPressed: enableFields ? _updatePassword : null,
              child: const Text('Cập nhật mật khẩu'),
            ),
          ],
        ),
      ),
    );
  }
}
