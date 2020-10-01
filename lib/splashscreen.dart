import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'main.dart';

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 2,
      navigateAfterSeconds: MyApp(),
      backgroundColor: Colors.blue,
      title: Text(
        'Helping Hand',
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white),
      ),
      photoSize: 150,
      loaderColor: Colors.white,
      image: Image.asset('assets/images/icon.png'),
    );
  }
}
