import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:medicare/features/reminder/notification_service.dart';
import 'package:medicare/features/medical/Screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'package:medicare/features/reminder/home.dart';
//import 'package:medicare/features/map_feature/screens/first_screen.dart';
//import 'package:medicare/features/reminder/reminder_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert'; // For encoding and decoding JSON
// import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    await NotificationService.initialize();
  } catch (e) {
    print('Error initializing Firebase or Notification Service: $e');
  }

  runApp(const MyApp());
=======
import 'package:ueehe/screens/edit_profile_screen.dart';
import 'package:ueehe/screens/essential_info_form_screen.dart';
import 'package:ueehe/screens/sos_screen.dart';
import 'package:ueehe/screens/splash_screen.dart';
import 'package:ueehe/screens/welcome_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ueehe/screens/EmergencyContactsScreen.dart';

/// The main entrypoint for the application. It initializes the Flutter engine
/// and runs the [MyApp] widget.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
>>>>>>> origin/hasindu
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
=======
    return MaterialApp(
      title: 'Emergency App',
      theme: ThemeData(textTheme: GoogleFonts.interTextTheme()),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/essentialForm': (context) => EssentialInfoFormScreen(),
        '/sos': (context) => SosScreen(),
        '/editProfile': (context) => EditProfileScreen(),
        '/emegencyContacts': (context) => EmergencyContactsScreen(),
      },
>>>>>>> origin/hasindu
    );
  }
}
