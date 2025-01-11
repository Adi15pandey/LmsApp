import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lms_practice/Verfiy_otp.dart';
import 'package:lms_practice/main_screen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getAuthToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return MaterialApp(home: MainScreen());
        } else {
          return MaterialApp(home: LoginScreen());
        }
      },
    );
  }

  Future<String?> _getAuthToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final String hardcodedEmail = "test@admin.com";
  final String hardcodedPassword = "12345";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final password = _passwordController.text;

    // Check for hardcoded email and password
    if (email == hardcodedEmail && password == hardcodedPassword) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', 'hardcoded_token');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in as Admin.')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
      return;
    }

    // Proceed with OTP verification for other emails
    await _initiateOtpLogin(email, password);
  }

  Future<void> _initiateOtpLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('https://lms.test.recqarz.com/api/user/initiateLoginAndGenerateOtp');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        print('Response Data: $responseData');

        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('OTP sent successfully.')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Verifyotpclient(storedEmail: email),
            ),
          );
        } else {
          final message = responseData['message'] ?? 'Login failed';
          _showErrorDialog(message);
        }
      } catch (error) {
        _showErrorDialog('Error parsing response: $error');
      }
    } else {
      final errorMessage = json.decode(response.body)['message'] ?? 'Unknown error';
      _showErrorDialog(errorMessage);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Login Failed'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/Group 1.png',
                  width: 400,
                  height: 150,
                ),
                SizedBox(height: 20),
                Text(
                  'Welcome',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!emailRegExp.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 5) {
                      return 'Password must be at least 5 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
