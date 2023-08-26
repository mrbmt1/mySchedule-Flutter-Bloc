import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_bloc.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_state.dart';

class SnackBarMessageWidget extends StatelessWidget {
  final String successMessage;
  final String errorMessage;

  const SnackBarMessageWidget({
    Key? key,
    required this.successMessage,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchoolScheduleBloc, SchoolScheduleState>(
      listener: (context, state) {
        if (state is SchoolScheduleSuccess) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is SchoolScheduleFailure) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(), // or any other widget you want to wrap with listener
    );
  }
}
