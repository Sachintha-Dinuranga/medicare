import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart'; // For scanning QR codes
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medicare/features/medical/Screens/edit_patient_Screen.dart';
import 'package:medicare/features/medical/Screens/generate_qr_code.dart';

class ViewPatientDetailsScreen extends StatefulWidget {
  const ViewPatientDetailsScreen({super.key});

  @override
  _ViewPatientDetailsScreenState createState() =>
      _ViewPatientDetailsScreenState();
}

class _ViewPatientDetailsScreenState extends State<ViewPatientDetailsScreen> {
  Map<String, dynamic>? patientData;
  bool isLoading = true;
  String? documentId; // Store document ID for updates

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
            documentId = snapshot.docs[0].id; // Store document ID for updates
            isLoading = false;
          });
        } else {
          setState(() {
            patientData = null;
            isLoading = false;
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching patient details: $e')),
        );
      }
    }
  }

  Future<void> _scanQR() async {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: Colors.blue,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : patientData == null
              ? const Center(child: Text('No patient details found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildDetailCard(
                          'Full Name', patientData!['fullName'], Icons.person),
                      _buildDetailCard(
                          'Date of Birth', patientData!['dob'], Icons.cake),
                      _buildDetailCard(
                          'Email', patientData!['email'], Icons.email),
                      _buildDetailCard(
                          'Address', patientData!['address'], Icons.location_on),
                      _buildDetailCard('Allergies', patientData!['allergies'],
                          Icons.warning),
                      _buildDetailCard(
                          'Gender', patientData!['gender'], Icons.wc),
                      _buildDetailCard('Medical Notes',
                          patientData!['medicalNotes'], Icons.note),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => GenerateQRScreen(
                                    patientData: patientData!),
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code),
                          label: const Text('Generate QR Code'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _scanQR,
                          icon: const Icon(Icons.qr_code_scanner),
                          label: const Text('Scan QR Code'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPatientDetailsScreen(
                                  documentId: documentId!,
                                  patientData: patientData!,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Edit Details'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.blue,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.blue),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientData!['fullName'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  patientData!['email'],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}


// New screen to display scanned QR code data
class ScannedDataScreen extends StatelessWidget {
  final String scannedData;

  const ScannedDataScreen({super.key, required this.scannedData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanned Data'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Scanned QR Data:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                scannedData,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to previous screen
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
