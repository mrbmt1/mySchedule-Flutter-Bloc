import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_bloc.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_event.dart';
import 'package:myschedule/blocs/school_schedule/school_schedule_state.dart';
import 'package:myschedule/utils/school_schedule/share_schedule.dart';

class ShareScreen extends StatefulWidget {
  const ShareScreen({Key? key}) : super(key: key);

  @override
  ShareScreenState createState() => ShareScreenState();
}

class ShareScreenState extends State<ShareScreen> {
  List<String> sharedUsers = [];
  TextEditingController searchController = TextEditingController();
  List<String> suggestions = [];

  @override
  void initState() {
    super.initState();
    context.read<SchoolScheduleBloc>().add(LoadSharedUserEvent());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void onSuggestionTapped(String suggestion) {
    setState(() {
      sharedUsers.add(suggestion);
      searchController.clear();
      suggestions = [];
    });
  }

  void removeSharedUser(String user) {
    setState(() {
      sharedUsers.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    final schoolScheduleBloc = BlocProvider.of<SchoolScheduleBloc>(context);

    return BlocListener<SchoolScheduleBloc, SchoolScheduleState>(
        listener: (context, state) {},
        child: BlocBuilder<SchoolScheduleBloc, SchoolScheduleState>(
            builder: (context, state) {
          if (state is LoadSharedUserState) {
            sharedUsers = state.sharedUsers;
          } else if (state is SearchSuggestionsLoaded) {
            suggestions = state.suggestions;
          }
          final isListEmpty = sharedUsers.isEmpty;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Chia sẻ thời khóa biểu với'),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText: 'Nhập tài khoản hoặc email bạn muốn chia sẻ',
                      ),
                      onChanged: (value) {
                        schoolScheduleBloc.add(SearchValueChanged(
                            value: value, sharedUsers: sharedUsers));
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Danh sách người được chia sẻ:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    isListEmpty
                        ? const Text(
                            'Danh sách trống.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : Column(
                            children: sharedUsers.map((user) {
                              return ListTile(
                                title: Text(user),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    removeSharedUser(user);
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                    const Text('Gợi ý:'),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          title: Text(suggestion),
                          onTap: () {
                            onSuggestionTapped(suggestion);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.share),
              onPressed: () async {
                await shareSchedule(context, sharedUsers);
              },
            ),
          );
        }));
  }
}
