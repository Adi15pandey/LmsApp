
import 'package:lms_practice/filelistscreen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notice_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NoticeDataSource extends DataTableSource {
  final List<NoticeModel> notices = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final BuildContext context;

  NoticeDataSource(this.context);

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchData(DateTime startDate, DateTime endDate, String selectedNoticeType, String searchQuery) async {
    final String apiUrl = 'https://lms.test.recqarz.com/api/notice/notices';

    final Map<String, String> params = {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'page': '1',
      'limit': '1000',
      'client':"",
      'notice':"",
      if (selectedNoticeType != 'All') 'NoticeID': selectedNoticeType,
      if (searchQuery.isNotEmpty) 'search': searchQuery,
    };

    final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzAzOTY0MiwiZXhwIjoxNzMzMTI2MDQyfQ.q7NWBweWMycRWWUHG5LO2AmX6hgGuhOcZqpQBpkrTDk';

    try {
      print(params);
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      // print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> noticesData = data['data'];

        final List<NoticeModel> noticeList = noticesData.map((notice) {
          return NoticeModel.fromJson(notice);
        }).toList();

        this.notices.clear();
        this.notices.addAll(noticeList);
        _isLoading = false;
        notifyListeners();
      } else {
        _errorMessage = 'Failed to load data';
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  DataRow? getRow(int index) {
    if (index >= notices.length) return null;
    final notice = notices[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text((index + 1).toString())),
        DataCell(Text(notice.noticeTypeName)),
        DataCell(Text(DateFormat('yyyy-MM-dd').format(notice.createdAt))),
        DataCell(
          Text(notice.filename, style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          )),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FileListScreen(
                  filename: notice.filename, // Pass the filename
                  ID: notice.id,


                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => notices.length;
  @override
  int get selectedRowCount => 0;
}

