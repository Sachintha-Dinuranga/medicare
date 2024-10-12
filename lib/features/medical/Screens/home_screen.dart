import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'patient_details_screen.dart';
import 'view_patient_details.dart';
import '../../reminder/reminder_list.dart';
import '../../map_feature/screens/first_screen.dart';
import '../../../screens/sos_screen.dart';
import 'generate_qr_code.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientDetails();
  }

  Future<void> _fetchPatientDetails() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('patients')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            patientData = snapshot.docs[0].data() as Map<String, dynamic>;
            isLoading = false;
          });
        } else {
          setState(() {
            patientData = null;
            isLoading = false;
          });
        }
      } catch (e) {
        print(e);
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _scanQR(BuildContext context) async {
    try {
      var result = await BarcodeScanner.scan(); // Start scanning
      String scannedQrData = result.rawContent; // Store scanned data
      // Navigate to ScannedDataScreen with scanned data
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScannedDataScreen(scannedData: scannedQrData),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to scan QR code: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Home Screen'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loader
          : Center(
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
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your Personal Health Management',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 40),
                  if (patientData != null) ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          (2 / 3), // 2/3 of the screen width
                      height: MediaQuery.of(context).size.height *
                          (1 / 7), // 1/5 of the screen height
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  GenerateQRScreen(patientData: patientData!),
                            ),
                          );
                        },
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Generate QR Code'),
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.blue, width: 2), // Blue border
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                          ),
                          backgroundColor: Colors.white, // White background
                          foregroundColor: Colors.blue, // Blue text/icon color
                        ),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: MediaQuery.of(context).size.width *
                          (2 / 3), // 2/3 of the screen width
                      height: MediaQuery.of(context).size.height *
                          (1 / 7), // 1/5 of the screen height
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const AddPatientDetailsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add patient details'),
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.blue,
                            width: 2, // Blue border
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // Rounded corners
                          ),
                          backgroundColor: Colors.white, // White background
                          foregroundColor: Colors.blue, // Blue text/icon color
                        ),
                      ),
                    )
                  ],
                  SizedBox(
                    height: 60,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width *
                        (2 / 3), // 2/3 of the screen width
                    height: MediaQuery.of(context).size.height *
                        (1 / 7), // 1/5 of the screen height
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _scanQR(context);
                      },
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan QR Code'),
                      style: ElevatedButton.styleFrom(
                        side: const BorderSide(
                            color: Colors.blue, width: 2), // Blue border
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(20), // Rounded corners
                        ),
                        backgroundColor: Colors.white, // White background
                        foregroundColor: Colors.blue, // Blue text/icon color
                      ),
                    ),
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
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Add Patient Details'),
              onTap: () {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SosScreen()),
                );
              },
            ),
            const Spacer(),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
