import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Show splash screen for 3 seconds before checking user info
    Timer(const Duration(seconds: 3), () {
      _checkUserInfo(context);
    });

    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo or App Icon
            Image.asset(
              'assets/images/uee_logo.png', // Path to your logo asset
              height: 250, // Adjust height as needed
            ),
            const SizedBox(height: 40), // Spacing between image and text

            // App Name
            const Text(
              'MediCare',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            // App Tagline
            const Text(
              'Your trusted partner in emergency, \nproviding immediate support',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(137, 60, 60, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Check if user info or skip status is stored in SharedPreferences
  Future<void> _checkUserInfo(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if user profile is created or if they skipped profile creation
    bool profileCreated = prefs.containsKey('fullName');
    bool profileSkipped = prefs.getBool('profileSkipped') ?? false;

    if (profileCreated || profileSkipped) {
      // Navigate to SOS screen if profile is created or skipped
      Navigator.pushReplacementNamed(context, '/sos');
    } else {
      // Navigate to Welcome screen if no profile data is found
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }
}
