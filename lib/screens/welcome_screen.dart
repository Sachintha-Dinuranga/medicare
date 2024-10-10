import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // App Icon or Illustration (Center)
              Image.asset(
                'assets/images/uee_logo.png', // Path to your logo asset
              ),

              const SizedBox(height: 30),

              // App Name
              const Text(
                "MedCare",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              // Tagline
              const SizedBox(height: 10),
              const Text(
                "Your trusted partner in emergencies, providing immediate support.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

              const Spacer(),

              // Get Started Button
              ElevatedButton(
                onPressed: () async {
                  // Store that the user has seen the welcome screen
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('hasSeenWelcome', true);

                  // Navigate to the Essential Info Form screen
                  Navigator.pushReplacementNamed(context, '/essentialForm');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Button color
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Skip Button (Skip profile creation and go to SOS screen)
              GestureDetector(
                onTap: () async {
                  // Store that the user has seen the welcome screen and skipped profile creation
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('profileSkipped', true);
                  await prefs.setBool('hasSeenWelcome', true);

                  // Navigate to SOS screen
                  Navigator.pushReplacementNamed(context, '/sos');
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
