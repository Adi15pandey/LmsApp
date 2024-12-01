// Make sure to import the correct file
import 'package:flutter/material.dart';
import 'notice_data_source.dart';  // Correct import

class NoticeDataTable extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String selectedNoticeType;
  final String searchQuery;

  NoticeDataTable({
    required this.startDate,
    required this.endDate,
    required this.selectedNoticeType,
    required this.searchQuery,
  });

  @override
  State<NoticeDataTable> createState() => _NoticeDataTableState();
}

class _NoticeDataTableState extends State<NoticeDataTable> {
  late NoticeDataSource _noticeDataSource;

  @override
  void initState() {
    super.initState();
    _noticeDataSource = NoticeDataSource(this.context);
    _fetchData();  // Initial data fetch
  }

  // Method to fetch data based on filter parameters
  void _fetchData() {
    _noticeDataSource.fetchData(
      widget.startDate,
      widget.endDate,
      widget.selectedNoticeType,
      widget.searchQuery,
    ).then((_) {
      setState(() {});  // Rebuild UI once data is fetched
    });
  }

  @override
  void didUpdateWidget(covariant NoticeDataTable oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger a data fetch when the filter values change
    if (oldWidget.startDate != widget.startDate ||
        oldWidget.endDate != widget.endDate ||
        oldWidget.selectedNoticeType != widget.selectedNoticeType ||
        oldWidget.searchQuery != widget.searchQuery) {
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _noticeDataSource.isLoading
          ? Center(child: CircularProgressIndicator())
          : _noticeDataSource.errorMessage.isNotEmpty
          ? Center(child: Text(_noticeDataSource.errorMessage))
          : SingleChildScrollView(
        child: PaginatedDataTable(
          columns: [
            DataColumn(label: Text('Sr No')),
            DataColumn(label: Text('Notice Type')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('File Name')),
          ],
          source: _noticeDataSource,
          rowsPerPage: 10,
        ),
      ),
    );
  }
}


