import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/setting/setting_bloc.dart';
import 'package:myschedule/blocs/setting/setting_event.dart';
import 'package:myschedule/blocs/setting/setting_state.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({Key? key}) : super(key: key);

  @override
  AboutAppScreenState createState() => AboutAppScreenState();
}

class AboutAppScreenState extends State<AboutAppScreen> {
  String appVersion = '';

  @override
  void initState() {
    super.initState();
    context.read<SettingBloc>().add(const LoadAppVersionEvent());
  }

  @override
  Widget build(BuildContext context) {
    final settingBloc = BlocProvider.of<SettingBloc>(context);
    return BlocListener<SettingBloc, SettingState>(
      listener: (context, state) {},
      child: BlocBuilder<SettingBloc, SettingState>(
        builder: (context, state) {
          if (state is LoadAppVersionState) {
            appVersion = state.appVersion;
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Thông tin ứng dụng'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tên ứng dụng:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  const Text('MySchedule', style: TextStyle(fontSize: 16.0)),
                  const SizedBox(height: 16.0),
                  const Text('Chức năng',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  const Text(
                      'Ứng dụng được tạo ra để hỗ trợ người trong việc lập lịch biểu và chia sẻ thời khóa biểu',
                      style: TextStyle(fontSize: 16.0)),
                  const SizedBox(height: 16.0),
                  const Text('Phiên bản:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  Text(appVersion, style: const TextStyle(fontSize: 16.0)),
                  const SizedBox(height: 16.0),
                  const Text('Ngày phát hành:',
                      style: TextStyle(
                          fontSize: 18.0, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8.0),
                  const Text('07/2023', style: TextStyle(fontSize: 16.0)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
