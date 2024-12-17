import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'file_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  TextEditingController _searchNameController = TextEditingController();

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    _searchController.addListener(_filterNotices);
    _searchNameController.addListener(_filterNotices);


  }
  @override
  void dispose() {
    _searchController.dispose();
    _searchNameController.dispose();
    super.dispose();
  }

  void _filterNotices() {
    String accountQuery = _searchController.text.toLowerCase();
    String nameQuery = _searchNameController.text.toLowerCase();
    setState(() {
      _filteredNotices = _notices.where((notice) {
        bool matchesAccount = notice.data.account.toString().toLowerCase().contains(accountQuery);
        bool matchesName = notice.data.name.toLowerCase().contains(nameQuery);
        // bool matchesMobile = notice.data.mobileNumber.toString().toLowerCase().contains(mobileQuery);
        print("Matches Account: $matchesAccount, Matches Name: $matchesName");

        return (accountQuery.isEmpty || matchesAccount) &&
            (nameQuery.isEmpty || matchesName);  // Show results matching any of the filters
      }).toList();
    });
  }
  Future<String?> _getTokenFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgyMjk4OCwiZXhwIjoxNzM0NDI3Nzg4fQ.BuBjr2SlMBhyS2B3HV5PPHP8f5gGUsyV6I8A2It4O3U";
  Future<void> fetchData() async {
    final token = await _getTokenFromPreferences();
    if (token == null) {
      print('Token not found. Please log in again.');
      return; // Optionally handle the case when the token is not found
    }
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
        _filteredNotices = List.from(_notices);
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


                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SMS', style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Row(
                        children: [
                          Text(
                            rowData['smsStatus']?.toLowerCase() ?? 'Pending',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            rowData['smsStatus']?.toLowerCase() == 'delivered' ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      backgroundColor: rowData['smsStatus']?.toLowerCase() == 'delivered'
                          ? Colors.green
                          : rowData['smsStatus']?.toLowerCase() == 'na'
                          ? Colors.red
                          : Colors.grey,
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
                            rowData['notificationType'] ?? 'N/A', // Or use the appropriate key for the label
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            rowData['notificationType'] == 'Open' ? Icons.check : Icons.check, // Check status instead
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      backgroundColor: rowData['notificationType'] == 'Open' // Check if it's open or closed
                          ? Colors.green
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
                            rowData['whatsappStatus']?.toLowerCase() ?? 'pending',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            (rowData['whatsappStatus']?.toLowerCase() == 'delivered' || rowData['whatsappStatus']?.toLowerCase() == 'read')
                                ? Icons.check
                                : Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      backgroundColor: (rowData['whatsappStatus']?.toLowerCase() == 'delivered' || rowData['whatsappStatus']?.toLowerCase() == 'read')
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
                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle tracking details tap
                    //   },
                    //   child: Column(
                    //     children: [
                    //       Icon(Icons.picture_as_pdf, color: Colors.red),
                    //       SizedBox(height: 4),
                    //       Text('Tracking Details', style: TextStyle(fontSize: 12)),
                    //     ],
                    //   ),
                    // ),
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
        foregroundColor: Color.fromRGBO(10, 36, 114, 1),
        title: Text(
          'Files Detail',
          style: GoogleFonts.poppins( // Apply the custom font here
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,  // Customize the font weight
              fontSize: 20, // Set the font size if needed
            ),
          ),
        ),
      ),


      body:



      _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(

        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Reduced outer padding
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0), // Reduced inner padding
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Account No:',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0), // Rounded corners here
                        ),
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0), // Reduced height here
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0), // Reduced inner padding
                    child: TextField(
                      controller: _searchNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),// Rounded corners here
                        ),
                        prefixIcon: Icon(Icons.search),
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 12.0), // Reduced height here
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )

          ,
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
          //     child: TextField(
          //       controller: _searchController,
          //       decoration: InputDecoration(
          //         labelText: 'Search by Account Number',
          //         border: OutlineInputBorder(),
          //         prefixIcon: Icon(Icons.search),
          //       ),
          //     ),
          //   ),
          // ),


          // Header Row
          Container(
            margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            padding: EdgeInsets.symmetric(vertical: 8.0),


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
                      "Account No:",
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
              itemCount: _filteredNotices.isNotEmpty ? _filteredNotices.length : 0,
    itemBuilder: (context, index) {
    if (_filteredNotices.isEmpty) {
    return Center(child: Text("No records found"));
    }

    final notice = _filteredNotices[index];

                return Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  width: 328, // Fixed width as per your layout
                  height: 40, // Fixed height as per your layout
                  decoration: BoxDecoration(
                      color: Color.fromRGBO(238, 240, 250, 1.0),
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
                                // 'date': notice.data.date,

                                'smsStatus': notice.smsStatus,

                                'notificationType': notice.notificationType,
                                'whatsappStatus': notice.whatsappStatus,
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
