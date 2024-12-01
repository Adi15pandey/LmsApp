import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
        title: Text('Search'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Search by ACC/No.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter ACC/No.',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _performSearch(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Colors.grey[500],
              ),
              child: Text('Search'),
            ),
          ],
        ),
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

  Future<void> _fetchSearchResults() async {
    final searchQuery = widget.searchQuery;
    final apiUrl =
        'https://lms.test.recqarz.com/api/notice/filterWithAccountRefnoPOD?name=&account=$searchQuery&ref_no=&mobilenumber=&startDate=&endDate=&page=1&limit=10';

    final token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzAzOTY0MiwiZXhwIjoxNzMzMTI2MDQyfQ.q7NWBweWMycRWWUHG5LO2AmX6hgGuhOcZqpQBpkrTDk';

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
                return item.accountNo.toString().startsWith(searchQuery);
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
            _errorMessage = resultData['message'] ?? 'Failed to load data';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load data';
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
    return  Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
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
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('S. No.')),
                        DataColumn(label: Text('Notice Type')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Account No.')),
                        DataColumn(label: Text('Address')),
                      ],
                      rows: _data.asMap().entries.map((entry) {
                        int index = entry.key;
                        SearchResult item = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text((index + 1).toString())),  // Serial number
                            DataCell(Text(item.noticeType)),
                            DataCell(Text(item.date)),
                            DataCell(Text(item.accountNo)),
                            DataCell(Text(item.address)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
            Text(
              'Results for: ${widget.searchQuery}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}


class SearchResult {
  final String sNo;
  final String noticeType;
  final String date;
  final String accountNo;
  final String address;

  SearchResult({
    required this.sNo,
    required this.noticeType,
    required this.date,
    required this.accountNo,
    required this.address,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      sNo: json['_id'] ?? '',
      noticeType: json['NoticeID']['notice']['noticeTypeName'] ?? '',
      date: json['data']['date'] ?? '',
      accountNo: json['data']['account'] ?? '',
      address: json['data']['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sNo': sNo,
      'noticeType': noticeType,
      'date': date,
      'accountNo': accountNo,
      'address': address,
    };
  }
}
