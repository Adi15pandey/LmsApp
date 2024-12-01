// import 'package:areness/Notice%20_type_model.dart';
// import 'package:areness/files_screen.dart';
// import 'package:areness/filescreenmodel.dart';
// import 'package:areness/notice_data_source.dart';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Notice _type_model.dart';
import 'notice_data_source.dart';
import 'notice_data_table.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// Ensure this import is added
import 'package:flutter/material.dart';
import 'notice_data_table.dart';

class FilesScreen extends StatefulWidget {
  @override
  State<FilesScreen> createState() => _FilesScreenState();
}

class _FilesScreenState extends State<FilesScreen> {
  DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
  DateTime _endDate = DateTime.now();
  String _selectedNoticeType = 'All';
  String _searchQuery = '';

  late NoticeDataSource _noticeDataSource;

  @override
  void initState() {
    super.initState();
    _noticeDataSource = NoticeDataSource(context); // Initialize data source
    _loadData(); // Initial load
  }

  void _loadData() {
    _noticeDataSource.fetchData(_startDate, _endDate, _selectedNoticeType, _searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Files'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return FilterDialog(
                    onApplyFilters: (DateTime startDate, DateTime endDate, String selectedNoticeType) {
                      setState(() {
                        _startDate = startDate;
                        _endDate = endDate;
                        _selectedNoticeType = selectedNoticeType;
                      });
                      _loadData(); // Reload the data with the new filters
                    },
                  );
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Implement search functionality if required
            },
          ),
        ],
      ),
      body: NoticeDataTable(
        startDate: _startDate,
        endDate: _endDate,
        selectedNoticeType: _selectedNoticeType,
        searchQuery: _searchQuery,
      ),
    );
  }
}



class FilterDialog extends StatefulWidget {
  final Function(DateTime startDate, DateTime endDate, String selectedNoticeType)
  onApplyFilters;

  const FilterDialog({Key? key, required this.onApplyFilters}) : super(key: key);

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String _selectedNoticeType = 'All';
  List<NoticeType> _noticeTypes = [];

  Future<void> _selectDate(BuildContext context, DateTime initialDate, ValueChanged<DateTime> onDateSelected) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != initialDate) {
      onDateSelected(picked);
    }
  }

  Future<void> _fetchNoticeTypes() async {


    final String token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzAzOTY0MiwiZXhwIjoxNzMzMTI2MDQyfQ.q7NWBweWMycRWWUHG5LO2AmX6hgGuhOcZqpQBpkrTDk'; // Replace with your token
    // final url = Uri.parse('https://lms.test.recqarz.com/api/noticeType/fetch?isActive=true');
    final url = Uri.parse('https://lms.test.recqarz.com/api/clientMapping/user');

    final response = await http.get(url, headers: {'Authorization': 'Bearer $token'});
    print(response.body,);
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
    _fetchNoticeTypes(); // Fetch the notice types on dialog initialization
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
                  _selectedNoticeType = newValue!;
                });
              },
              items: [
                // Add 'All' as the first option in the dropdown
                DropdownMenuItem<String>(
                  value: 'All',
                  child: Text('All'),
                ),
                // Map the fetched _noticeTypes to DropdownMenuItem<String>
                ..._noticeTypes.map((NoticeType type) {
                  return DropdownMenuItem<String>(
                    value: type.noticeTypeName,  // value is directly from NoticeType
                    child: Text(type.noticeTypeName),  // Text display is also directly from NoticeType
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
            // Apply the filter and fetch the data
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



