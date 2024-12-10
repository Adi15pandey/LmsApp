import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'BulkUploadDialog.dart';
import 'filedatamodel.dart';

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  ConciliationResponse? conciliationResponse;

  @override
  void initState() {
    super.initState();
    fetchData();  // Fetch data when the screen is loaded
  }

  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzc0NzMwNCwiZXhwIjoxNzMzODMzNzA0fQ.QtkiTyPLJDqwjaiO6ZY5NiG0SoOg2xSk44Jp2InVFuU'; // Add your token here

  Future<void> fetchData() async {
    final url = 'https://lms.test.recqarz.com/api/econciliation/get?page=1&limit=10';
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
        title: Text('Upload Data'),
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
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(
                        conciliationResponse!.conciliations[index].filename,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Created At: ${conciliationResponse!.conciliations[index].createdAt}'),
                      trailing: IconButton(
                        icon: Icon(Icons.download),
                        onPressed: () {
                          _downloadFile(conciliationResponse!.conciliations[index].s3Url);
                        },
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
