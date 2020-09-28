import 'package:flutter/material.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:imgur/imgur.dart' as imgur;
import 'package:path/path.dart';
import 'package:flutter_tts/flutter_tts.dart';

class imgCap {
  File capImage;
  Context context;

  static final FlutterTts flutterTts = FlutterTts();

  static uploadImg(BuildContext context, File image) async {
    print("stage 1");
    final client =
    imgur.Imgur(imgur.Authentication.fromToken('a05da4f1a5b17ae'));
    print("stage 2");

    /// Upload an image from path
    String imgLink = await client.image
        .uploadImage(
      imagePath: image.path,
    )
        .then((image) => image.link);
    print("stage 3");
    String caption = await extractCaption(imgLink);
    print("stage 5");
    _speak(caption);
    showCaptionDialog(context, caption, image);
  }

  static _speak(String output) async {
    await flutterTts.speak(output);
  }

  static Future extractCaption(String imgLink) async {
    print("stage 4 ");
    var caption = await http.post('https://bow-flannel-food.glitch.me/caption',
        body: {"image_url": imgLink});
    print("stage a");
    var parsed = json.decode(caption.body);
    print("stage b");
    return parsed.toString();
  }

  static Future<void> showCaptionDialog(
      BuildContext context, String text, File picture) async {
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
                title: Text('Image Caption'),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      new Image.file(picture),
                      SizedBox(width: 20),
                      new Text("$text"),
                      new RaisedButton(
                        onPressed: () {
                          _speak(text);
                        },
                        padding: const EdgeInsets.all(10.0),
                        child: const Text('Replay'),
                        color: Color(0xFFE08284),
                        elevation: 5.0,
                      ),
                      new RaisedButton(
                        onPressed: _stopTts,
                        padding: const EdgeInsets.all(10.0),
                        child: const Text('Stop'),
                        color: Color(0xFFE08284),
                        elevation: 5.0,
                      )
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

  static void _stopTts() {
    flutterTts.stop();
  }
}
