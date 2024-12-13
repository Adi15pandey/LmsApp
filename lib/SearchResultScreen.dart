import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    home: SearchScreen(),
  ));
}

class SearchScreen extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  void _performSearch(BuildContext context) {
    String searchQuery = _searchController.text;

    // Navigate to the SearchResultScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(searchQuery: searchQuery),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color.fromRGBO(10, 36, 114, 1),
        title: Text(
          'Search',
          style: GoogleFonts.poppins( // Apply the custom font here
            textStyle: TextStyle(
              fontWeight: FontWeight.bold,  // Customize the font weight
              fontSize: 20, // Set the font size if needed
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: 0.9,
              // child: Image.asset(
              //   'assets/images/bg.jpg',
              //   width: 466,
              //   height: 390,
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'SEARCH BY ACC NO.',
                    style: GoogleFonts.poppins(  // Apply the custom font here
                      textStyle: TextStyle(
                        fontSize: 16,  // Set the font size
                        fontWeight: FontWeight.w500,  // Set the font weight
                        color: Color.fromRGBO(10, 36, 114, 1),  // Set the text color
                      ),
                    ),
                  ),

                  SizedBox(height: 20),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Enter ACC/No.',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _performSearch(context),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      backgroundColor: Color.fromRGBO(78, 185, 103, 1),
                    ),
                    child: Text('Search'),

                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchResultScreen extends StatefulWidget {
  final String searchQuery;

  SearchResultScreen({required this.searchQuery});

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  List<SearchResult> _data = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchSearchResults();
  }

  Future<String?> _getTokenFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _fetchSearchResults() async {
    final token=await _getTokenFromPreferences();
    if (token == null) {
      print('Token not found. Please log in again.');
      return; // Optionally handle the case when the token is not found
    }

    final searchQuery = widget.searchQuery;
    final apiUrl =
        'https://lms.recqarz.com/api/notice/filterWithAccountRefnoPOD?name=&account=$searchQuery&ref_no=&mobilenumber=&startDate=&endDate=&page=1&limit=100000';

    // final token =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgyMjk4OCwiZXhwIjoxNzM0NDI3Nzg4fQ.BuBjr2SlMBhyS2B3HV5PPHP8f5gGUsyV6I8A2It4O3U ';

    try {
      print(apiUrl);
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        print("0000000000000000000000");
        final Map<String, dynamic> resultData = json.decode(response.body);

        print('Parsed Result Data: $resultData');

        if (resultData['success'] == true) {
          if (resultData['data'] is Map && resultData['data']['notices'] is List) {
            setState(() {
              _data = (resultData['data']['notices'] as List)
                  .map((item) => SearchResult.fromJson(item))
                  .where((item) {
                return item.account.toString().startsWith(searchQuery);
              }).toList();
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
              _errorMessage = 'No data found';
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = resultData['message'] ?? '';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = '';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error occurred: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Color.fromRGBO(10, 36, 114, 1),
          title: Text(
            'Search Result',
            style: GoogleFonts.poppins( // Apply the custom font here
              textStyle: TextStyle(
                fontWeight: FontWeight.bold,  // Customize the font weight
                fontSize: 20, // Set the font size if needed
              ),
            ),
          ),
        ),


        // automaticallyImplyLeading: (Platform.isIOS) ? true : false,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (_isLoading)
                CircularProgressIndicator()
              else if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(color: Colors.red),
                )
              else if (_data.isEmpty)
                  Text(
                    'No results found',
                    style: TextStyle(color: Colors.red),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color.fromRGBO(10, 36, 114, 1), width: 0.75), // Blue border
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text('S. No.')),
                              DataColumn(label: Text('Name')),
                              DataColumn(label: Text('Date')),
                              DataColumn(label: Text('Account No.')),
                              // DataColumn(label: Text('Address')),
                            ],
                            rows: _data.asMap().entries.map((entry) {
                              int index = entry.key;
                              SearchResult item = entry.value;
                              return DataRow(
                                cells: [
                                  DataCell(Text((index + 1).toString())),
                                  DataCell(Text(item.name)),
                                  DataCell(Text(item.date)),
                                  DataCell(Text(item.account)),
                                  // DataCell(Text(item.address)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),


              SizedBox(height: 20),
              Text(
                'Results for: ${widget.searchQuery}',
                style: TextStyle(fontWeight: FontWeight.w500,color: Color.fromRGBO(10,36,114,1),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchResult {
  final String sNo;
  final String noticeType;
  final String date;
  final String account;
  final String address;
  final String name;

  SearchResult({
    required this.sNo,
    required this.name,
    required this.noticeType,
    required this.date,
    required this.account,
    required this.address,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      sNo: json['_id'] ?? '',
      noticeType: json['NoticeID']?['notice']?['noticeTypeName'] ?? '',
      date: json['data']?['date'] ?? '',
      name: json['data']?['name'] ?? '',
      account: (json['data']?['account']?.toString() ?? 'No Account Found'),
      address: json['data']?['address'] ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'noticeType': noticeType,
      'date': date,
      'accountNo': account,
      'address': address,
    };
  }
}
