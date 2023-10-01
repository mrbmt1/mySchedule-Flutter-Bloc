import 'package:flutter/material.dart';
import 'package:myschedule/views/screens/birthday_task/birthdaylist.dart';
import 'package:myschedule/views/screens/profile/profile.dart';
import 'package:myschedule/views/screens/school_schedule/school_schedule_navigator%20.dart';
import 'package:myschedule/views/screens/setting/setting/setting.dart';
import 'package:myschedule/views/widgets/task/to_do_task_widget/log_out.dart';

Widget todoTaskDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(),
          child: Text('Menu'),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Thông tin người dùng'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserProfileScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.list_alt),
          title: const Text('Thời khóa biểu'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SchoolScheduleNavigator()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.cake),
          title: const Text('Sinh nhật'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BirthdayScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('Cài đặt'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Đăng xuất'),
          onTap: () {
            logout(context);
          },
        ),
      ],
    ),
  );
}
