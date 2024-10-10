import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const GenerateQRScreen({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    String qrData =
        'Name: ${patientData['fullName']}\nEmail: ${patientData['email']}\n'
        'DOB: ${patientData['dob']}\nAddress: ${patientData['address']}\n'
        'Allergies: ${patientData['allergies']}\nGender: ${patientData['gender']}\n'
        'Medical Notes: ${patientData['medicalNotes']}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'My QR Code',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
                height: 20), // Adding space between title and QR code
            Container(
              padding: const EdgeInsets.all(20.0), // Padding inside the frame
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Color of the frame
                  width: 3.0, // Thickness of the frame
                ),
                borderRadius: BorderRadius.circular(
                    10.0), // Rounded corners for the frame
              ),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
