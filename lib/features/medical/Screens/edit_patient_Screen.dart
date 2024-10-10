import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditPatientDetailsScreen extends StatefulWidget {
  final String documentId;
  final Map<String, dynamic> patientData;

  const EditPatientDetailsScreen({
    super.key,
    required this.documentId,
    required this.patientData,
  });

  @override
  _EditPatientDetailsScreenState createState() =>
      _EditPatientDetailsScreenState();
}

class _EditPatientDetailsScreenState extends State<EditPatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicalNotesController;

  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    // Populate the controllers with existing data
    _fullNameController =
        TextEditingController(text: widget.patientData['fullName']);
    _dobController = TextEditingController(text: widget.patientData['dob']);
    _addressController =
        TextEditingController(text: widget.patientData['address']);
    _allergiesController =
        TextEditingController(text: widget.patientData['allergies']);
    _medicalNotesController =
        TextEditingController(text: widget.patientData['medicalNotes']);
    _selectedGender = widget.patientData['gender'];
  }

  Future<void> _updatePatientDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Update patient details in Firestore
        await FirebaseFirestore.instance
            .collection('patients')
            .doc(widget.documentId)
            .update({
          'fullName': _fullNameController.text,
          'dob': _dobController.text,
          'address': _addressController.text,
          'allergies': _allergiesController.text,
          'gender': _selectedGender,
          'medicalNotes': _medicalNotesController.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient details updated successfully!')),
        );

        // Return to the previous screen with a success result
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating patient details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _dobController,
                decoration: const InputDecoration(labelText: 'Date of Birth'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the date of birth';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _allergiesController,
                decoration: const InputDecoration(labelText: 'Allergies'),
              ),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: _genderOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _medicalNotesController,
                decoration: const InputDecoration(labelText: 'Medical Notes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePatientDetails,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text('Update Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
