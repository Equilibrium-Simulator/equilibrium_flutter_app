import 'package:flutter/material.dart';
import 'main.dart';

class ProgressPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: kToolbarHeight + MediaQuery.of(context).padding.top, // Height of the app bar
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
        Container( //for bottom navbar
            height: 70,
            color: Colors.brown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    // Navigate to the Home class in main.dart
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                  child: Icon(
                    Icons.home,
                    color: Colors.white,               
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to the ProgressPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProgressPage()),
                    );
                  },
                  child: Icon(
                    Icons.auto_graph,
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


// import 'dart:convert';
// import 'package:equilibrium/main.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';

// class ProgressPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Equilibrium',
//           style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
//         ),
//         backgroundColor: Colors.brown,
//         centerTitle: true,
//         elevation: 5,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Practice History',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 16),
//             Expanded(
//               child: PracticeHistoryTable(), // Use the PracticeHistoryTable widget here
//             ),
//           ],
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.timeline),
//             label: 'Progress',
//           ),
//         ],
//         selectedItemColor: Colors.brown,
//         onTap: (int index) {
//           if (index == 0) { // Check if the home button is tapped
//             Navigator.popUntil(context, ModalRoute.withName('/')); // Navigate back to the home page
//           } else if (index == 1) { // Check if the progress button is tapped
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => ProgressPage()),
//             );
//           }
//         },
//       ),
//     );
//   }
// }

// class PracticeHistoryManager with WidgetsBindingObserver {
//   static final PracticeHistoryManager _instance = PracticeHistoryManager._internal();

//   factory PracticeHistoryManager() {
//     return _instance;
//   }

//   PracticeHistoryManager._internal();

//   SharedPreferences? _prefs;
//   late List<Map<String, dynamic>> _practiceHistory;
//   late DateTime _sessionStartTime;

//   Future<void> initialize() async {
//     _prefs = await SharedPreferences.getInstance();
//     _practiceHistory = _getPracticeHistoryFromPrefs();
//     _sessionStartTime = DateTime.now();
//     WidgetsBinding.instance?.addObserver(this);
//   }

//   List<Map<String, dynamic>> _getPracticeHistoryFromPrefs() {
//     final practiceHistoryJson = _prefs?.getStringList('practice_history');
//     if (practiceHistoryJson != null) {
//       return practiceHistoryJson.map((json) => Map<String, dynamic>.from(jsonDecode(json))).toList();
//     }
//     return [];
//   }

//   void _savePracticeHistoryToPrefs() {
//     final practiceHistoryJson = _practiceHistory.map((entry) => jsonEncode(entry)).toList();
//     _prefs?.setStringList('practice_history', practiceHistoryJson);
//   }

//   void addPracticeTime() {
//     final sessionDuration = DateTime.now().difference(_sessionStartTime).inMinutes;
//     _sessionStartTime = DateTime.now();
//     final currentDate = DateTime.now().toString().split(' ')[0]; // Get date in YYYY-MM-DD format

//     // Check if there is an entry for the current date, if not, create one
//     final todayEntryIndex = _practiceHistory.indexWhere((entry) => entry['date'] == currentDate);
//     if (todayEntryIndex != -1) {
//       _practiceHistory[todayEntryIndex]['minutes'] += sessionDuration;
//     } else {
//       _practiceHistory.add({'date': currentDate, 'minutes': sessionDuration});
//     }

//     _savePracticeHistoryToPrefs();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused) {
//       addPracticeTime();
//     }
//   }

//   List<Map<String, dynamic>> get practiceHistory => _practiceHistory;
// }

// class PracticeHistoryTable extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final practiceHistory = PracticeHistoryManager().practiceHistory;
//     return DataTable(
//       columns: [
//         DataColumn(label: Text('Date')),
//         DataColumn(label: Text('Minutes')),
//       ],
//       rows: practiceHistory.map((data) {
//         final date = DateFormat('MMM dd, yyyy').format(DateTime.parse(data['date']));
//         return DataRow(
//           cells: [
//             DataCell(Text(date)),
//             DataCell(Text(data['minutes'].toString())),
//           ],
//         );
//       }).toList(),
//     );
//   }
// }

// void main() async {
//   // Initialize the PracticeHistoryManager
//   await PracticeHistoryManager().initialize();
  
//   runApp(Home());
// }