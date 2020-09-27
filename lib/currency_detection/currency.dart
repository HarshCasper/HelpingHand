import 'dart:io';
import 'package:tflite/tflite.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../home.dart';

class CurrPage extends StatefulWidget {
  File currImage;

  CurrPage({this.currImage});

  @override
  _CurrPageState createState() => _CurrPageState(this.currImage);
}

class _CurrPageState extends State<CurrPage> {
  File currImage;

  _CurrPageState(this.currImage);

  List _output;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      // setState(() {});
    });
    speakCurrencyValue();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  classifyCurrency(File image) async {
    var output = await Tflite.runModelOnImage(
        path: image.path,
        numResults: 7,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);
    print("This is the $output");
    print("This is the ${output[0]['label']}");
    dynamic label = output[0]['label'];
    print(label.runtimeType);
    _speak(label);
    setState(() {
      _output = output;
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/cash_model_unquant.tflite',
      labels: 'assets/cash_labels.txt',
    );
  }

  speakCurrencyValue() {
    classifyCurrency(currImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Currency Identification'),
          backgroundColor: Hexcolor('b56576'),
        ),
        body: Center(
            child: SizedBox.expand(
                child: GestureDetector(
          onTap: () => speakCurrencyValue(),
          onDoubleTap: () {},
          child: Image.file(currImage),
        ))));
  }

  Future _speak(String output) async {
    await flutterTts.speak(output);
  }
}
//
