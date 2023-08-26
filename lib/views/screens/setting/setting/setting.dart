import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/setting/setting_bloc.dart';
import 'package:myschedule/blocs/setting/setting_event.dart';
import 'package:myschedule/blocs/setting/setting_state.dart';
import 'package:myschedule/views/screens/login/login.dart';
import 'package:myschedule/views/screens/setting/setting_option/about.dart';
import 'package:myschedule/views/screens/setting/setting_option/change_password.dart';
import 'package:myschedule/views/screens/setting/setting_option/feedback.dart';
import 'package:myschedule/views/screens/setting/setting_option/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final settingBloc = BlocProvider.of<SettingBloc>(context);

    return BlocListener<SettingBloc, SettingState>(
      listener: (context, state) async {
        if (state is SettingSuccess) {
          await Future.delayed(const Duration(milliseconds: 500));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Xóa tài khoản thành công'),
                backgroundColor: Colors.green),
          );
        } else if (state is SettingFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Cài đặt'),
        ),
        body: ListView(
          children: [
            const Divider(),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text('Chế độ tối'),
              trailing: Switch(
                value: themeNotifier.darkTheme,
                onChanged: (value) {
                  themeNotifier.toggleTheme();
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool('darkTheme', value);
                  });
                },
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Đổi mật khẩu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Hỗ trợ và phản hồi'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FeedBackScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Thông tin ứng dụng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutAppScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(
                Icons.person_off_rounded,
                color: Colors.red, // Đổi màu biểu tượng thành màu đỏ
              ),
              title: const Text(
                'Xóa tài khoản',
                style: TextStyle(
                  color: Colors.red, // Đổi màu chữ thành màu đỏ
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text(
                        'Xác nhận xóa!',
                        style: TextStyle(
                          color: Colors.red, // Đổi màu chữ thành màu đỏ
                        ),
                      ),
                      content: const Text(
                        'Bạn có chắc muốn xóa toàn bộ tài liệu trong tài khoản này không? \nSau khi xóa thì không thể khôi phục lại được!',
                        style: TextStyle(
                          color: Colors.red, // Đổi màu chữ thành màu đỏ
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text(
                            'Không',
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop(); // Đóng hộp thoại
                          },
                        ),
                        TextButton(
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              color: Colors.red, // Đổi màu chữ thành màu đỏ
                            ),
                          ),
                          onPressed: () {
                            settingBloc.add(const DeleteAccountButtonPressed());
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
