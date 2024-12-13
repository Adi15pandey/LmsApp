import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:lms_practice/Logout_screen.dart';
import 'package:lms_practice/Tracking_screen.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:lms_practice/upload_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AddNewUser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // title: 'LMS Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController startDateController = TextEditingController();
  final TextEditingController endDateController = TextEditingController();
  List<String> noticeTypes = ['All'];
  String selectedNoticeType = 'All';

  int totalRecords = 0;
  Map<String, int> noticeTypeCount = {};
  String?token;


  // final String token =
  //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgyMjk4OCwiZXhwIjoxNzM0NDI3Nzg4fQ.BuBjr2SlMBhyS2B3HV5PPHP8f5gGUsyV6I8A2It4O3U';

  @override
  void initState() {
    super.initState();
    fetchToken();
    fetchNoticeTypes();
  }
  Future<void> fetchToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedToken = prefs.getString('auth_token'); // Retrieve the saved token

    if (savedToken != null) {
      setState(() {
        token = savedToken;
      });
    } else {
      print('Token not found'); // Token is not availabl
      // Handle token not found case if needed (e.g., show error, redirect to login, etc.)
    }
  }


  Future<void> fetchNoticeTypes() async {
    final url = 'https://lms.recqarz.com/api/clientMapping/user';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Notice types data: $data'); // Debug print
        setState(() {
          noticeTypes = ['All'];
          noticeTypes.addAll(List<String>.from(data['data'] ?? []));
          print('Notice types updated: $noticeTypes'); // Debug print
        });
      } else {
        print('Failed to load notice types: ${response.statusCode}'); // Debug print
        // showError('Failed to load notice types: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> fetchData() async {
    if(token==null){
      print("Token not  Found");
      return;
    }else print(" Token found");
    final startDate = startDateController.text.isNotEmpty
        ? startDateController.text
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    final endDate = endDateController.text.isNotEmpty
        ? endDateController.text
        : DateFormat('yyyy-MM-dd').format(DateTime.now());
    final noticeType = selectedNoticeType;

    final url = 'https://lms.recqarz.com/api/dashboard/getDataByClientId?clientId=NotALL'
        '&dateRange=${startDate.isNotEmpty && endDate.isNotEmpty ? '$startDate,$endDate' : ''}'
        '&serviceType=all'
        '&dateType=fileProcessed'
        '&noticeType=${noticeType != 'All' ? noticeType : ''}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          final noticeTypeTotalCount = data['data']['noticeTypeTotalCount'] ?? {};
          noticeTypeCount = Map<String, int>.from(noticeTypeTotalCount.map(
                (key, value) => MapEntry(key, value is num ? value.toInt() : value),
          ));
          totalRecords = noticeTypeCount.values.fold(0, (sum, count) => sum + count);
        });
      } else {
        print('Failed to load data: ${response.statusCode}');
        // showError('Failed to load data: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error'); // Debug print
      // showError('An error occurred: $error');
    }
  }

  // void showError(String message) {
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(
  //       content: Text(message),
  //       backgroundColor: Colors.red,
  //     ),
  //   );
  // }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color.fromRGBO(10, 36, 114, 1),
        title: Padding(
          padding: const EdgeInsets.only(right:40), // Adjust the value as needed
          child: Image.asset(
            'assets/images/Untitled-4 2 (1).png',
            height: 35, // Adjust the height according to your needs
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(),
            ),
            ListTileTheme(
              textColor: Color.fromRGBO(10, 36, 114, 1),
              iconColor: Color.fromRGBO(10, 36, 114, 1),
              style: ListTileStyle.drawer,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.dashboard_outlined),
                    title: Text(
                      'Dashboard',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to Dashboard
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.upload_file),
                    title: Text(
                      'Upload Data',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UploadScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.spatial_tracking),
                    title: Text(
                      'Tracking',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TrackingScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.fiber_new_rounded),
                    title: Text(
                      'Add New User',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AddNewUser()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text(
                      'Logout',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LogoutScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 01, left: 5),
                    // child: Image.asset(
                    //   'assets/images/Untitled-4 2 (1).png',
                    //   height: 40,
                    // ),
                  ),
                  SizedBox(height: 15),
                  _buildFilterSection(constraints),
                  SizedBox(height: 20),
                  _buildStatisticsSection(constraints),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


  Widget _buildFilterSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField('Start Date', startDateController, constraints),
        SizedBox(height: 10),
        _buildDateField('End Date', endDateController, constraints),
        SizedBox(height: 10),
        _buildNoticeTypeField('Notice Type', constraints),
        SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: fetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white12,
            ),
            child: Text('Search'),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, TextEditingController controller, BoxConstraints constraints) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: AbsorbPointer(
        child: Container(
          width: constraints.maxWidth > 600 ? 400 : double.infinity,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () => _selectDate(context, controller),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeTypeField(String label, BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth > 600 ? 400 : double.infinity,
      child: DropdownButtonFormField<String>(
        value: selectedNoticeType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: (String? newValue) {
          setState(() {
            selectedNoticeType = newValue!;
          });
        },
        items: noticeTypes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatisticsSection(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTotalRecords(constraints),
        SizedBox(height: 20),
        _buildNoticeTypeCard(constraints),
      ],
    );
  }

  Widget _buildTotalRecords(BoxConstraints constraints) {
    return Center(
      child: Center(
        child: Container(
          width: constraints.maxWidth > 600 ? 400 : double.infinity,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color.fromRGBO(101, 85, 143, 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Total Records: $totalRecords',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoticeTypeCard(BoxConstraints constraints) {
    return Container(
      width: constraints.maxWidth > 600 ? 400 : double.infinity,
      decoration: BoxDecoration(
        color: Color.fromRGBO(243, 237, 247, 1),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(243, 237, 247, 1),
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Notice Type Total Count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Divider(color: Color.fromRGBO(243, 237, 247, 1)),
          Column(
            children: noticeTypeCount.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:http/http.dart' as http;
// import 'package:lms_practice/Logout_screen.dart';
// import 'package:lms_practice/Tracking_screen.dart';
// import 'package:lms_practice/login_screen.dart';
// import 'dart:convert';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:lms_practice/upload_screen.dart';
// import 'AddNewUser.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       debugShowCheckedModeBanner: false,
//       home: DashboardScreen(),
//     );
//   }
// }
//
// class DashboardScreen extends StatefulWidget {
//   @override
//   _DashboardScreenState createState() => _DashboardScreenState();
// }
//
// class _DashboardScreenState extends State<DashboardScreen> {
//   final TextEditingController startDateController = TextEditingController();
//   final TextEditingController endDateController = TextEditingController();
//   List<String> noticeTypes = ['All'];
//   String selectedNoticeType = 'All';
//
//   int totalRecords = 0;
//   Map<String, int> noticeTypeCount = {};
//
//   String? token; // Token will be retrieved from SharedPreferences
//
//   @override
//   void initState() {
//     super.initState();
//     _getToken();
//     fetchNoticeTypes();
//   }
//
//   Future<void> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       token = prefs.getString('auth_token');
//     });
//   }
//
//   Future<void> fetchNoticeTypes() async {
//     if (token == null) {
//       // If no token found, redirect to login screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//       return;
//     }
//
//     final url = 'https://lms.recqarz.com/api/clientMapping/user';
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           noticeTypes = ['All'];
//           noticeTypes.addAll(List<String>.from(data['data'] ?? []));
//         });
//       } else {
//         print('Failed to load notice types: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//   }
//
//   Future<void> fetchData() async {
//     if (token == null) {
//       // If no token found, redirect to login screen
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//       );
//       return;
//     }
//
//     final startDate = startDateController.text.isNotEmpty
//         ? startDateController.text
//         : DateFormat('yyyy-MM-dd').format(DateTime.now());
//     final endDate = endDateController.text.isNotEmpty
//         ? endDateController.text
//         : DateFormat('yyyy-MM-dd').format(DateTime.now());
//     final noticeType = selectedNoticeType;
//
//     final url = 'https://lms.recqarz.com/api/dashboard/getDataByClientId?clientId=NotALL'
//         '&dateRange=${startDate.isNotEmpty && endDate.isNotEmpty ? '$startDate,$endDate' : ''}'
//         '&serviceType=all'
//         '&dateType=fileProcessed'
//         '&noticeType=${noticeType != 'All' ? noticeType : ''}';
//
//     try {
//       final response = await http.get(
//         Uri.parse(url),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           final noticeTypeTotalCount = data['data']['noticeTypeTotalCount'] ?? {};
//           noticeTypeCount = Map<String, int>.from(noticeTypeTotalCount.map(
//                 (key, value) => MapEntry(key, value is num ? value.toInt() : value),
//           ));
//           totalRecords = noticeTypeCount.values.fold(0, (sum, count) => sum + count);
//         });
//       } else {
//         print('Failed to load data: ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error: $error');
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         controller.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         foregroundColor: Color.fromRGBO(10, 36, 114, 1),
//         title: Padding(
//           padding: const EdgeInsets.only(right: 40),
//           child: Image.asset(
//             'assets/images/Untitled-4 2 (1).png',
//             height: 35,
//           ),
//         ),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: AssetImage('assets/images/bg.jpg'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//               child: Container(),
//             ),
//             ListTileTheme(
//               textColor: Color.fromRGBO(10, 36, 114, 1),
//               iconColor: Color.fromRGBO(10, 36, 114, 1),
//               style: ListTileStyle.drawer,
//               child: Column(
//                 children: [
//                   ListTile(
//                     leading: Icon(Icons.dashboard_outlined),
//                     title: Text(
//                       'Dashboard',
//                       style: GoogleFonts.roboto(
//                         textStyle: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.upload_file),
//                     title: Text(
//                       'Upload Data',
//                       style: GoogleFonts.roboto(
//                         textStyle: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => UploadScreen()),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.spatial_tracking),
//                     title: Text(
//                       'Tracking',
//                       style: GoogleFonts.roboto(
//                         textStyle: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(builder: (context) => TrackingScreen()),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.fiber_new_rounded),
//                     title: Text(
//                       'Add New User',
//                       style: GoogleFonts.roboto(
//                         textStyle: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => AddNewUser()),
//                       );
//                     },
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.logout),
//                     title: Text(
//                       'Logout',
//                       style: GoogleFonts.roboto(
//                         textStyle: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     onTap: () {
//                       Navigator.pop(context);
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (context) => LogoutScreen()),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           return SingleChildScrollView(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 15),
//                   _buildFilterSection(constraints),
//                   SizedBox(height: 20),
//                   _buildStatisticsSection(constraints),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildFilterSection(BoxConstraints constraints) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildDateField('Start Date', startDateController, constraints),
//         SizedBox(height: 10),
//         _buildDateField('End Date', endDateController, constraints),
//         SizedBox(height: 10),
//         _buildNoticeTypeField('Notice Type', constraints),
//         SizedBox(height: 20),
//         Center(
//           child: ElevatedButton(
//             onPressed: fetchData,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white,
//               side: BorderSide(color: Color.fromRGBO(10, 36, 114, 1)),
//             ),
//             child: Text(
//               'Apply Filter',
//               style: GoogleFonts.roboto(
//                 textStyle: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color.fromRGBO(10, 36, 114, 1),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDateField(String label, TextEditingController controller, BoxConstraints constraints) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label,
//             style: GoogleFonts.roboto(
//               textStyle: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             )),
//         SizedBox(
//           width: constraints.maxWidth * 0.5,
//           child: TextField(
//             controller: controller,
//             readOnly: true,
//             decoration: InputDecoration(
//               hintText: 'Select Date',
//               suffixIcon: IconButton(
//                 icon: Icon(Icons.calendar_today),
//                 onPressed: () => _selectDate(context, controller),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNoticeTypeField(String label, BoxConstraints constraints) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label,
//             style: GoogleFonts.roboto(
//               textStyle: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             )),
//         DropdownButton<String>(
//           value: selectedNoticeType,
//           items: noticeTypes.map((String noticeType) {
//             return DropdownMenuItem<String>(
//               value: noticeType,
//               child: Text(noticeType),
//             );
//           }).toList(),
//           onChanged: (value) {
//             setState(() {
//               selectedNoticeType = value!;
//             });
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildStatisticsSection(BoxConstraints constraints) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Statistics',
//             style: GoogleFonts.roboto(
//               textStyle: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             )),
//         SizedBox(height: 10),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(8),
//             color: Color.fromRGBO(10, 36, 114, 1),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Total Records: $totalRecords',
//                   style: GoogleFonts.roboto(
//                     textStyle: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                     ),
//                   )),
//               SizedBox(height: 10),
//               _buildNoticeTypeCounts(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildNoticeTypeCounts() {
//     return Column(
//       children: noticeTypeCount.entries.map((entry) {
//         return Text(
//           '${entry.key}: ${entry.value}',
//           style: GoogleFonts.roboto(
//             textStyle: TextStyle(
//               fontSize: 16,
//               color: Colors.white,
//             ),
//           ),
//         );
//       }).toList(),
//     );
//   }
// }

