import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myschedule/blocs/login/login_event.dart';
import 'package:myschedule/blocs/login/login_state.dart';
import 'package:myschedule/utils/login/email_check.dart';
import 'package:myschedule/utils/login/remember_me.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool viewTimer = false;
  bool viewAuthenticationFail = false;
  int countdownSeconds = 60;
  Timer? timer;
  String errorMessage = '';
  bool rememberMe = false;

  LoginBloc(this._firebaseAuth) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<GoogleLoginButtonPressed>(_onGoogleLoginButtonPressed);
    on<FacebookLoginButtonPressed>(_onFacebookLoginButtonPressed);
    on<PhoneNumberLoginButtonPressed>(_onPhoneNumberLoginButtonPressed);
  }

  void _onLoginButtonPressed(
      LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginInitial());

    if (event.username.isEmpty || event.password.isEmpty) {
      emit(const LoginFailure(
          error: 'Vui lòng nhập đầy đủ thông tin đăng nhập'));
    } else {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('username', isEqualTo: event.username.trim())
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final user = userDoc.data();
          final passwordHash =
              sha256.convert(utf8.encode(event.password.trim())).toString();
          if (event.rememberMe) {
            await saveLoginStatus(true);
          }

          if (user['password'] == passwordHash) {
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: user['email'],
              password: event.password.trim(),
            );
            final loggedInUser = userCredential.user!;

            emit(LoginSuccess(loggedInUser));
            if (event.rememberMe) {
              await saveLoginStatus(true);
            }
            // emit(LoginSuccess());
          } else {
            emit(const LoginFailure(error: 'Sai mật khẩu'));
          }
        } else {
          emit(const LoginFailure(error: 'Tài khoản không tồn tại'));
        }
      } catch (e) {
        emit(const LoginFailure(error: 'Đăng nhập thất bại'));
      }
    }
  }

  void _onGoogleLoginButtonPressed(
      GoogleLoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginInitial());

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
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
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
            emit(const LoginFailure(error: 'Tài khoản đã tồn tại'));

            return;
          }

          // Đăng nhập thành công bằng tài khoản Google đã đăng ký trước đó
          final loggedInUser = userCredential.user!;

          emit(LoginSuccess(loggedInUser));

          // Lưu trạng thái đăng nhập nếu người dùng đã chọn "Lưu đăng nhập"
          if (event.rememberMe) {
            await saveLoginStatus(true);
          }
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

          emit(RegisterSuccess());

          if (event.rememberMe) {
            await saveLoginStatus(true);
          }
        }
      }
    } catch (e) {
      // print(e);
      emit(const LoginFailure(error: 'Đăng nhập bằng google thất bại'));
    }
  }

  void _onFacebookLoginButtonPressed(
      FacebookLoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginInitial());

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
            final loggedInUser = userCredential.user!;

            emit(LoginSuccess(loggedInUser));

            // Lưu trạng thái đăng nhập nếu người dùng đã chọn "Lưu đăng nhập"
            if (event.rememberMe) {
              await saveLoginStatus(true);
            }

            // Chuyển hướng đến màn hình TodoListScreen sau khi đăng nhập/đăng ký thành công
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
            emit(RegisterSuccess());

            if (event.rememberMe) {
              await saveLoginStatus(true);
            }
          }
        }
      } else if (loginResult.status == LoginStatus.cancelled) {
        // Người dùng hủy đăng nhập
        emit(const LoginFailure(error: 'Đăng nhập bằng Facebook bị hủy'));
      } else {
        // Đăng nhập thất bại
        emit(const LoginFailure(error: 'Đăng nhập bằng Facebook thất bại'));
      }
    } catch (e) {
      // Xử lý các lỗi xảy ra trong quá trình đăng nhập
      // print('Đăng nhập bằng Facebook thất bại: $e');
      emit(const LoginFailure(error: 'Đăng nhập bằng Facebook thất bại'));
    }
  }

  Future<void> _onPhoneNumberLoginButtonPressed(
      PhoneNumberLoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginInitial());

    final String phoneNumber = event.phoneNumber;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
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
                  emit(LoginSuccess(user));
                } else {
                  emit(const LoginFailure(
                      error: "Số điện thoại đã được đăng ký bởi người khác"));
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

                emit(RegisterSuccess());
                timer?.cancel();
              }
            }
          } catch (e) {
            // Bỏ qua việc xử lý lỗi đăng nhập nếu cần
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = e.code;
          emit(LoginDialogFailure(errorMessage: errorMessage));
          viewTimer = false;
          viewAuthenticationFail = true;
          timer?.cancel();
          if (e.code == 'invalid-phone-number') {
            errorMessage =
                'Số điện thoại sai hoặc không đúng định dạng, vui lòng kiểm tra lại';
          } else if (e.code == 'too-many-requests') {
            errorMessage =
                'Số điện thoại đã bị chặn gửi tin nhắn xác thực do gửi quá nhiều yêu cầu trong ngày, vui lòng sử dụng chức năng này trong ngày mai.';
          } else {
            errorMessage = 'Có lỗi xảy ra trong quá trình xác thực';
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationId = verificationId;
          viewTimer = false;
          timer?.cancel();
        },
      );
    } catch (e) {
      // Bỏ qua việc xử lý lỗi chung nếu cần
    }
  }
}
