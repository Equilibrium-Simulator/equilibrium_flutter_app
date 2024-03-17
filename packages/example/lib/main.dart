import 'package:flutter/material.dart';
import 'vision_detector_views/text_detector_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equilibrium'),
        centerTitle: true,
        elevation: 5,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  //ACTION_SHOULDER_HIP_HEEL_ALIGN = 0;
                  //ACTION_STEADY_SHOULDER = 1;                      //No motion on X or Y axis
                  //ACTION_STEADY_HANDS = 2;                         //No motion on X or Y axis
                  //ACTION_HEELS_DOWN = 3;                           //No motion on X or Y axis
                  //ACTION_LEFT_RIGHT_SHOULDER_ALIGN = 4;            //Shoulders need to be aligned and on same Y axis
                  //ACTION_TOES_FORWARD = 5;                          //No motion
                  //ACTION_FOLLOWING_SEAT = 6;                        //Only X axis motion should be present, no Y axis motion
                  //ACTION_MAX = 7;
                  ExpansionTile(
                    title: const Text('Side Camera'),
                    children: [
                      //CustomCard('Shoulder, Hip, Heel Align', TextRecognizerView(0)),
                      CustomCard('Steady Shoulder', TextRecognizerView(1)),
                      CustomCard('Steady Hands', TextRecognizerView(2)),
                      //CustomCard('Heel Down', TextRecognizerView(3)),
                      CustomCard('Walk/Canter: Following Seat', TextRecognizerView(6)),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ExpansionTile(
                    title: const Text('Front/Rear Camera'),
                    children: [
                      CustomCard('Left, Right Shoulder Align', TextRecognizerView(4)),
                      //CustomCard('Toes Forward', TextRecognizerView(5)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final String _label;
  final Widget _viewPage;
  final bool featureCompleted;

  const CustomCard(this._label, this._viewPage, {this.featureCompleted = true});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        tileColor: Theme.of(context).primaryColor,
        title: Text(
          _label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          if (!featureCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    const Text('This feature has not been implemented yet')));
          } else {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => _viewPage));
          }
        },
      ),
    );
  }
}
