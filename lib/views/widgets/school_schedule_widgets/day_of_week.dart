import 'package:flutter/material.dart';

class DayOfWeekText extends StatelessWidget {
  final String dayName;
  final bool isToday;

  const DayOfWeekText({
    required this.dayName,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          dayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (isToday)
          const Text(
            ' (hôm nay)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
              fontSize: 20,
            ),
          ),
      ],
    );
  }
}
