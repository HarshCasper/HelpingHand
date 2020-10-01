import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:helping_hands/currency_detection/currency.dart';
import 'package:helping_hands/image_captioning/image_captioning.dart';
import 'package:helping_hands/ocr/dialog_ocr.dart';
import 'package:helping_hands/sos/sos_dialog.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shake/shake.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'package:tflite/tflite.dart';
import 'package:telephony/telephony.dart';
import 'dart:math' as math;
import 'package:vibration/vibration.dart';

import 'live_labelling/bndbox.dart';
import 'live_labelling/camera.dart';

class HomePage extends StatefulWidget {
  final List<CameraDescription> cameras;

  HomePage(this.cameras);

  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "SSD MobileNet";
  File _capImage;
  File _currImage;
  final FlutterTts flutterTts = FlutterTts();
  final Telephony telephony = Telephony.instance;

  PageController _controller = PageController(
    initialPage: 0,
  );

  Future getCurrImage() async {
    final currImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _currImage = currImage;
    });
    if (currImage != null) {
      CurrPage.currencyDetect(context, currImage);
    }
  }

  Future getCapImage() async {
    final capImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _capImage = capImage;
    });
    if (capImage != null) {
      imgCap.uploadImg(context, _capImage);
    }
  }

  var sosCount = 0;
  var initTime;

  @override
  Future<void> initState() {
    super.initState();
    smsPermission();
    loadModel();
    ShakeDetector detector = ShakeDetector.waitForStart(onPhoneShake: () {
      if (sosCount == 0) {
        initTime = DateTime.now();
        ++sosCount;
      } else {
        if (DateTime.now().difference(initTime).inSeconds < 4) {
          ++sosCount;
          if (sosCount == 6) {
            sendSms();
            sosCount = 0;
          }
          print(sosCount);
        } else {
          sosCount = 0;
          print(sosCount);
        }
      }
    });

    detector.startListening();
  }

  void sendSms() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String n1 = prefs.getString('n1');
    String n2 = prefs.getString('n2');
    String n3 = prefs.getString('n3');
    String name = prefs.getString('name');
    Position position =
        await getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    if (position == null) {
      position = await getLastKnownPosition();
    }
    String lat = (position.latitude).toString();
    String long = (position.longitude).toString();
    String alt = (position.altitude).toString();
    String speed = (position.speed).toString();
    String timestamp = (position.timestamp).toIso8601String();
    print(n2);
    telephony.sendSms(
        to: n1,
        message:
            "$name needs you help, last seen at: Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
    telephony.sendSms(
        to: n2,
        message:
            "$name needs you help, last seen at:  Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
    telephony.sendSms(
        to: n3,
        message:
            "$name needs you help, last seen at:  Latitude: $lat, Longitude: $long, Altitude: $alt, Speed: $speed, Time: $timestamp");
  }

  void smsPermission() async {
    //bool permissionsGranted = await telephony.requestPhoneAndSmsPermissions;
  }

  loadModel() async {
    String res = await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt");
    print("MODEL" + res);
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    sosDialog sd = new sosDialog();
    ocrDialog od = new ocrDialog();
    return Scaffold(
      body: PageView(
        controller: _controller,
        onPageChanged: _speakPage,
        children: <Widget>[
          Container(
            child: Stack(
              children: [
                Camera(
                  widget.cameras,
                  _model,
                  setRecognitions,
                ),
                BndBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.height,
                    screen.width,
                    _model),
              ],
            ),
          ),
          Container(
              child: Center(
                  child: SizedBox.expand(
                      child: FlatButton(
                          highlightColor: Hexcolor('#A8DEE0'),
                          splashColor: Hexcolor('#F9E2AE'),
                          onPressed: () => getCapImage(),
                          child: Text("Image Captioning",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Hexcolor('6d597a')),
          Container(
              child: Center(
                  child: SizedBox.expand(
                      child: FlatButton(
                          highlightColor: Hexcolor('#A8DEE0'),
                          splashColor: Hexcolor('#F9E2AE'),
                          onPressed: () => od.optionsDialogBox(context),
                          child: Text("Text Extraction from Images",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Hexcolor('b56576')),
          Container(
              child: Center(
                  child: SizedBox.expand(
                      child: FlatButton(
                          highlightColor: Hexcolor('#F9E2E'),
                          splashColor: Hexcolor('#FBC78D'),
                          onPressed: () => getCurrImage(),
                          child: Text("Currency Identifier",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Hexcolor('e56b6f')),
          Container(
              child: Center(
                  child: SizedBox.expand(
                      child: FlatButton(
                          highlightColor: Colors.yellow[900],
                          splashColor: Colors.yellow[500],
                          onPressed: () => sd.sosDialogBox(context),
                          child: Text("SOS Settings",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Hexcolor('eaac8b')),
        ],
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        physics: BouncingScrollPhysics(),
      ),
    );
  }

  _speakPage(int a) async {
    if (a == 0) {
      await flutterTts.speak("Live object detection");
    } else if (a == 1) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 1000);
      }
      await flutterTts.speak("Image Captioning");
    } else if (a == 2) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 1400);
      }
      await flutterTts.speak("Text Extraction from images");
    } else if (a == 3) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 1800);
      }
      await flutterTts.speak("Currency Identifier");
    } else if (a == 4) {
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(amplitude: 128, duration: 2200);
      }
      await flutterTts.speak("SOS Settings");
    }
  }
}
