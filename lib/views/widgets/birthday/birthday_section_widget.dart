import 'package:flutter/material.dart';
import 'package:myschedule/models/birthday_item.dart';
import 'package:myschedule/views/screens/birthday_task/birthday_widget.dart';

Widget buildBirthDaySection(
    BuildContext context, String title, List<BirthDayItem> birthdayList) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.all(13.0),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: birthdayList.length,
        itemBuilder: (context, index) {
          BirthDayItem birthayItem = birthdayList[index];
          return BirthDayWidget(birthdayTodo: birthayItem);
        },
      ),
    ],
  );
}
