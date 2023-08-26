import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myschedule/utils/profile/check_password.dart';
import 'package:myschedule/views/screens/profile/edit_profile.dart';

class PasswordConfirmationDialog extends StatefulWidget {
  final BuildContext scaffoldContext;

  const PasswordConfirmationDialog({Key? key, required this.scaffoldContext})
      : super(key: key);
  @override
  _PasswordConfirmationDialogState createState() =>
      _PasswordConfirmationDialogState();
}

class _PasswordConfirmationDialogState
    extends State<PasswordConfirmationDialog> {
  String password = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Xác nhận mật khẩu hiện tại'),
      content: TextFormField(
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Mật khẩu',
          border: OutlineInputBorder(),
        ),
        onChanged: (value) {
          setState(() {
            password = value;
          });
        },
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Hủy'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Xác nhận'),
          onPressed: () async {
            FocusScope.of(context).unfocus();
            final currentUser = FirebaseAuth.instance.currentUser;

            if (currentUser != null) {
              final passwordMatched =
                  await checkPassword(currentUser, password);
              if (passwordMatched) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const EditProfileScreen()),
                );
              } else {
                ScaffoldMessenger.of(widget.scaffoldContext)
                    .hideCurrentSnackBar();

                ScaffoldMessenger.of(widget.scaffoldContext).showSnackBar(
                  const SnackBar(
                    content: Text('Sai mật khẩu!'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 5),
                  ),
                );
              }
            }
          },
        ),
      ],
    );
  }
}
