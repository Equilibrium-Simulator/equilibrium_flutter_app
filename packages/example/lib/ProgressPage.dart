// progress_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'PracticeHistoryManager.dart';
import 'main.dart';

class ProgressPage extends StatefulWidget {
  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late Map<DateTime, List<int>> _practiceEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadPracticeEvents();
  }

  void _loadPracticeEvents() {
    final practiceHistory = PracticeHistoryManager().practiceHistory;
    _practiceEvents = {};

    for (var entry in practiceHistory) {
      final date = DateTime.parse(entry['date']);
      final minutes = entry['minutes'];

      if (_practiceEvents[date] != null) {
        _practiceEvents[date]!.add(minutes);
      } else {
        _practiceEvents[date] = [minutes];
      }
    }

    print('Loaded practice events: $_practiceEvents');
  }

  List<int> _getEventsForDay(DateTime day) {
    return _practiceEvents[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top,
            color: Colors.brown,
            child: Center(
              child: Text(
                'Progress',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 25,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: _getEventsForDay,
                    calendarStyle: CalendarStyle(
                      markersAlignment: Alignment.bottomCenter,
                      markersMaxCount: 1,
                      markerSize: 5.0,
                      markerDecoration: BoxDecoration(
                        color: Colors.brown,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  if (_selectedDay != null)
                    ..._getEventsForDay(_selectedDay!).map((event) => ListTile(
                          title: Text('Minutes practiced: $event'),
                        )),
                ],
              ),
            ),
          ),
          Container(
            height: 70,
            color: Colors.brown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                  child: Icon(
                    Icons.home,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => ProgressPage()),
                    );
                  },
                  child: Icon(
                    Icons.calendar_month,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
