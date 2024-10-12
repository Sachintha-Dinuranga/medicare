import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/welcome_screen.dart';
import '../screens/main_app_screen.dart'; // Import the main app screen

class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String mainApp = '/main'; // Main screen for bottom navigation

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => WelcomeScreen());
      case mainApp:
        return MaterialPageRoute(builder: (_) => MainAppScreen());
      default:
        return MaterialPageRoute(builder: (_) => SplashScreen());
    }
  }
}
