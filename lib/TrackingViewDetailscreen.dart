import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

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
  final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgwODMyMiwiZXhwIjoxNzMzODk0NzIyfQ.ZiBY47T9tXvPXApijOuy6lsWuUmFlGx4Itv-brN6mLc';

  // Fetch data with dynamic consignment ID
  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse('https://lms.test.recqarz.com/api/track/${widget.consignmentId}?page=1&limit=1000000'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];

      setState(() {
        consignments = data;  // Update the list with the fetched data
        isLoading = false;    // Stop the loading indicator
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
    fetchData(); // Fetch data when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          foregroundColor: Color.fromRGBO(10,36,114,1),title: Text('Consignment Tracking')
      ),

      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
              borderRadius: BorderRadius.circular(4.0), // Match the card border radius
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
                      _launchURL(consignment['pdf']); // Launch the PDF link
                    }
                  },
                ),
                onTap: () {
                  // Add navigation or other logic here if needed
                },
              ),
            ),
          );

        },
      ),
    );
  }
}
