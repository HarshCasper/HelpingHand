import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:helping_hands/currency_detection/currency.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

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
  File _currImage;
  final FlutterTts flutterTts = FlutterTts();

  Future getCurrImage() async {
    final currImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _currImage = currImage;
    });
    if (currImage != null) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => CurrPage(currImage: currImage)));
    }
  }

  @override
  void initState() {
    super.initState();
    loadModel();
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
    return Scaffold(
      body: PageView(
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
                          onPressed: () => _speak(),
                          child: Text("Feature: Image Captioning",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Hexcolor('6d597a')),
          Container(
              child: Center(
                  child: SizedBox.expand(
                      child: FlatButton(
                          highlightColor: Hexcolor('#F9E2E'),
                          splashColor: Hexcolor('#FBC78D'),
                          onPressed: () => getCurrImage(),
                          child: Text("Feature: Currency Identifier",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Hexcolor('b56576')),
          Container(
              child: Center(
                  child: SizedBox.expand(
                      child: FlatButton(
                          highlightColor: Colors.yellow[900],
                          splashColor: Colors.yellow[500],
                          onPressed: () => _speak(),
                          child: Text("Feature: Fruits & Vegetable Identifier",
                              style: TextStyle(
                                  fontSize: 27.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))))),
              color: Hexcolor('e56b6f')),
        ],
        scrollDirection: Axis.horizontal,
        pageSnapping: true,
        physics: BouncingScrollPhysics(),
      ),
    );
  }

  Future _speak() async {
    await flutterTts.speak("something");
  }
}
//
