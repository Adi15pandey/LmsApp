import 'package:flutter/material.dart';
import 'package:lms_practice/dashboard_screen.dart';
import 'package:lms_practice/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';

class LogoutScreen extends StatelessWidget {
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();


    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );


  }

  @override
  Widget build(BuildContext context) {

    logout(context);

    return Scaffold(
      appBar: AppBar(title: Text('Logging Out')),
      body: Center(
        child: CircularProgressIndicator(),  // Show a loading indicator while logging out
      ),
    );
  }
}


