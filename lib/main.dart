import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:myschedule/blocs/birthday_task/create_birthday/create_birthday_bloc.dart';
import 'package:myschedule/blocs/birthday_task/edit_birthday/edit_birthday_bloc.dart';
import 'package:myschedule/blocs/forgot_password/forgot_password/forgot_password_bloc.dart';
import 'package:myschedule/blocs/forgot_password/set_new_password/set_new_password_bloc.dart';
import 'package:myschedule/blocs/login/login_bloc.dart';
import 'package:myschedule/blocs/profile/profile_bloc.dart';
import 'package:myschedule/blocs/register/register_bloc.dart';
import 'package:myschedule/blocs/setting/setting_bloc.dart';
import 'package:myschedule/blocs/task/create_task/create_task_bloc.dart';
import 'package:myschedule/blocs/task/edit_task/edit_task_bloc.dart';
import 'package:myschedule/views/screens/login/login.dart';
import 'package:myschedule/views/screens/setting/setting_option/theme.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'blocs/school_schedule/school_schedule_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  await createNotificationChannel();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeNotifier>(
          create: (_) => ThemeNotifier(),
        ),
        BlocProvider(
          create: (_) => LoginBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => SettingBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => RegisterBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => ForgotPasswordBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => SetNewPasswordBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => SchoolScheduleBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => ProfileBloc(FirebaseAuth.instance),
        ),
        BlocProvider(
          create: (_) => CreateTaskBloc(),
        ),
        BlocProvider(
          create: (_) => EditTaskBloc(),
        ),
        BlocProvider(
          create: (_) => CreateBirthDayTaskBloc(),
        ),
        BlocProvider(
          create: (_) => EditBirthDayTaskBloc(),
        ),
      ],
      child: const ThemeConfiguration(
        child: MainApp(),
      ),
    ),
  );
}

Future<void> createNotificationChannel() async {
  await AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'channel_key',
        channelName: 'Channel Name',
        channelDescription: 'Channel Description',
        defaultColor: Colors.white,
        ledColor: Colors.white,
      ),
    ],
  );
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ThemeConfiguration(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        themeMode: themeNotifier.darkTheme ? ThemeMode.dark : ThemeMode.light,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/ic_launcher.png',
              width: 250.0,
              height: 250.0,
            ),
            const SizedBox(height: 5),
            Text(
              'My Schedule',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 0),
                    blurRadius: 18.0,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
