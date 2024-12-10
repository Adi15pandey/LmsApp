import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'file_model.dart';
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
  List<Notice> _filteredNotices = [];
  List<Notice> _notices = [];
  TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(_filterNotices);

  }
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterNotices() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNotices = _notices
          .where((notice) =>
          notice.data.account.toString().toLowerCase().contains(query))
          .toList();
    });
  }

  final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgyMjk4OCwiZXhwIjoxNzM0NDI3Nzg4fQ.BuBjr2SlMBhyS2B3HV5PPHP8f5gGUsyV6I8A2It4O3U";
  Future<void> fetchData() async {
    final response = await http.get(
      Uri.parse(
          'https://lms.recqarz.com/api/notice/notices-entries?NoticeID=${widget.ID}&startDate=30/6/2000&endDate=30/6/2025&page=1&limit=100000000'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

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

  void _showDetailDialog(Map<String, String> rowData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Name Field
                TextFormField(
                  initialValue: rowData['name'],
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  readOnly: true,
                ),
                SizedBox(height: 16),

                // Statuses with Tick or Cross Mark
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SMS', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Row(
                        children: [
                          Text(
                            rowData['smsStatus'] ?? 'Pending',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            rowData['smsStatus'] == 'Delivered' ? Icons.close : Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      backgroundColor: rowData['smsStatus'] == 'Delivered'
                          ? Colors.green
                          : Colors.green,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Email', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Row(
                        children: [
                          Text(
                            rowData['notificationType'] ?? 'Pending',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            rowData['notificationType'] == 'Delivered' ? Icons.close : Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      backgroundColor: rowData['notificationType'] == 'Delivered'
                          ? Colors.red
                          : Colors.green,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Row(
                        children: [
                          Text(
                            rowData['status'] ?? 'Pending',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            rowData['status'] == 'Delivered' ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      backgroundColor: rowData['status'] == 'Delivered'
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('India Post', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Row(
                        children: [
                          Text(
                            rowData['processIndiaPost'] ?? 'Pending',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            rowData['processIndiaPost'] == 'Delivered' ? Icons.check : Icons.close,
                            color: Colors.black,
                            size: 16,
                          ),
                        ],
                      ),
                      backgroundColor: Colors.yellow,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Notice Copy and Tracking Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        String shortURL = rowData['shortURL'] ?? '';
                        if (shortURL.isNotEmpty) {
                          _launchURL(shortURL);
                        } else {
                          print('No URL found');
                        }
                      },
                      child: Column(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red),
                          SizedBox(height: 4),
                          Text('Notice Copy', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Handle tracking details tap
                      },
                      child: Column(
                        children: [
                          Icon(Icons.picture_as_pdf, color: Colors.red),
                          SizedBox(height: 4),
                          Text('Tracking Details', style: TextStyle(fontSize: 12)),
                        ],
                      ),
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






  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Files'),
        backgroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: TextStyle(
            color: Color.fromRGBO(10, 36,114, 1), fontWeight: FontWeight.bold, fontSize: 20),
      ),

      body:


      _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Header Row
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            padding: EdgeInsets.symmetric(vertical: 8.0),
            // decoration: BoxDecoration(
            //   color: Color.fromRGBO(10, 36, 114, 1),
            //   // borderRadius: BorderRadius.circular(10.0),
            // ),
            child: Row(
              children: [
                // Header for Serial Number
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      "S. No.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(10, 36, 114, 1),
                        fontSize: screenWidth < 600 ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                // Header for Name
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(10, 36, 114, 1),
                        fontSize: screenWidth < 600 ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                // Header for Mobile Number
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "Mobile No.",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(10, 36, 114, 1),
                        fontSize: screenWidth < 600 ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                // Header for Account Number
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      "Account",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(10, 36, 114, 1),
                        fontSize: screenWidth < 600 ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                // Header for View Button
                Expanded(
                  flex: 2,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        print("View Header Clicked");
                      },
                      child: Text(
                        "View ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(10, 36, 114, 1),
                          fontSize: screenWidth < 600 ? 12 : 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ListView Builder for Data Rows
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              itemCount: _notices.length,
              itemBuilder: (context, index) {
                Notice notice = _notices[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  width: 328, // Fixed width as per your layout
                  height: 40, // Fixed height as per your layout
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15)// Border radius on top-le
                    ),
                    border: Border.all(
                      color: Color.fromRGBO(10, 36, 114, 1), // Border color
                      width: 0.75, // Border width
                    ),
                  ),
                  child: Row(
                    children: [
                      // Serial Number
                      Expanded(
                        flex: 1,
                        child: Center(
                          child: Text(
                            "${index + 1}.",
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 10 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Name
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            notice.data.name,
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 10 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      // Mobile Number
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            notice.data.mobileNumber.toString(),
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 10 : 14,
                            ),
                          ),
                        ),
                      ),
                      // Account Number
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            notice.data.account.toString(),
                            style: TextStyle(
                              fontSize: screenWidth < 600 ? 10 : 14,
                            ),
                          ),
                        ),
                      ),
                      // View More
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: GestureDetector(
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
                                fontSize: screenWidth < 600 ? 10 : 14,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }




}
