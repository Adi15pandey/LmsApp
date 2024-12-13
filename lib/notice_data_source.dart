import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'notice_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'filelistscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NoticeDataSource extends DataTableSource {
  late List<NoticeModel> notices = [];
  bool _isLoading = true;
  String _errorMessage = '';

  NoticeDataSource([noticeList]);

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void updateData(List<NoticeModel> newNotices) {
    notices = newNotices;
    _isLoading = false;
    notifyListeners();
  }
  Future<String?> _getTokenFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> fetchData(DateTime startDate, DateTime endDate, String selectedNoticeType, String searchQuery) async {
    final token = await _getTokenFromPreferences();

    if (token == null) {
      print('Token not found. Please log in again.');
      return; // Optionally handle the case when the token is not found
    }

    final String apiUrl = 'https://lms.recqarz.com/api/notice/notices';

    final Map<String, String> params = {
      'startDate': DateFormat('yyyy-MM-dd').format(startDate),
      'endDate': DateFormat('yyyy-MM-dd').format(endDate),
      'page': '1',
      'limit': '1000000',
      'client': "",
      'notice': "",
      if (selectedNoticeType != 'All') 'NoticeID': selectedNoticeType,
      if (searchQuery.isNotEmpty) 'search': searchQuery,
    };

    // final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgyMjk4OCwiZXhwIjoxNzM0NDI3Nzg4fQ.BuBjr2SlMBhyS2B3HV5PPHP8f5gGUsyV6I8A2It4O3U';

    try {
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

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

  Widget _buildDecoratedCell(Widget child) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Color.fromRGBO(10, 36, 114, 1),
          width: 0.75,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }

  @override
  DataRow? getRow(int index) {
    if (index >= notices.length) return null;
    final notice = notices[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(_buildDecoratedCell(Text((index + 1).toString(), style: TextStyle(fontSize: 12)))),
        DataCell(_buildDecoratedCell(Text(notice.noticeTypeName, style: TextStyle(fontSize: 12)))),
        DataCell(_buildDecoratedCell(Text(DateFormat('yyyy-MM-dd').format(notice.createdAt), style: TextStyle(fontSize: 12)))),
        DataCell(
          _buildDecoratedCell(
            GestureDetector(
              onTap: () {
                // context should be passed from the place where this method is called.
              },
              child: Text(
                notice.filename,
                style: TextStyle(fontSize: 12, color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ),
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

class NoticeTableScreen extends StatefulWidget {
  @override
  _NoticeTableScreenState createState() => _NoticeTableScreenState();
}

class _NoticeTableScreenState extends State<NoticeTableScreen> {
  late NoticeDataSource _noticeDataSource;

  @override
  void initState() {
    super.initState();
    _noticeDataSource = NoticeDataSource();
    _fetchNotices();
  }

  Future<void> _fetchNotices() async {
    await _noticeDataSource.fetchData(DateTime.now().subtract(Duration(days: 30)), DateTime.now(), 'All', '');
    setState(() {
      // _noticeDataSource = NoticeDataSource(noticeList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(
        title: Text('Notices')

      ),
      body: _noticeDataSource.isLoading
          ? Center(child: CircularProgressIndicator())
          : _noticeDataSource.errorMessage.isNotEmpty
          ? Center(child: Text('Error: ${_noticeDataSource.errorMessage}'))
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: Color.fromRGBO(10, 36, 114, 1),
                width: 0.75,
              ),
            ),
            child: DataTable(
              columns: [
                DataColumn(label: Text('S. No.')),
                DataColumn(label: Text('Notice Type')),
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('File Name')),
              ],
              rows: List<DataRow>.generate(
                _noticeDataSource.rowCount,
                    (index) {
                  final DataRow? row = _noticeDataSource.getRow(index);
                  if (row != null) {
                    return DataRow(
                      cells: row.cells.map((cell) {
                        if (cell.child is GestureDetector) {
                          final GestureDetector gestureDetector = cell.child as GestureDetector;
                          return DataCell(
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => FileListScreen(
                                      filename: _noticeDataSource.notices[index].filename,
                                      ID: _noticeDataSource.notices[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: gestureDetector.child,
                            ),
                          );
                        }
                        return cell;
                      }).toList(),
                    );
                  }
                  return row!;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}


