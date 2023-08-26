import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoginStatus(bool rememberMe) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (!rememberMe) {
    await prefs.remove('rememberMe');
  } else {
    await prefs.setBool('rememberMe', true);
  }
}
