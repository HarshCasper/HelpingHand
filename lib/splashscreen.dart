import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

import 'home.dart';
import 'main.dart';

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: new HomePage(cameras),
      backgroundColor: Colors.white,
      photoSize: 150,
      loaderColor: Colors.blueAccent,
      image: Image.asset('assets/icon.jpg'),
    );
  }
}
