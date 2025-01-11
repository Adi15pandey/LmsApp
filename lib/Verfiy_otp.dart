import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart'; // Ensure MainScreen is imported correctly

class Verifyotpclient extends StatefulWidget {
  final String storedEmail;

  const Verifyotpclient({super.key, required this.storedEmail});

  @override
  State<Verifyotpclient> createState() => _VerifyotpclientState();
}

class _VerifyotpclientState extends State<Verifyotpclient> {
  final TextEditingController _emailOtpController = TextEditingController();
  final TextEditingController _phoneOtpController = TextEditingController();
  final String apiUrl = 'https://lms.test.recqarz.com/api/user/login';

  bool isLoading = false;

  Future<void> _verifyOtp() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Define the headers and body
      var headers = {'Content-Type': 'application/json'};
      var body = json.encode({
        "email": widget.storedEmail,
        "emailOtp": _emailOtpController.text,
        "smsOtp": _phoneOtpController.text,
      });

      // Make the POST request
      var response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: body,
      );

      // Log the response details for debugging
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // Extract the token
          String token = jsonResponse['data']['accessToken'] ?? '';
          String refreshToken = jsonResponse['data']['refreshToken'] ?? '';
          String role = jsonResponse['data']['role'] ?? 'user';

          if (token.isNotEmpty) {
            // Save tokens to SharedPreferences
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('auth_token', token);
            await prefs.setString('refresh_token', refreshToken);
            await prefs.setString('user_role', role);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('OTP Verified Successfully')),
            );

            // Navigate to MainScreen or another screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen()),
            );
          } else {
            throw Exception('Access token missing in response');
          }
        } else {
          String message = jsonResponse['message'] ?? 'OTP Verification Failed';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } else {
        // Handle non-200 HTTP status codes
        print('Error: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server error, please try again.')),
        );
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred, please try again.')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Verify OTP',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                overflow: TextOverflow.ellipsis, // Prevents overflow
              ),
            ),
          ],
        ),
      ),

      body: Center(
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailOtpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP from Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneOtpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP from Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[900],
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 16.0),
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
