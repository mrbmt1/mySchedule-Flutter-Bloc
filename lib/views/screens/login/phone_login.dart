import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/login/login_bloc.dart';
import 'package:myschedule/blocs/login/login_state.dart';
import 'package:myschedule/views/screens/task/todotask.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  PhoneLoginScreenState createState() => PhoneLoginScreenState();
}

class PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneNumberController =
      TextEditingController(text: '+84');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _viewTimer = false;
  bool _viewAuthenticationFail = false;
  int _countdownSeconds = 60;
  Timer? _timer;
  String _errorMessage = '';
  String _verificationId = "";

  @override
  Widget build(BuildContext context) {
    final loginBloc = BlocProvider.of<LoginBloc>(context);
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TodoListScreen()),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Đăng nhập thành công'),
                backgroundColor: Colors.green),
          );
          ;
        } else if (state is LoginFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error), backgroundColor: Colors.red));
        } else if (state is RegisterSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TodoListScreen()),
          );
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Đăng ký thành công'),
                backgroundColor: Colors.green),
          );
          ;
        } else if (state is LoginDialogFailure) {
          print("Error Message: ${state.errorMessage}");
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Lỗi'),
                content: Text(state.errorMessage),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Đóng'),
                  ),
                ],
              );
            },
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Đăng nhập bằng số điện thoại'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại dạng +84 xxx xxx xxx',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    // final phoneNumber = _phoneNumberController.text;
                    // loginBloc.add(PhoneNumberLoginButtonPressed(
                    //     phoneNumber: phoneNumber));
                    final String phoneNumber =
                        _phoneNumberController.text.trim();

                    try {
                      await _auth.verifyPhoneNumber(
                        phoneNumber: phoneNumber,
                        verificationCompleted:
                            (PhoneAuthCredential credential) async {
                          try {
                            final UserCredential userCredential =
                                await FirebaseAuth.instance
                                    .signInWithCredential(credential);
                            final User? user = userCredential.user;

                            if (user != null) {
                              final phone = user.phoneNumber;
                              final uid = user.uid;

                              final userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(uid)
                                  .get();

                              if (userDoc.exists) {
                                final role = userDoc.data()?['role'];

                                if (role == 'phone') {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text('Đăng nhập thành công'),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 5),
                                  ));
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TodoListScreen()),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Số điện thoại đã được đăng ký bởi người khác'),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 5),
                                  ));
                                }
                              } else {
                                final username = phone;
                                final userData = {
                                  'username': username,
                                  'phone': phone,
                                  'role': 'phone',
                                  'avatarURL': '',
                                  'fullName': phone,
                                };

                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(uid)
                                    .set(userData);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Đăng ký thành công'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 5),
                                ));

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const TodoListScreen()),
                                );
                                _timer?.cancel();
                              }
                            }
                          } catch (e) {
                            // Bỏ qua việc xử lý lỗi đăng nhập nếu cần
                          }
                        },
                        verificationFailed: (FirebaseAuthException e) {
                          // Xử lý khi xác nhận số điện thoại thất bại
                          // print('Xác nhận số điện thoại thất bại: ${e.message}');
                          setState(() {
                            _viewTimer = false;
                            _viewAuthenticationFail = true;
                            _timer?.cancel();
                            if (e.code == 'invalid-phone-number') {
                              _errorMessage =
                                  'Số điện thoại sai hoặc không đúng định dạng, vui lòng kiểm tra lại';
                            } else if (e.code == 'too-many-requests') {
                              _errorMessage =
                                  'Số điện thoại đã bị chặn gửi tin nhắn xác thực do gửi quá nhiều yêu cầu trong ngày, vui lòng sử dụng chức năng này trong ngày mai.';
                            } else {
                              _errorMessage =
                                  'Có lỗi xảy ra trong quá trình xác thực';
                            }
                          });
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Lỗi'),
                                content: Text(_errorMessage),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        codeSent: (String verificationId, int? resendToken) {
                          // Lưu verificationId để sử dụng khi người dùng nhập mã xác nhận
                          setState(() {
                            _verificationId = verificationId;
                          });
                        },
                        codeAutoRetrievalTimeout: (String verificationId) {
                          // Xử lý khi hết thời gian chờ tự động lấy mã xác nhận
                          // print('Hết thời gian chờ lấy mã xác nhận.');
                          setState(() {
                            _verificationId = verificationId;
                            _viewTimer = false;
                            _timer?.cancel();
                          });
                        },
                      );
                    } catch (e) {
                      // Bỏ qua việc xử lý lỗi chung nếu cần
                    }
                  },
                  child: const Text('Gửi yêu cầu đăng nhập'),
                ),
                Visibility(
                  visible: _viewTimer,
                  child: Text(
                    'Quá trình đăng nhập tự động sẽ diễn ra khi tin nhắn xác thực được gửi tới, quý khách vui lòng đợi trong vòng $_countdownSeconds giây',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                Visibility(
                  visible: _viewAuthenticationFail,
                  child: const Text(
                    'Đăng nhập bằng số điện thoại không thành công! Đã xảy ra lỗi trong quá trình xác thực',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
