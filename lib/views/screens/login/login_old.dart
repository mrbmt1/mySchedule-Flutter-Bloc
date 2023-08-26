import 'package:flutter/material.dart';
import 'package:myschedule/views/screens/login/phone_login.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import '../forgot_password/forgot_password.dart';
import '../register/register.dart';
import '../task/todotask.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  // final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  User? _currentUser;
  bool rememberMe = false;
  bool _obscureText = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _saveLoginStatus(bool rememberMe) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!rememberMe) {
      await prefs.remove('rememberMe');
    } else {
      await prefs.setBool('rememberMe', true);
    }
  }

  @override
  void initState() {
    super.initState();
    _readLoginStatus();
  }

  Future<bool> isEmailUsed(String email) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // Đảm bảo đăng xuất khỏi bất kỳ tài khoản Google nào đang đăng nhập trước đó
      await _googleSignIn.signOut();

      // Bắt đầu quá trình đăng nhập bằng Google và đợi người dùng chọn một tài khoản
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();

      // Lấy thông tin xác thực (accessToken và idToken) cho tài khoản Google đã chọn
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;

      // Tạo credential bằng accessToken và idToken từ quá trình đăng nhập Google
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      // Đăng nhập vào Firebase bằng credential đã tạo
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Kiểm tra xem email người dùng đã tồn tại trong ứng dụng hay chưa
        final isEmailUsedResult = await isEmailUsed(user.email!);

        if (isEmailUsedResult) {
          // Email đã tồn tại, kiểm tra vai trò của người dùng
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          final role = userDoc.data()?['role'];

          if (role != 'google') {
            // Tài khoản với cùng email đã tồn tại, nhưng không phải đăng ký bằng Google
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Tài khoản đã tồn tại'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 5),
            ));
            return;
          }

          // Đăng nhập thành công bằng tài khoản Google đã đăng ký trước đó
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Đăng nhập thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ));

          // Lưu trạng thái đăng nhập nếu người dùng đã chọn "Lưu đăng nhập"
          if (rememberMe) {
            await _saveLoginStatus(true);
          }

          // Chuyển hướng đến màn hình TodoListScreen sau khi đăng nhập/đăng ký thành công
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TodoListScreen()),
          );
        } else {
          // Email chưa được sử dụng, tiến hành đăng ký

          // Lấy thông tin người dùng (tên hiển thị, email và uid)
          final username = user.displayName ?? '';
          final email = user.email ?? '';
          final uid = user.uid;

          // Tạo đối tượng userData với các thông tin cần thiết
          final userData = {
            'uid': uid,
            'fullName': username,
            'email': email,
            'role': 'google',
            'username': email,
            'avatarURL': '',
          };

          // Lưu thông tin người dùng vào Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set(userData);

          // Hiển thị thông báo đăng ký thành công
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Đăng ký thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ));

          // Lưu trạng thái đăng nhập nếu người dùng đã chọn "Lưu đăng nhập"
          if (rememberMe) {
            await _saveLoginStatus(true);
          }

          // Chuyển hướng đến màn hình TodoListScreen sau khi đăng nhập/đăng ký thành công
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TodoListScreen()),
          );
        }
      }
    } catch (e) {
      // Xử lý các lỗi xảy ra trong quá trình đăng nhập
      // print('Đăng nhập bằng Google thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đăng nhập bằng Google thất bại'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
    }
  }

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // Trigger the sign-in flow without requesting the 'email' scope
      final LoginResult loginResult =
          await FacebookAuth.instance.login(permissions: ['public_profile']);

      // Kiểm tra xem người dùng đã cấp quyền hay chưa
      if (loginResult.status == LoginStatus.success) {
        final AccessToken? accessToken = loginResult.accessToken;

        // Lấy thông tin người dùng từ Facebook
        final userProfileData = await FacebookAuth.instance.getUserData();

        // Kiểm tra xem email đã được sử dụng hay chưa
        final isEmailUsedResult =
            await isEmailUsed(userProfileData['email'] ?? '');
        if (isEmailUsedResult) {
          // Email đã tồn tại, tiến hành đăng nhập
          final UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCredential(
            FacebookAuthProvider.credential(accessToken!.token),
          );
          final User? user = userCredential.user;

          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Đăng nhập thành công'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ));

            // Lưu trạng thái đăng nhập nếu người dùng đã chọn "Lưu đăng nhập"
            if (rememberMe) {
              await _saveLoginStatus(true);
            }

            // Chuyển hướng đến màn hình TodoListScreen sau khi đăng nhập/đăng ký thành công
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TodoListScreen()),
            );
          }
        } else {
          // Email chưa được sử dụng, tiến hành đăng ký
          final userCredential =
              await FirebaseAuth.instance.signInWithCredential(
            FacebookAuthProvider.credential(accessToken!.token),
          );
          final User? user = userCredential.user;
          final username = userProfileData['name'] ?? '';
          final email = userProfileData['email'] ?? '';
          final uid =
              FirebaseAuth.instance.currentUser?.uid; // Lấy UID từ Firebase

          // Tạo user trong Firestore với dữ liệu từ Facebook và Firebase
          await FirebaseFirestore.instance.collection('users').doc(uid).set({
            'uid': uid,
            'fullName': username,
            'email': email,
            'role': 'facebook',
            'username': uid,
            'avatarURL': '',
          });

          if (user != null) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Đăng ký thành công'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ));

            // Lưu trạng thái đăng nhập nếu người dùng đã chọn "Lưu đăng nhập"
            if (rememberMe) {
              await _saveLoginStatus(true);
            }

            // Chuyển hướng đến màn hình TodoListScreen sau khi đăng nhập/đăng ký thành công
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TodoListScreen()),
            );
          }
        }
      } else if (loginResult.status == LoginStatus.cancelled) {
        // Người dùng hủy đăng nhập
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đăng nhập bằng Facebook đã bị hủy'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ));
      } else {
        // Đăng nhập thất bại
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Đăng nhập bằng Facebook thất bại'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ));
      }
    } catch (e) {
      // Xử lý các lỗi xảy ra trong quá trình đăng nhập
      // print('Đăng nhập bằng Facebook thất bại: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Đăng nhập bằng Facebook thất bại'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ));
    }
  }

  Future<void> _readLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
    });
    if (rememberMe) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TodoListScreen()),
        );
      } else {
        setState(() {
          rememberMe = false;
        });
        await _saveLoginStatus(false);
      }
    }
  }

  void _login(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin đăng nhập'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: _usernameController.text.trim())
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final user = userDoc.data();
          final passwordHash = sha256
              .convert(utf8.encode(_passwordController.text.trim()))
              .toString();
          if (rememberMe) {
            await _saveLoginStatus(true);
          }

          if (user['password'] == passwordHash) {
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: user['email'],
              password: _passwordController.text.trim(),
            );
            setState(() {
              _currentUser = userCredential.user;
            });
            if (rememberMe) {
              await _saveLoginStatus(true);
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TodoListScreen()),
            );
            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
              const SnackBar(
                  content: Text('Đăng nhập thành công'),
                  backgroundColor: Colors.green),
            );
          } else {
            ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
              const SnackBar(
                content: Text('Sai mật khẩu'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
            const SnackBar(
                content: Text('Tài khoản không tồn tại'),
                backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(
          const SnackBar(
              content: Text('Đăng nhập thất bại'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Đăng nhập',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _usernameField(),
                  const SizedBox(height: 20),
                  _passwordField(),
                  const SizedBox(height: 0),
                  _saveLoginStatusCheckbox(),
                  const SizedBox(height: 0),
                  Row(
                    children: [
                      _registerButton(),
                      const SizedBox(width: 10),
                      _loginButton(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _forgotPasswordButton(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _loginWithFacebookButton(),
                      const SizedBox(width: 10),
                      _loginWithGoogleButton(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _loginWithPhoneNumberButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _usernameField() {
    return TextFormField(
      controller: _usernameController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập tài khoản';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: const InputDecoration(
        hintText: 'Tài khoản',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscureText,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập mật khẩu';
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: 'Mật khẩu',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        ),
      ),
    );
  }

  Widget _saveLoginStatusCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Lưu đăng nhập',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        Checkbox(
          value: rememberMe,
          onChanged: (value) {
            setState(() {
              rememberMe = value!;
            });
          },
          activeColor: Colors.blue, // Đổi màu khi Checkbox được chọn
        ),
      ],
    );
  }

  Widget _registerButton() {
    return Expanded(
      child: ElevatedButton(
        child: const Text(
          'Đăng ký',
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        },
      ),
    );
  }

  Widget _loginButton() {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _login(context),
        child: const Text('Đăng nhập', style: TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _forgotPasswordButton() {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
        );
      },
      child: const Text('Quên mật khẩu?'),
    );
  }

  Widget _loginWithFacebookButton() {
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 200, height: 40),
        child: ElevatedButton.icon(
          onPressed: () {
            signInWithFacebook(context);
          },
          icon:
              Image.asset('assets/images/facebook_logo.png', fit: BoxFit.cover),
          label: const Text('Đăng nhập với Facebook'),
        ),
      ),
    );
  }

  Widget _loginWithGoogleButton() {
    return Expanded(
      child: ConstrainedBox(
        constraints: const BoxConstraints.tightFor(width: 200, height: 40),
        child: ElevatedButton.icon(
          onPressed: () {
            signInWithGoogle(context);
          },
          icon: Image.asset('assets/images/google_logo.png', fit: BoxFit.cover),
          label: const Text('Đăng nhập với Google'),
        ),
      ),
    );
  }

  Widget _loginWithPhoneNumberButton() {
    return ConstrainedBox(
      constraints:
          const BoxConstraints.tightFor(width: double.infinity, height: 40),
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PhoneLoginScreen()),
          );
        },
        icon: const Icon(Icons.phone),
        label: const Text('Đăng nhập với số điện thoại'),
      ),
    );
  }
}
