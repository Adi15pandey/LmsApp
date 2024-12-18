import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
// Import url_launcher

class ConsignmentTracking extends StatefulWidget {
  final String consignmentId;

  ConsignmentTracking({required this.consignmentId});

  @override
  _ConsignmentTrackingState createState() => _ConsignmentTrackingState();
}

class _ConsignmentTrackingState extends State<ConsignmentTracking> {
  List consignments = [];
  bool isLoading = true;

  // Token for authentication
  // final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzkwNTg0NiwiZXhwIjoxNzM0NTEwNjQ2fQ.YIoKP6gZm5oYdzYMKc46fsKYAqTTM-gfnLE0YN9Egzk';
  // Fetch data with dynamic consignment ID
  Future<String?> _getTokenFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  Future<void> fetchData() async {
    final token = await _getTokenFromPreferences();
    if (token == null) {
      print('Token not found. Please log in again.');
      return; // Optionally handle the case when the token is not found
    }

    final response = await http.get(
      Uri.parse('https://lms.recqarz.com/api/track/${widget.consignmentId}?page=1&limit=1000000'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];

      setState(() {
        consignments = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      print("Failed to load data. Status code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      throw Exception('Failed to load data');
    }
  }

  // Function to launch the PDF URL
  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color.fromRGBO(10, 36, 114, 1),
        title: Text(
          'Consignment Tracking',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,  // Customize the font weight
              fontSize: 20, // Set the font size if needed
            ),
          ),
        ),
      ),


      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Please wait, data is being loaded...',
              style: TextStyle(
                color: Color.fromRGBO(10, 36, 114, 1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This might take a few seconds.',
              style: TextStyle(
                color: Color.fromRGBO(10, 36, 114, 1),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            // Optional: Add an animation or image here
            // For example, you can use an asset image:
            // Image.asset('assets/loading_image.png', height: 100),
          ],
        ),
      )
          : ListView.builder(
        itemCount: consignments.length,
        itemBuilder: (context, index) {
          final consignment = consignments[index];
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromRGBO(10, 36, 114, 1),
                width: 2.0, // Adjust the border width as needed
              ),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: Card(
              elevation: 2.0, // Optional: add elevation for shadow effect
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0), // Match the container border radius
              ),
              child: ListTile(
                title: Text(consignment['CONSIGNMENT_NO'] ?? 'No consignment number'),
                subtitle: Text(consignment['status'] ?? 'No status'),
                trailing: IconButton(
                  icon: Icon(Icons.picture_as_pdf),
                  color: Color.fromRGBO(181, 12, 12, 1.0),
                  onPressed: () {
                    // Check if the PDF link is available and valid
                    if (consignment['pdf'] != null && consignment['pdf'].isNotEmpty) {
                      _launchURL(consignment['pdf']);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text('Consignment Details Not Found'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },

                ),
                onTap: () {

                },
              ),
            ),
          );

        },
      ),
    );
  }
}
