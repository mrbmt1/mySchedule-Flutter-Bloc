import 'package:flutter/material.dart';
import 'package:myschedule/views/screens/school_schedule/sat_school_schedule.dart';
import 'package:myschedule/views/screens/school_schedule/sun_school_schedule.dart';
import 'package:myschedule/views/screens/school_schedule/thu_school_schedule.dart';
import 'package:myschedule/views/screens/school_schedule/tue_school_schedule.dart';
import 'package:myschedule/views/screens/school_schedule/wed_school_schedule.dart';
import 'fri_school_schedule.dart';
import 'mon_school_schedule.dart';

class SchoolScheduleNavigator extends StatefulWidget {
  const SchoolScheduleNavigator({Key? key}) : super(key: key);

  @override
  SchoolScheduleNavigatorState createState() => SchoolScheduleNavigatorState();
}

class SchoolScheduleNavigatorState extends State<SchoolScheduleNavigator> {
  int _currentIndex = DateTime.now().weekday - 1;
  final PageController _pageController =
      PageController(initialPage: DateTime.now().weekday - 1);

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (details.primaryVelocity! > 0) {
      // Quẹt sang phải
      _pageController.previousPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else if (details.primaryVelocity! < 0) {
      // Quẹt sang trái
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  final List<Widget> _children = [
    const MonDayScheduleScreen(),
    const TuesDayScheduleScreen(),
    const WednesDayScheduleScreen(),
    const ThursDayScheduleScreen(),
    const FriDayScheduleScreen(),
    const SaturDayScheduleScreen(),
    const SunDayScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          physics: const BouncingScrollPhysics(),
          children: _children,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(color: Colors.grey),
        unselectedLabelStyle: const TextStyle(color: Colors.grey),
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.looks_two_rounded,
              color: Colors.grey,
            ),
            label: 'Thứ 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_3_rounded, color: Colors.grey),
            label: 'Thứ 3',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_4_rounded, color: Colors.grey),
            label: 'Thứ 4',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_5_rounded, color: Colors.grey),
            label: 'Thứ 5',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.looks_6_rounded, color: Colors.grey),
            label: 'Thứ 6',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.weekend, color: Colors.grey),
            label: 'Thứ 7',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.weekend, color: Colors.grey),
            label: 'Chủ nhật',
          ),
        ],
      ),
    );
  }
}
