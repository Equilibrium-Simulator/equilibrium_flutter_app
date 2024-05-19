// practice_history_manager.dart

import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PracticeHistoryManager with WidgetsBindingObserver {
  static final PracticeHistoryManager _instance = PracticeHistoryManager._internal();

  factory PracticeHistoryManager() {
    return _instance;
  }

  PracticeHistoryManager._internal();

  SharedPreferences? _prefs;
  late List<Map<String, dynamic>> _practiceHistory;
  late DateTime _sessionStartTime;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _practiceHistory = _getPracticeHistoryFromPrefs();
    _sessionStartTime = DateTime.now();
    WidgetsBinding.instance.addObserver(this);
  }

  List<Map<String, dynamic>> _getPracticeHistoryFromPrefs() {
    final practiceHistoryJson = _prefs?.getStringList('practice_history');
    if (practiceHistoryJson != null) {
      return practiceHistoryJson.map((json) => Map<String, dynamic>.from(jsonDecode(json))).toList();
    }
    return [];
  }

  void _savePracticeHistoryToPrefs() {
    final practiceHistoryJson = _practiceHistory.map((entry) => jsonEncode(entry)).toList();
    _prefs?.setStringList('practice_history', practiceHistoryJson);
  }

  void addPracticeTime() {
    final sessionDuration = DateTime.now().difference(_sessionStartTime).inMinutes;
    _sessionStartTime = DateTime.now();
    final currentDate = DateTime.now().toString().split(' ')[0];

    final todayEntryIndex = _practiceHistory.indexWhere((entry) => entry['date'] == currentDate);
    if (todayEntryIndex != -1) {
      _practiceHistory[todayEntryIndex]['minutes'] += sessionDuration;
    } else {
      _practiceHistory.add({'date': currentDate, 'minutes': sessionDuration});
    }

    _savePracticeHistoryToPrefs();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      addPracticeTime();
    }
  }

  List<Map<String, dynamic>> get practiceHistory => _practiceHistory;
}
