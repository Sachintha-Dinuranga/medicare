import 'package:flutter/material.dart';
import 'sos_screen.dart';
import 'profile_screen.dart';
import 'history_screen.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  // List of screens corresponding to each tab in the bottom navigation bar
  final List<Widget> _screens = [
    SosScreen(), // SOS Home Screen
    HistoryScreen(), // History Screen
    ProfileScreen(), // Profile Screen
  ];

  // Function to handle tab switching
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens, // Keeps state of all screens
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onTabSelected, // Handle tab selection
      ),
    );
  }
}
