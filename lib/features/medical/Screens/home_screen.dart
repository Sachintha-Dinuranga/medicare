import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/features/medical/Screens/patient_details_screen.dart';
import 'package:medicare/features/medical/Screens/view_patient_details.dart';
import 'package:medicare/features/reminder/reminder_list.dart';
import 'package:medicare/features/map_feature/screens/first_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: Text('Hello, ${user?.email ?? 'Guest'}!'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Patient Details'),
              onTap: () {
                // Navigate to PatientDetailsScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AddPatientDetailsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('View Patient Details'),
              onTap: () {
                // Navigate to PatientDetailsScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViewPatientDetailsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.timelapse),
              title: const Text('Reminders'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReminderList()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FirstScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sos),
              title: const Text('SOS'),
              onTap: () {
                Navigator.of(context).pushReplacementNamed('/sos');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
          ],
        ),
      ),
    );
  }
}
