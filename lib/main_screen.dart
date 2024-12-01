
import 'package:lms_practice/login_screen.dart';

import 'package:flutter/material.dart';
import 'SearchResultScreen.dart';
import 'dashboard_screen.dart';
import 'files_screen.dart';
import 'sbi_screen.dart';
import 'searchscreen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    FilesScreen(),

    SearchScreen(),
    // SBIScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
              backgroundColor: Colors.grey
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.folder),
              label: 'Files',
              backgroundColor: Colors.grey

          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
              backgroundColor: Colors.grey
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_balance),
          //   label: 'SBI',
          //     backgroundColor: Colors.grey
          // ),

        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
      ),
    );
  }
}
