import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:lms_practice/Logout_screen.dart';
import 'package:lms_practice/Tracking_screen.dart';
import 'package:lms_practice/login_screen.dart';
import 'dart:convert';

import 'package:lms_practice/upload_screen.dart';

import 'AddNewUser.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS Dashboard',
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

  final String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJfaWQiOiI2NjhiYWY0ZjJlNGUyNWI5ZTRmZThiN2YiLCJyb2xlIjoidXNlciIsImlhdCI6MTczMzgyMjk4OCwiZXhwIjoxNzM0NDI3Nzg4fQ.BuBjr2SlMBhyS2B3HV5PPHP8f5gGUsyV6I8A2It4O3U';

  @override
  void initState() {
    super.initState();
    fetchNoticeTypes();
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
      print('Error: $error'); // Debug print
      // showError('An error occurred: $error');
    }
  }

  Future<void> fetchData() async {
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
        foregroundColor: Color.fromRGBO(10,36,114,1),
        //textColor: Color.fromRGBO(10, 36, 114, 1),
        //               iconColor: Color.fromRGBO(10, 36, 114, 1),
        title: Text('LMS Dashboard'),


        // actions: [
        //   Builder(
        //     builder: (context) => IconButton(
        //       icon: Icon(Icons.menu),
        //       onPressed: () => Scaffold.of(context).openDrawer(),
        //     ),
        //   ),
        // ],
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
            ListTile(
              leading: Icon(Icons.dashboard_outlined),
              title: Text('Dashboard'),
              textColor: Color.fromRGBO(10, 36, 114, 1),
              iconColor: Color.fromRGBO(10, 36, 114, 1),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Dashboard
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Upload Data'),
              textColor: Color.fromRGBO(10, 36, 114, 1),
              iconColor: Color.fromRGBO(10, 36, 114, 1),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UploadScreen()),  // Navigate to UploadScreen
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.spatial_tracking),
              title: Text('Tracking'),
              textColor: Color.fromRGBO(10, 36, 114, 1),
              iconColor: Color.fromRGBO(10, 36, 114, 1),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrackingScreen()),  // Navigate to UploadScreen
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.fiber_new_rounded),
              title: Text("Add New User"),
              textColor: Color.fromRGBO(10, 36, 114, 1),
              iconColor: Color.fromRGBO(10, 36, 114, 1),
              onTap: (){
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context)=> AddNewUser()),
                );
              },

            ),

            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              textColor: Color.fromRGBO(10, 36, 114, 1),
              iconColor: Color.fromRGBO(10, 36, 114, 1),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LogoutScreen()),
                );
                // Navigator.push(context, MaterialPageRoute(builder: context)=>)
                // Handle logout
              },
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
                    child: Image.asset(
                      'assets/images/Untitled-4 2 (1).png',
                      height: 40,
                    ),
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
              backgroundColor: Colors.white,
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
