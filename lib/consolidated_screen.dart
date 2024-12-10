// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// // Assuming these are defined elsewhere
//
// import 'notice_data_source.dart';
// import 'notice_model.dart';
// import 'filelistscreen.dart';
//
// class ConsolidatedScreen extends StatefulWidget {
//   @override
//   State<ConsolidatedScreen> createState() => _ConsolidatedScreenState();
// }
//
// class _ConsolidatedScreenState extends State<ConsolidatedScreen> {
//   DateTime _startDate = DateTime.now().subtract(Duration(days: 7));
//   DateTime _endDate = DateTime.now();
//   String _selectedNoticeType = 'All';
//   String _searchQuery = '';
//   late NoticeDataSource _noticeDataSource;
//
//   @override
//   void initState() {
//     super.initState();
//     _noticeDataSource = NoticeDataSource(context);
//     _fetchData();
//   }
//
//   void _fetchData() {
//     _noticeDataSource.fetchData(
//       _startDate,
//       _endDate,
//       _selectedNoticeType,
//       _searchQuery,
//     );
//   }
//
//   void _openFilterDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return FilterDialog(
//           onApplyFilters: (startDate, endDate, noticeType) {
//             setState(() {
//               _startDate = startDate;
//               _endDate = endDate;
//               _selectedNoticeType = noticeType;
//             });
//             _fetchData();
//           },
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Consolidated Screen'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.filter_alt_outlined),
//             onPressed: _openFilterDialog,
//           ),
//         ],
//       ),
//       body: _noticeDataSource.isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _noticeDataSource.errorMessage.isNotEmpty
//           ? Center(child: Text(_noticeDataSource.errorMessage))
//           : SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//               padding: EdgeInsets.all(screenWidth > 600 ? 12 : 8),
//               child: Row(
//                 children: [
//                   _buildHeaderCell('S. No.', screenWidth),
//                   _buildHeaderCell('Notice Type', screenWidth),
//                   _buildHeaderCell('Date', screenWidth),
//                   _buildHeaderCell('File Name', screenWidth),
//                 ],
//               ),
//             ),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: _noticeDataSource.notices.length,
//               itemBuilder: (context, index) {
//                 final notice = _noticeDataSource.notices[index];
//                 return _buildNoticeRow(index, notice, screenWidth);
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHeaderCell(String title, double screenWidth) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(screenWidth > 600 ? 12 : 8),
//         child: Text(
//           title,
//           style: TextStyle(
//             fontSize: screenWidth > 600 ? 16 : 14,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNoticeRow(int index, NoticeModel notice, double screenWidth) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
//       padding: EdgeInsets.all(screenWidth > 600 ? 12 : 8),
//       child: Row(
//         children: [
//           _buildDecoratedCell(Text((index + 1).toString())),
//           _buildDecoratedCell(Text(notice.noticeTypeName)),
//           _buildDecoratedCell(Text(DateFormat('yyyy-MM-dd').format(notice.createdAt))),
//           _buildDecoratedCell(
//             GestureDetector(
//               onTap: () {
//                 Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (context) => FileListScreen(
//                       filename: notice.filename,
//                       ID: notice.id,
//                     ),
//                   ),
//                 );
//               },
//               child: Text(
//                 notice.filename,
//                 style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDecoratedCell(Widget child) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(8),
//         child: child,
//       ),
//     );
//   }
// }
//
// class FilterDialog extends StatefulWidget {
//   final Function(DateTime startDate, DateTime endDate, String selectedNoticeType) onApplyFilters;
//
//   const FilterDialog({required this.onApplyFilters});
//
//   @override
//   _FilterDialogState createState() => _FilterDialogState();
// }
//
// class _FilterDialogState extends State<FilterDialog> {
//   DateTime _startDate = DateTime.now();
//   DateTime _endDate = DateTime.now();
//   String _selectedNoticeType = 'All';
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Filter'),
//       content: Column(
//         children: [
//           DatePickerField(
//             label: 'Start Date',
//             selectedDate: _startDate,
//             onDateSelected: (date) => setState(() => _startDate = date),
//           ),
//           DatePickerField(
//             label: 'End Date',
//             selectedDate: _endDate,
//             onDateSelected: (date) => setState(() => _endDate = date),
//           ),
//           DropdownButtonFormField<String>(
//             value: _selectedNoticeType,
//             onChanged: (value) => setState(() => _selectedNoticeType = value ?? 'All'),
//             items: [DropdownMenuItem(value: 'All', child: Text('All'))],
//           ),
//         ],
//       ),
//       actions: [
//         TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel')),
//         TextButton(
//           onPressed: () {
//             widget.onApplyFilters(_startDate, _endDate, _selectedNoticeType);
//             Navigator.of(context).pop();
//           },
//           child: Text('Apply'),
//         ),
//       ],
//     );
//   }
// }
//
// class DatePickerField extends StatelessWidget {
//   final String label;
//   final DateTime selectedDate;
//   final ValueChanged<DateTime> onDateSelected;
//
//   DatePickerField({required this.label, required this.selectedDate, required this.onDateSelected});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () async {
//         final picked = await showDatePicker(
//           context: context,
//           initialDate: selectedDate,
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2101),
//         );
//         if (picked != null) onDateSelected(picked);
//       },
//       child: InputDecorator(
//         decoration: InputDecoration(labelText: label),
//         child: Row(
//           children: [
//             Icon(Icons.calendar_today, size: 20, color: Colors.grey),
//             SizedBox(width: 8),
//             Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
//           ],
//         ),
//       ),
//     );
//   }
// }
