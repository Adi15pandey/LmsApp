import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'BulkUploadDialog.dart';
import 'filedatamodel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  ConciliationResponse? conciliationResponse;

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  Future<String?> _getTokenFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzkwNTg0NiwiZXhwIjoxNzM0NTEwNjQ2fQ.YIoKP6gZm5oYdzYMKc46fsKYAqTTM-gfnLE0YN9Egzk';
  Future<void> fetchData() async {
    final token = await _getTokenFromPreferences();
    if (token == null) {
      print('Token not found. Please log in again.');
      return; // Optionally handle the case when the token is not found
    }
    final url = 'https://lms.recqarz.com/api/econciliation/get?page=1&limit=10000';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        setState(() {
          conciliationResponse = ConciliationResponse.fromJson(jsonResponse);
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _downloadFile(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _handleFileUpload(File file) {
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color.fromRGBO(10, 36, 114, 1),
        title: Text(
          'Upload Data',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return BulkUploadDialog(onFileUploaded: _handleFileUpload);
                  },
                );
              },
              child: Text('Bulk Upload'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 20),
            Expanded(
              child: conciliationResponse == null
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                itemCount: conciliationResponse!.conciliations.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
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
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: ListTile(
                        title: Text(
                          conciliationResponse!.conciliations[index].filename,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Date and Time : ${conciliationResponse!.conciliations[index].createdAt}'),
                        trailing: IconButton(
                          icon: Icon(Icons.download),
                          color: Color.fromRGBO(228, 16, 16, 1.0),
                          onPressed: () {
                            _downloadFile(conciliationResponse!.conciliations[index].s3Url);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
