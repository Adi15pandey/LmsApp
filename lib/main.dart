import 'package:flutter/material.dart';
import 'package:lms_practice/splash_screen.dart';
import 'login_screen.dart';

void main() {
  runApp(LMSApp());
}

class LMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LmsRec',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

