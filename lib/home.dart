import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:helping_hands/currency_detection/currency.dart';
import 'package:helping_hands/image_captioning/image_captioning.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
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
  File _capImage;
  File _currImage;
  final FlutterTts flutterTts = FlutterTts();

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
                          onPressed: () => _optionsDialogBox(),
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
                          onPressed: () => _sosDialogBox(),
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

  Future _speak() async {
    await flutterTts.speak("something");
  }

  Future<void> _sosDialogBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text("Enter phone numbers you would like to contact"),
              content: new SingleChildScrollView(
                  child: new ListBody(children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Enter phone number 1:',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Enter phone number 2:',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Enter phone number 3:',
                  ),
                ),
                new SizedBox(height: 10),
                new RaisedButton(
                  onPressed: () {},
                  color: Hexcolor('eaac8b'),
                  child: Text(
                    "Save Information",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  elevation: 5.0,
                  shape: new RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(16.0)),
                )
              ])));
        });
  }

  Future<void> _optionsDialogBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: new SingleChildScrollView(
              child: new ListBody(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyText2,
                      children: [
                        WidgetSpan(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                            child: Icon(FlutterIcons.photo_camera_mdi),
                          ),
                        ),
                        TextSpan(
                          text: 'Choose mode',
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Text('Take a picture'),
                    onTap: openCamera,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Text('Select from gallery'),
                    onTap: openGallery,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> openCamera() async {
    ImagePicker ip = new ImagePicker();
    var picture = await ip.getImage(
      source: ImageSource.camera,
    );
    var _extractText = await SimpleOcrPlugin.performOCR(picture.path);
    print(_extractText.substring(20));
    _speakOCR(_extractText.substring(20, _extractText.length - 15));
    showOCRDialog(
        _extractText.substring(20, _extractText.length - 15), picture);
  }

  Future<void> openGallery() async {
    ImagePicker ip = new ImagePicker();
    var picture = await ip.getImage(
      source: ImageSource.gallery,
    );
    var _extractText = await SimpleOcrPlugin.performOCR(picture.path);
    print(_extractText.substring(20));
    _speakOCR(_extractText.substring(20, _extractText.length - 15));
    showOCRDialog(
        _extractText.substring(20, _extractText.length - 15), picture);
  }

  Future<void> showOCRDialog(String text, PickedFile picture) async {
    final pngByteData = await picture.readAsBytes();
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.scale(
            scale: a1.value,
            child: Opacity(
              opacity: a1.value,
              child: AlertDialog(
                shape: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                title: Text('Text Detected'),
                content: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      new Container(
                        width: 300.0,
                        height: 150,
                        child: RaisedButton(
                          onPressed: _stopTts,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text('Stop',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          color: Hexcolor('b56576'),
                          elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(16.0)),
                        ),
                      ),
                      new Container(height: 10),
                      new Container(
                        width: 300.0,
                        height: 150,
                        child: RaisedButton(
                          onPressed: () {
                            _speakOCR(text);
                          },
                          padding: const EdgeInsets.all(10.0),
                          child: const Text('Replay',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          color: Hexcolor('b56576'),
                          elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(16.0)),
                        ),
                      ),
                      new Container(height: 10),
                      new Container(
                        width: 300.0,
                        height: 150,
                        child: RaisedButton(
                          onPressed: _pauseTts,
                          padding: const EdgeInsets.all(10.0),
                          child: const Text('Pause',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                          color: Hexcolor('b56576'),
                          elevation: 5.0,
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(16.0)),
                        ),
                      ),
                      new Container(height: 10),
                      new Image.memory(pngByteData),
                      SizedBox(width: 20),
                      new Text("$text"),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: Duration(milliseconds: 200),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {});
  }

  void _stopTts() {
    flutterTts.stop();
  }

  void _pauseTts() {
    flutterTts.pause();
  }

  Future _speakOCR(String text) async {
    await flutterTts.speak(text);
  }

  _speakPage(int a) async {
    if (a == 0) {
      await flutterTts.speak("Live object detection");
    } else if (a == 1) {
      await flutterTts.speak("Image Captioning");
    } else if (a == 2) {
      await flutterTts.speak("Text Extraction from images");
    } else if (a == 3) {
      await flutterTts.speak("Currency Identifier");
    }
  }
}
//
