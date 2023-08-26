import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_bloc.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_event.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_state.dart';
import 'package:myschedule/utils/school_schedule/day_schedule_utils.dart';
import 'package:myschedule/views/screens/school_schedule/share_schedule_screen.dart';
import 'package:myschedule/views/widgets/school_schedule_widgets/day_of_week.dart';
import 'package:myschedule/views/widgets/school_schedule_widgets/subject_row_widget.dart';

class TuesDayScheduleScreen extends StatefulWidget {
  const TuesDayScheduleScreen({Key? key}) : super(key: key);

  @override
  TuesDayScheduleScreenState createState() => TuesDayScheduleScreenState();
}

class TuesDayScheduleScreenState extends State<TuesDayScheduleScreen> {
  final _subjectControllers =
      List.generate(12, (index) => TextEditingController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadDataForDay('tuesday', _subjectControllers);
  }

  @override
  Widget build(BuildContext context) {
    final schoolScheduleBloc = BlocProvider.of<SchoolScheduleBloc>(context);

    return BlocListener<SchoolScheduleBloc, SchoolScheduleState>(
      listener: (context, state) {
        if (state is SchoolScheduleSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cập nhật thành công thời khóa biểu thứ ba'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SchoolScheduleFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Thời khóa biểu'),
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt),
              onPressed: () {
                const day = 'tuesday';
                final scaffoldKey = _scaffoldKey;

                schoolScheduleBloc.add(ShowSharedSchedulesDialogButtonPressed(
                    context: context,
                    day: day,
                    subjectControllers: _subjectControllers,
                    scaffoldKey: scaffoldKey));
              },
            ),
            IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShareScreen(),
                    ),
                  );
                }),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: GestureDetector(
            child: ListView(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DayOfWeekText(
                      dayName: 'Thứ 3',
                      isToday: DateFormat('EEEE').format(DateTime.now()) ==
                          'Tuesday',
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text(
                  'Sáng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                for (var i = 0; i < 5; i++)
                  SubjectRowWidget(
                    label: 'Tiết ${i + 1}',
                    controller: _subjectControllers[i],
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Chiều',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                for (var i = 5; i < 10; i++)
                  SubjectRowWidget(
                    label: 'Tiết ${i + 1}',
                    controller: _subjectControllers[i],
                  ),
                const SizedBox(height: 20),
                const Text(
                  'Tối',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                for (var i = 10; i < 12; i++)
                  SubjectRowWidget(
                    label: 'Tiết ${i + 1}',
                    controller: _subjectControllers[i],
                  ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            const day = 'tuesday';
            schoolScheduleBloc.add(UpdateScheduleButtonPressed(
                day: day, subjectControllers: _subjectControllers));
          },
          child: const Icon(Icons.save_as_rounded),
        ),
      ),
    );
  }
}
