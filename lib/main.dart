import 'package:flutter/material.dart';
// import 'package:medicare/features/reminder/home.dart';
import 'package:medicare/features/map_feature/screens/first_screen.dart';
import 'package:medicare/features/reminder/notification_service.dart';
//import 'package:medicare/features/reminder/reminder_list.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert'; // For encoding and decoding JSON
// import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the notification service
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstScreen(),
    );
  }
}
