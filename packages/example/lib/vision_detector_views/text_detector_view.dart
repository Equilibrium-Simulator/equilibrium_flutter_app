import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:audioplayers/audioplayers.dart';


import 'detector_view.dart';
import 'painters/text_detector_painter.dart';

class TextRecognizerView extends StatefulWidget {
  int _equiAnalysisType = 0;

  TextRecognizerView(int equiAnalysisType) {
    this._equiAnalysisType = equiAnalysisType;
  }

  @override
  State<TextRecognizerView> createState() => _TextRecognizerViewState(_equiAnalysisType);
}

class _TextRecognizerViewState extends State<TextRecognizerView> {
  static const int ACTION_SHOULDER_HIP_HEEL_ALIGN = 0;
  static const int ACTION_STEADY_SHOULDER = 1;                      //No motion on X or Y axis
  static const int ACTION_STEADY_HANDS = 2;                         //No motion on X or Y axis
  static const int ACTION_HEELS_DOWN = 3;                           //No motion on X or Y axis
  static const int ACTION_LEFT_RIGHT_SHOULDER_ALIGN = 4;            //Shoulders need to be aligned and on same Y axis
  static const int ACTION_TOES_FORWARD = 5;                          //No motion
  static const int ACTION_FOLLOWING_SEAT = 6;                        //Only X axis motion should be present, no Y axis motion
  static const int ACTION_MAX = 7;
  static const int DETECT_ERROR = 100;

  static const int AUDIO_STEADY_SHOULDER = 101;                      
  static const int AUDIO_STEADY_HANDS = 102;                         
  static const int AUDIO_LEFT_SHOULDER_HIGH = 103;
  static const int AUDIO_RIGHT_SHOULDER_HIGH = 104;
  static const int AUDIO_HIPS_LOW = 105;

  //Amount of displacement allowed on x or y axis for each of the above action-types
  final List<int> X_ALLOWED_DISP = [2, 1, 2, 1, 100, 2, 100];
  final List<int> Y_ALLOWED_DISP = [2, 1, 2, 1, 1,   2, 1];

  var _script = TextRecognitionScript.latin;
  var _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  var _cameraLensDirection = CameraLensDirection.back;
  int _equiAnalysisType = 0;

  _TextRecognizerViewState(int equiAnalysisType) {
    this._equiAnalysisType = equiAnalysisType;
  }

  @override
  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        DetectorView(
          title: 'Equilibrium',
          customPaint: _customPaint,
          text: _text,
          onImage: _processImage,
          initialCameraLensDirection: _cameraLensDirection,
          onCameraLensDirectionChanged: (value) => _cameraLensDirection = value,
        ),
      ]),
    );
  }

  var lastPlayedDate = DateTime.now();
  int boundBoxWidthX = 0;
  int boundBoxHeightY = 0;
  static const int HYSTERESIS_SAMPLE = 10;
  static const int HYSTERESIS_TIME = 1;

  final steadyX = List<int>.filled(HYSTERESIS_SAMPLE, 0, growable: true); // [0, 0, 0]
  final steadyY = List<int>.filled(HYSTERESIS_SAMPLE, 0, growable: true); // [0, 0, 0]


  void _playAudio (int whichAudio) async {

    int secondsDifference = lastPlayedDate.difference(DateTime.now()).inSeconds;
    if (secondsDifference.abs() > HYSTERESIS_TIME) {
      lastPlayedDate = DateTime.now();
      final player = AudioPlayer();

      switch(whichAudio) {
        case AUDIO_STEADY_HANDS:
          await player.play(AssetSource('audio/steady_hands.wav'));
          break;
        case AUDIO_STEADY_SHOULDER:
          await player.play(AssetSource('audio/steady_shoulders.wav'));
          break;
        case AUDIO_HIPS_LOW:
          await player.play(AssetSource('audio/hips_low.wav'));
          break;          
        case AUDIO_LEFT_SHOULDER_HIGH:
          await player.play(AssetSource('audio/lower_left_shoulder.wav'));
          break;          
        case AUDIO_RIGHT_SHOULDER_HIGH:
          await player.play(AssetSource('audio/lower_right_shoulder.wav'));
          break;
        default:
          break;
      }
    }
  }

  void _processSteady (int X, int Y) {
    steadyX.add(X);
    steadyX.removeAt(0);
    steadyY.add(Y);
    steadyY.removeAt(0);

    List<int> tempX = List.from(steadyX);
    tempX.sort((a, b) => a.compareTo(b));
    List<int> tempY = List.from(steadyY);
    tempY.sort((a, b) => a.compareTo(b));

    if(tempX[0] == 0 || tempY[0] == 0) {
      //Not yet initialized completely, do not do anything here
    } else {
      if ((tempX[HYSTERESIS_SAMPLE-2] - tempX[1] > (boundBoxWidthX *X_ALLOWED_DISP[_equiAnalysisType]) )  ||
          (tempY[HYSTERESIS_SAMPLE-2] - tempY[1] > (boundBoxHeightY*Y_ALLOWED_DISP[_equiAnalysisType])) ){
        //too much hand or shoulder motion.  not good for horses mouth
        switch(_equiAnalysisType) {
          case ACTION_STEADY_HANDS:
            _playAudio(AUDIO_STEADY_HANDS);
            break;
          case ACTION_STEADY_SHOULDER:
            _playAudio(AUDIO_STEADY_SHOULDER);
            break;
          case ACTION_FOLLOWING_SEAT:
            _playAudio(AUDIO_HIPS_LOW);
            break;
          default:
            break;
        }
      }
    }
  }

  void _processAlignedAxis (int x1, int y1, int x2, int y2) { 
    if((x1 - x2).abs() > (boundBoxWidthX * X_ALLOWED_DISP[_equiAnalysisType]) ||
       (y1 - y2).abs() > (boundBoxHeightY *Y_ALLOWED_DISP[_equiAnalysisType])){
      int leftY=0, rightY=0;
      //default assume x1,y1 is right, x2,y2 is left
      rightY = y1; leftY = y2;
      //if x2 is closer to 0, then swap rightY and leftY
      if(x2 < x1) {
        rightY = y2; leftY = y1;
      }
      if(rightY > leftY) {
          _playAudio(AUDIO_LEFT_SHOULDER_HIGH);
      } else {
          _playAudio(AUDIO_RIGHT_SHOULDER_HIGH);
      }
    }
  }

  void _processRiderPosition(RecognizedText recognizedText) {

    switch(_equiAnalysisType) {
      case ACTION_STEADY_HANDS:
      case ACTION_STEADY_SHOULDER:
      case ACTION_FOLLOWING_SEAT:
        if(! (recognizedText.blocks.length  == 1 && (recognizedText.text == 'X' || recognizedText.text == 'x'))) {
          return;
        }

        //x, y are swapped here are we are in portrait mode, so we need to account for a rotation of 90 degrees
        //coo-ordinate system is
        //640,0   -----------------------------0,0
        //        -----------------------------
        //640,480------------------------------0,480
        int xDiff = (recognizedText.blocks[0].cornerPoints[0].y - recognizedText.blocks[0].cornerPoints[2].y).abs();
        int yDiff = (recognizedText.blocks[0].cornerPoints[0].x - recognizedText.blocks[0].cornerPoints[2].x).abs();

        if(boundBoxWidthX == 0 || (boundBoxWidthX < xDiff)) {
          boundBoxWidthX = xDiff;
        }
        if(boundBoxHeightY == 0 || (boundBoxHeightY < yDiff)) {
          boundBoxHeightY = yDiff;
        }
        _processSteady(recognizedText.blocks[0].cornerPoints[0].y, recognizedText.blocks[0].cornerPoints[0].x);
        break;
      case ACTION_LEFT_RIGHT_SHOULDER_ALIGN:
        if(!(recognizedText.blocks.length  == 2 && (recognizedText.text == 'X\nX' || recognizedText.text == 'x\nX' ||
                                                    recognizedText.text == 'X\nx'))) {
          return;
        }
        //x, y are swapped here are we are in portrait mode, so we need to account for a rotation of 90 degrees
        boundBoxWidthX = (recognizedText.blocks[0].cornerPoints[0].y - recognizedText.blocks[0].cornerPoints[2].y).abs();
        boundBoxHeightY = (recognizedText.blocks[0].cornerPoints[0].x - recognizedText.blocks[0].cornerPoints[2].x).abs();

        _processAlignedAxis(recognizedText.blocks[0].cornerPoints[0].y, recognizedText.blocks[0].cornerPoints[0].x,
              recognizedText.blocks[1].cornerPoints[0].y, recognizedText.blocks[1].cornerPoints[0].x);
        break;
      default:
        break;
    }
  }


  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    setState(() {
      _text = '';
    });

    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {

      _processRiderPosition(recognizedText);

      final painter = TextRecognizerPainter(
        recognizedText,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _customPaint = CustomPaint(painter: painter);

    } else {
      _text = 'Recognized text:\n\n${recognizedText.text}';
      // TODO: set _customPaint to draw boundingRect on top of image
      _customPaint = null;
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }
}
