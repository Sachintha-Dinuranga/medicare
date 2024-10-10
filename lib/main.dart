import 'package:flutter/material.dart';
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
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
    );
  }
}
