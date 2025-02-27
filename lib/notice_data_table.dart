import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'notice_data_source.dart';
import 'notice_model.dart';
import 'filelistscreen.dart';

class NoticeDataTable extends StatefulWidget {
  final DateTime startDate;
  final DateTime endDate;
  final String selectedNoticeType;
  final String searchQuery;
  final NoticeDataSource noticeDataSource;

  const NoticeDataTable({
    required this.startDate,
    required this.endDate,
    required this.selectedNoticeType,
    required this.searchQuery,
    required this.noticeDataSource
  });

  @override
  State<NoticeDataTable> createState() => _NoticeDataTableState();
}

class _NoticeDataTableState extends State<NoticeDataTable> {
  late NoticeDataSource _noticeDataSource;

  @override
  void initState() {
    super.initState();
    _noticeDataSource = NoticeDataSource();
    _fetchData();
  }


  void _fetchData() {
    _noticeDataSource.fetchData(
      widget.startDate,
      widget.endDate,
      widget.selectedNoticeType,
      widget.searchQuery,
      1, 10

    ).then((_) {
      setState(() {});
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Notices'),
      // ),
      body: _noticeDataSource.isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Please wait, data is being loaded...',
              style: TextStyle(
                color: Color.fromRGBO(10, 36, 114, 1),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This might take a few seconds.',
              style: TextStyle(
                color: Color.fromRGBO(10, 36, 114, 1),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            // Optional: Add an animation or image here
            // For example, you can use an asset image:
            // Image.asset('assets/loading_image.png', height: 100),
          ],
        ),
      )


          : _noticeDataSource.errorMessage.isNotEmpty
          ? Center(child: Text(_noticeDataSource.errorMessage))
          : SingleChildScrollView(
        child: Column(
          children: [
            // Header Row
            Container(
              margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              padding: EdgeInsets.all(screenWidth > 600 ? 12 : 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(01),
              ),
              child: Row(
                children: [
                  _buildHeaderCell('S. No.', screenWidth),
                  _buildHeaderCell('Notice Type', screenWidth),
                  _buildHeaderCell('Date', screenWidth),
                  _buildHeaderCell('File Name', screenWidth),
                ],
              ),
            ),
            // ListView.builder for Rows
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _noticeDataSource.notices.length,
              itemBuilder: (context, index) {
                final notice = _noticeDataSource.notices[index];
                return _buildNoticeRow(index, notice, screenWidth);
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildHeaderCell(String title, double screenWidth) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(screenWidth > 600 ? 12 : 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: screenWidth > 600 ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: const Color.fromRGBO(10, 36, 114, 1),

          ),
        ),
      ),
    );
  }


  Widget _buildNoticeRow(int index, NoticeModel notice, double screenWidth) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      padding: EdgeInsets.all(screenWidth > 600 ? 12 : 8),
      decoration: BoxDecoration(
        color: Color.fromRGBO(238, 240, 250, 1.0),
        border: Border.all(
          color: Color.fromRGBO(10, 36, 114, 1),
          width: 0.75,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          _buildDecoratedCell(Text((index + 1).toString(), style: TextStyle(fontSize: screenWidth > 600 ? 14 : 12,color: Color.fromRGBO(0, 0, 0, 1),))),
          _buildDecoratedCell(Text(notice.noticeTypeName, style: TextStyle(fontSize: screenWidth > 600 ? 14 : 12,color: Colors.black,))),
          _buildDecoratedCell(Text(DateFormat('yyyy-MM-dd').format(notice.createdAt), style: TextStyle(fontSize: screenWidth > 600 ? 14 : 12,color: Colors.black,))),
          _buildDecoratedCell(
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FileListScreen(
                      filename: notice.filename,
                      ID: notice.id,
                    ),
                  ),
                );
              },
              child: Container(
                width: screenWidth > 600 ? 150 : 100,
                child: Text(
                  notice.filename,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 14 : 12,
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
  }

  Widget _buildDecoratedCell(Widget child) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: child,
      ),
    );
  }
}
