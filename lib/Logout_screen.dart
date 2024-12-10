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


    // Navigator.pushReplacementNamed(context, '/login');  // Replace '/login' with your actual login screen's route name
  }

  @override
  Widget build(BuildContext context) {
    // Call the logout method as soon as the screen is built
    logout(context);

    return Scaffold(
      appBar: AppBar(title: Text('Logging Out')),
      body: Center(
        child: CircularProgressIndicator(),  // Show a loading indicator while logging out
      ),
    );
  }
}
// void main() {
//   runApp(MaterialApp(
//     initialRoute: '/home',  // The initial route (home page) when the app starts
//     routes: {
//       '/home': (context) => DashboardScreen(),
//       '/login': (context) => LoginScreen(),  // Define your login screen here
//       '/logout': (context) => LogoutScreen(),  // Define the logout screen route
//     },
//   ));
// }

