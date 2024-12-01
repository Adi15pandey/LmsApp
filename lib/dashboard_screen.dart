
import 'package:flutter/material.dart';

import 'package:lms_practice/login_screen.dart';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard with Logout',
      initialRoute: '/',
      routes: {
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class DashboardScreen extends StatelessWidget {

  // Function to navigate to LoginScreen after logout
  Future<void> _logOut(BuildContext context) async {
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Function to show the confirmation dialog
  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Are you sure?'),
        content: Text('Do you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              _logOut(context);
            },
            child: Text('Log Out'),
          ),
        ],
      ),
    );

    if (shouldLogOut == true) {
      _logOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _confirmLogout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Dashboard Screen'),
      ),
    );
  }
}













//
//
//
//
// import 'package:areness/file_model.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:open_file/open_file.dart';
// // import 'package:url_launcher/url_launcher.dart';
// import 'dart:convert';
//
// class FileListScreen extends StatefulWidget {
//   final String filename;
//   final String ID;
//
//   FileListScreen({required this.filename, required this.ID,});
//
//   @override
//   _FileListScreenState createState() => _FileListScreenState();
// }
//
// class _FileListScreenState extends State<FileListScreen> {
//   int _currentIndex = 1;
//   List<Notice> _notices = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//     print("00000000000000000000000000000000000000000");
//     print(widget.ID);
//   }
//   final String token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NmYyYTI1NzFjNTI3YzgwMTYwMmQ5YWMiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMjg2MjI0NCwiZXhwIjoxNzMyOTQ4NjQ0fQ.R-3kddMQ_eYasmd1-NNeIPukeNrecRhdkjOpnUSXUPY";
//   Future<void> fetchData() async {
//     final response = await http.get(
//       Uri.parse(
//           'https://lms.test.recqarz.com/api/notice/notices-entries?NoticeID=${widget.ID}&startDate=30/6/2023&endDate=30/6/2025&page=1&limit=10'),
//       headers: {
//         'Authorization': 'Bearer $token',
//       },
//     );
//     print('Response body: ${response.body}');
//
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body)['data'];
//       setState(() {
//         _notices = data.map((json) => Notice.fromJson(json)).toList();
//         _isLoading = false;
//       });
//     } else {
//       throw Exception('Failed to load data');
//     }
//   }
//
//
//   void _onBottomNavigationTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//     if (index == 0) {
//       print("Dashboard selected");
//     } else if (index == 2) {
//       print("Search selected");
//     } else if (index == 3) {
//       print("SBI selected");
//     }
//   }
//
//
//   void _showDetailDialog(Map<String, String> rowData) {
//
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Name: ${rowData['name']}',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Icon(Icons.close, color: Colors.grey),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 8),
//                 Text('Date: ${rowData['date']}'),
//                 SizedBox(height: 16),
//                 ListTile(
//                   title: Text(' Whatsapp '),
//                   trailing: Text('Whatsapp: ${rowData['status']}'),
//                 ),
//                 Divider(),
//                 ListTile(
//                   title: Text('SMS'),
//                   trailing: Text('SMS: ${rowData['smsStatus']}'),
//                 ),
//                 Divider(),
//                 ListTile(
//                   title: Text('Email'),
//                   trailing: Text('Email: ${rowData['notificationType']}'),
//                 ),
//                 Divider(),
//                 ListTile(
//                   title: Text('Indiapost'),
//                   trailing: Text('Indiapost: ${rowData['processIndiaPost']}'),
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Column(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//
//                             String shortURL = rowData['shortURL'] ?? '';
//                             if (shortURL.isNotEmpty) {
//                               _openPDF(shortURL);
//                             } else {
//                               print('No URL found');
//                             }
//                           },
//                           child: Icon(Icons.picture_as_pdf, color: Colors.red),
//                         ),
//                         SizedBox(height: 4),
//                         Text('Notice Copy', style: TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Icon(Icons.picture_as_pdf, color: Colors.red),
//                         SizedBox(height: 4),
//                         Text('Tracking Details', style: TextStyle(fontSize: 12)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Files'),
//         backgroundColor: Colors.white,
//         elevation: 1,
//         titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: DataTable(
//             headingRowHeight: 40,
//             dataRowHeight: 60,
//             columnSpacing: 20,
//             headingRowColor: MaterialStateColor.resolveWith((states) => Colors.orange.shade100),
//             columns: [
//               DataColumn(label: Text('S. No.')),
//               DataColumn(label: Text('Name')),
//               DataColumn(label: Text('Mobile No.')),
//               DataColumn(label: Text('Account')),
//               DataColumn(label: Text('View')),
//             ],
//             rows: _notices.asMap().entries.map((entry) {
//               int index = entry.key + 1; // Serial number starts from 1
//               Notice notice = entry.value;
//               return DataRow(
//                 cells: [
//                   DataCell(Text(index.toString())),
//                   DataCell(Text(notice.data.name)),
//                   DataCell(Text(notice.data.mobileNumber.toString())),
//                   DataCell(Text(notice.data.account.toString())),
//                   DataCell(
//                     GestureDetector(
//                       onTap: () {
//                         _showDetailDialog({
//                           'name': notice.data.name,
//                           'date': notice.data.date,
//                           'status': notice.whatsappStatus,
//                           'smsStatus':notice.smsStatus,
//                           'notificationType':notice.notificationType,
//                           'processIndiaPost':notice.processIndiaPost,
//                           'shortURL': notice.shortURL,
//
//
//                         });
//                       },
//                       child: Text(
//                         'View More',
//                         style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
//                       ),
//                     ),
//                   ),
//                 ],
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         onTap: _onBottomNavigationTap,
//         selectedItemColor: Colors.purple,
//         unselectedItemColor: Colors.grey,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
//           BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Files'),
//           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
//           BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'SBI'),
//         ],
//       ),
//     );
//   }
//   void _openPDF(String url) async {
//     final result = await OpenFile.open(url);
//     if (result.type != ResultType.done) {
//       print('Error opening PDF file: ${result.message}');
//     }
//   }
// }
//
