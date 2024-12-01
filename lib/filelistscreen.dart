import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'file_model.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:open_url/open_url.dart';
import 'package:url_launcher/url_launcher.dart';

class FileListScreen extends StatefulWidget {
  final String filename;
  final String ID;

  FileListScreen({required this.filename, required this.ID});

  @override
  _FileListScreenState createState() => _FileListScreenState();
}

class _FileListScreenState extends State<FileListScreen> {
  int _currentIndex = 1;
  List<Notice> _notices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    print("00000000000000000000000000000000000000000");
    print(widget.ID);
  }

  final String token =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzAzOTY0MiwiZXhwIjoxNzMzMTI2MDQyfQ.q7NWBweWMycRWWUHG5LO2AmX6hgGuhOcZqpQBpkrTDk"; // Use your token here
  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(
          'https://lms.test.recqarz.com/api/notice/notices-entries?NoticeID=${widget.ID}&startDate=30/6/2023&endDate=30/6/2025&page=1&limit=10'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      setState(() {
        _notices = data.map((json) => Notice.fromJson(json)).toList();
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  void _onBottomNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0) {
      print("Dashboard selected");
    } else if (index == 2) {
      print("Search selected");
    } else if (index == 3) {
      print("SBI selected");
    }
  }

  void _showDetailDialog(Map<String, String> rowData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Name: ${rowData['name']}',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text('Date: ${rowData['date']}'),
                SizedBox(height: 16),
                ListTile(
                  title: Text('Whatsapp'),
                  trailing: Text('Whatsapp: ${rowData['status']}'),
                ),
                Divider(),
                ListTile(
                  title: Text('SMS'),
                  trailing: Text('SMS: ${rowData['smsStatus']}'),
                ),
                Divider(),
                ListTile(
                  title: Text('Email'),
                  trailing: Text('Email: ${rowData['notificationType']}'),
                ),
                Divider(),
                ListTile(
                  title: Text('Indiapost'),
                  trailing: Text('Indiapost: ${rowData['processIndiaPost']}'),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            String shortURL = rowData['shortURL'] ?? '';
                            //              String shortURL= 'https://cretezy.com';

                            print("000000000000");

                            if (shortURL.isNotEmpty) {
                              _launchURL(shortURL);
                            } else {
                              print('No URL found');
                            }
                          },
                          child: Icon(Icons.picture_as_pdf, color: Colors.red),
                        ),
                        SizedBox(height: 4),
                        Text('Notice Copy', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.picture_as_pdf, color: Colors.red),
                        SizedBox(height: 4),
                        Text('Tracking Details',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // void _openPDF(String url) async {
  //   final result = await OpenFile.open(url);
  //   if (result.type != ResultType.done) {
  //     print('Error opening PDF file: ${result.message}');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Files'),
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(
            color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DataTable(
                  headingRowHeight: 40,
                  dataRowHeight: 60,
                  columnSpacing: 20,
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.orange.shade100),
                  columns: [
                    DataColumn(label: Text('S. No.')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Mobile No.')),
                    DataColumn(label: Text('Account')),
                    DataColumn(label: Text('View')),
                  ],
                  rows: _notices.asMap().entries.map((entry) {
                    int index = entry.key + 1; // Serial number starts from 1
                    Notice notice = entry.value;
                    return DataRow(
                      cells: [
                        DataCell(Text(index.toString())),
                        DataCell(Text(notice.data.name)),
                        DataCell(Text(notice.data.mobileNumber.toString())),
                        DataCell(Text(notice.data.account.toString())),
                        DataCell(
                          GestureDetector(
                            onTap: () {
                              _showDetailDialog({
                                'name': notice.data.name,
                                'date': notice.data.date,
                                'status': notice.whatsappStatus,
                                'smsStatus': notice.smsStatus,
                                'notificationType': notice.notificationType,
                                'processIndiaPost': notice.processIndiaPost,
                                'shortURL': notice.shortURL,
                              });
                            },
                            child: Text(
                              'View More',
                              style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavigationTap,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Files'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance), label: 'SBI'),
        ],
      ),
    );
  }

  Future<void> requestPermission() async {
    // Request permission to manage external storage
    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      // Permission granted, proceed with your task
      print('Permission granted');
      // Example: Open a PDF file after permission is granted
    } else if (status.isDenied) {
      // Permission denied
      print('Permission denied');
    } else if (status.isPermanentlyDenied) {
      // If permission is permanently denied, guide the user to settings
      openAppSettings();
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
