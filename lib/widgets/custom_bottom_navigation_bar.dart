import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // Add shadow effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Shadow color
            spreadRadius: 1, // How much the shadow spreads
            blurRadius: 80, // Blurring of the shadow
            offset: const Offset(0, 1), // Horizontal and Vertical position
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: selectedIndex,
        height: 60.0,
        backgroundColor:
            Colors.transparent, // Keeps it transparent to reveal body content
        color: Colors
            .blue, // Background color of the curved bar        buttonBackgroundColor: const Color.fromARGB(255, 175, 128, 125), // Color of the center button
        animationDuration:
            const Duration(milliseconds: 300), // Animation duration
        animationCurve: Curves.easeInOut, // Animation curve for smooth effect
        onTap: onTabSelected, // Handle tab changes
        items: const [
          Center(
              child:
                  Icon(Icons.warning_rounded, size: 40, color: Colors.white)),
          Icon(Icons.history_edu_rounded, size: 40, color: Colors.white),
          Icon(Icons.person, size: 40, color: Colors.white),
        ],
      ),
    );
  }
}
