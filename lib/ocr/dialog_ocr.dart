import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'package:vibration/vibration.dart';

class ocrDialog {
  final FlutterTts flutterTts = FlutterTts();

  Future<void> showOCRDialog(
      String text, PickedFile picture, BuildContext context) async {
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

  Future _stopTts() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 100, duration: 200);
    }
    flutterTts.stop();
  }

  void _pauseTts() {
    flutterTts.pause();
  }

  Future _speakOCR(String text) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(amplitude: 500, duration: 200);
    }
    await flutterTts.speak(text);
  }

  Future<void> optionsDialogBox(BuildContext context) {
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
                    onTap: () {
                      openCamera(context);
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  GestureDetector(
                    child: new Text('Select from gallery'),
                    onTap: () {
                      openGallery(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> openCamera(BuildContext context) async {
    ImagePicker ip = new ImagePicker();
    var picture = await ip.getImage(
      source: ImageSource.camera,
    );
    var _extractText = await SimpleOcrPlugin.performOCR(picture.path);
    print(_extractText.substring(20));
    _speakOCR(_extractText.substring(20, _extractText.length - 15));
    showOCRDialog(
        _extractText.substring(20, _extractText.length - 15), picture, context);
  }

  Future<void> openGallery(BuildContext context) async {
    ImagePicker ip = new ImagePicker();
    var picture = await ip.getImage(
      source: ImageSource.gallery,
    );
    var _extractText = await SimpleOcrPlugin.performOCR(picture.path);
    print(_extractText.substring(20));
    _speakOCR(_extractText.substring(20, _extractText.length - 15));
    showOCRDialog(
        _extractText.substring(20, _extractText.length - 15), picture, context);
  }
}
