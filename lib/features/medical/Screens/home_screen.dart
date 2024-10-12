import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_details_screen.dart';
import 'view_patient_details.dart';
import '../../reminder/reminder_list.dart';
import '../../map_feature/screens/first_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Home Screen'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.medical_services,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.email ?? 'Guest'}!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your Personal Health Management',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              accountName: Text(user?.displayName ?? 'Patient'),
              accountEmail: Text(user?.email ?? 'guest@example.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.blue,
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
                  MaterialPageRoute(builder: (context) => const ReminderList()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FirstScreen()),
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
            const Spacer(), // Pushes the logout button to the bottom
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/');
              },
            ),
            const SizedBox(height: 20), // Extra spacing at the bottom
          ],
        ),
      ),
    );
  }
}
