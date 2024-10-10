import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class ViewPatientDetailsScreen extends StatefulWidget {
  const ViewPatientDetailsScreen({super.key});

  @override
  State<ViewPatientDetailsScreen> createState() => _ViewPatientDetailsScreenState();
}

class _ViewPatientDetailsScreenState extends State<ViewPatientDetailsScreen> {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching patient details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        backgroundColor: Colors.teal,
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
                      _buildDetailCard('Full Name', patientData!['fullName'], Icons.person),
                      _buildDetailCard('Date of Birth', patientData!['dob'], Icons.cake),
                      _buildDetailCard('Email', patientData!['email'], Icons.email),
                      _buildDetailCard('Address', patientData!['address'], Icons.location_on),
                      _buildDetailCard('Allergies', patientData!['allergies'], Icons.warning),
                      _buildDetailCard('Gender', patientData!['gender'], Icons.wc),
                      _buildDetailCard('Medical Notes', patientData!['medicalNotes'], Icons.note),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    return Card(
      color: Colors.teal,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.teal),
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

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.teal),
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }
}
