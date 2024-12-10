// file: main.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lms_practice/TrackingViewDetailscreen.dart';

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TrackingScreen(),
    );
  }
}

// Model for FileRecord
class FileRecord {
  final String id;
  final String filename;
  final String status;
  final DateTime createdAt;

  FileRecord({
    required this.id,
    required this.filename,
    required this.status,
    required this.createdAt,
  });

  factory FileRecord.fromJson(Map<String, dynamic> json) {
    return FileRecord(
      id: json['_id'],
      filename: json['filename'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

// API Service
class ApiService {
  final String apiUrl = "https://lms.test.recqarz.com/api/track/all?page=1&limit=1000000";
  final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgwODMyMiwiZXhwIjoxNzMzODk0NzIyfQ.ZiBY47T9tXvPXApijOuy6lsWuUmFlGx4Itv-brN6mLc"; // Add your token here

  Future<List<FileRecord>> fetchFileRecords() async {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(response.body)['data'];
      return body.map((dynamic item) => FileRecord.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load file records');
    }
  }
}

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late Future<List<FileRecord>> futureFileRecords;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    futureFileRecords = apiService.fetchFileRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color.fromRGBO(10,36,114,1),
        title: Text('File Tracker'),
      ),
      body: FutureBuilder<List<FileRecord>>(
        future: futureFileRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No records found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                FileRecord file = snapshot.data![index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                      title: Text(file.filename),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Status: ${file.status}'),
                          Text('Created At: ${DateFormat('MM/dd/yyyy').format(file.createdAt)}'),
                        ],
                      ),
                      trailing: file.status == 'process'
                          ? Text('Processing')
                          : TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ConsignmentTracking(consignmentId: file.id),
                            ),
                          );
                        },
                        child: Text('View Details'),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
