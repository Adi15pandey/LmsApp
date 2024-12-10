import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Notice _type_model.dart';
import 'notice_data_source.dart';
import 'notice_data_table.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'notice_model.dart';

class FilesScreen extends StatefulWidget {
  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _selectedNoticeType = '';
  String _searchQuery = '';

  late NoticeDataSource _noticeDataSource;

  @override
  void initState() {
    super.initState();
    _noticeDataSource = NoticeDataSource();
    _loadData(); // Initial load
  }


  void _loadData() async {
    String noticeTypeToFetch = _selectedNoticeType.isEmpty ? 'All' : _selectedNoticeType;

    final String formattedStartDate = DateFormat('yyyy-MM-dd').format(_startDate);
    final String formattedEndDate = DateFormat('yyyy-MM-dd').format(_endDate);
    // final String urls = 'https://lms.recqarz.com/api/notice/notices?notice=$noticeTypeToFetch&startDate=$formattedStartDate&endDate=$formattedEndDate&page=1&limit=200';
    // print(urls);
    final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgyMjk4OCwiZXhwIjoxNzM0NDI3Nzg4fQ.BuBjr2SlMBhyS2B3HV5PPHP8f5gGUsyV6I8A2It4O3UyNjYyfQ.eqwknvI3N9C9Vbxz6jAoCuenpkEZ06iFCo0TJqF3dww';
    final url = Uri.parse(
        'https://lms.recqarz.com/api/dashboard/getDataByClientId?clientId=NotALL&dateRange=$formattedStartDate,$formattedEndDate&serviceType=all&dateType=fileProcessed&noticeType=$noticeTypeToFetch'
    );

    try {
      final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

      if (response.statusCode == 200) {
        // Check if the response body contains valid JSON
        Map<String, dynamic> responseData = json.decode(response.body);

        // Ensure 'data' and 'results' are present to avoid null errors
        if (responseData.containsKey('data') && responseData['data'].containsKey('results')) {
          List<dynamic> noticesData = responseData['data']['results'];
          print('API Response Data: $noticesData');

          final noticeList = noticesData.map((item) => NoticeModel.fromJson(item)).toList();

          setState(() {
            // Assuming NoticeDataSource expects a list of NoticeModel
            _noticeDataSource = NoticeDataSource(noticeList);  // Pass the list of NoticeModel
          });

        } else {
          // Handle the case where the 'data' or 'results' key is missing
          print('Unexpected response structure: ${response.body}');
        }
      } else {
        // Handle non-200 status codes here
        print('Failed to load notices. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle the error (e.g., parsing error, network issue, etc.)
      print('Error fetching data: $e');
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text(
          'Files',
          style: TextStyle(
            color: Color.fromRGBO(10, 36, 114, 1),
          ),
        ),
        automaticallyImplyLeading: Platform.isIOS ? true : false,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_outlined),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FilterDialog(
                    onApplyFilters: (DateTime startDate, DateTime endDate, String selectedNoticeType) {
                      setState(() {
                        _startDate = startDate;
                        _endDate = endDate;
                        _selectedNoticeType = selectedNoticeType.isEmpty ? 'All' : selectedNoticeType;
                      });
                      _loadData(); // Re-fetch data with new filters
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: NoticeDataTable(
        startDate: _startDate,
        endDate: _endDate,
        selectedNoticeType: _selectedNoticeType.isEmpty ? 'All' : _selectedNoticeType,
        searchQuery: _searchQuery,
      ),
    );
  }
}
class FilterDialog extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate, String selectedNoticeType) onApplyFilters;

  const FilterDialog({Key? key, required this.onApplyFilters}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _selectedNoticeType = 'All';
  List<NoticeType> _noticeTypes = [];


  // Fetch notice types when the dialog is initialized
  Future<void> _fetchNoticeTypes() async {
    final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzcxNzg2MiwiZXhwIjoxNzM0MzIyNjYyfQ.eqwknvI3N9C9Vbxz6jAoCuenpkEZ06iFCo0TJqF3dww';  // Replace with actual token
    final url = Uri.parse('https://lms.recqarz.com/api/clientMapping/user');

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = json.decode(response.body);
      List<dynamic> data = responseData['data'];

      setState(() {
        _noticeTypes = data.map((e) => NoticeType.fromJson(e)).toList();
      });
    } else {
      throw Exception('Failed to load notice types');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchNoticeTypes();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(

      title: Text('Filter'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            DatePickerField(
              label: 'Start Date',
              selectedDate: _startDate,
              onDateSelected: (date) {
                setState(() {
                  _startDate = date;
                });
              },
            ),
            SizedBox(height: 10),
            DatePickerField(
              label: 'End Date',
              selectedDate: _endDate,
              onDateSelected: (date) {
                setState(() {
                  _endDate = date;
                });
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedNoticeType,
              onChanged: (newValue) {
                setState(() {
                  _selectedNoticeType = newValue ?? ' All';
                });
              },
              items: [
                DropdownMenuItem<String>(
                  value: 'All',
                  child: Text('All'),
                ),
                ..._noticeTypes.map((NoticeType type) {
                  return DropdownMenuItem<String>(
                    value: type.notice.id,
                    child: Text(type.notice.noticeTypeName),
                  );
                }).toList(),
              ],
              decoration: InputDecoration(
                labelText: 'Notice Type',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onApplyFilters(_startDate, _endDate, _selectedNoticeType);
            Navigator.of(context).pop();
          },
          child: Text('Apply'),
        ),
      ],
    );
  }
}

class DatePickerField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  DatePickerField({
    required this.label,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null && picked != selectedDate) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              DateFormat('yyyy-MM-dd').format(selectedDate),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
