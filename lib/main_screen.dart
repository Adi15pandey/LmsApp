// import 'package:lms_practice/consolidated_screen.dart';
// import 'package:lms_practice/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart'; // Add this import for custom fonts
// import 'SearchResultScreen.dart';
// import 'dashboard_screen.dart';
// import 'files_screen.dart';
// import 'sbi_screen.dart';
// import 'searchscreen.dart';
//
// class MainScreen extends StatefulWidget {
//   @override
//   _MainScreenState createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//
//   static final List<Widget> _widgetOptions = <Widget>[
//     DashboardScreen(),
//     FilesScreen(),
//     SearchScreen(),
//     // SBIScreen(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _widgetOptions.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         items: <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.dashboard_outlined),
//             label: 'Dashboard',
//             backgroundColor: Colors.grey,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.file_copy),
//             label: 'Files',
//             backgroundColor: Colors.grey,
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.search),
//             label: 'Search',
//             backgroundColor: Colors.grey,
//           ),
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.account_balance),
//           //   label: 'SBI',
//           //   backgroundColor: Colors.grey,
//           // ), // Uncomment if needed
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.blue[900],
//         unselectedItemColor: Colors.grey,
//         onTap: _onItemTapped,
//         selectedLabelStyle: GoogleFonts.poppins(
//           textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//         ), // Custom font style for selected labels
//         unselectedLabelStyle: GoogleFonts.poppins(
//           textStyle: TextStyle(fontSize: 14),
//         ), // Custom font style for unselected labels
//       ),
//     );
//   }
// }
import 'package:lms_practice/consolidated_screen.dart';
import 'package:lms_practice/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import for custom fonts
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: 'Files',
            backgroundColor: Colors.grey,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
            backgroundColor: Colors.grey,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.account_balance),
          //   label: 'SBI',
          //   backgroundColor: Colors.grey,
          // ), // Uncomment if needed
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[900],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        selectedLabelStyle: GoogleFonts.poppins(
          textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ), // Custom font style for selected labels
        unselectedLabelStyle: GoogleFonts.poppins(
          textStyle: TextStyle(fontSize: 14),
        ), // Custom font style for unselected labels
      ),
    );
  }
}

