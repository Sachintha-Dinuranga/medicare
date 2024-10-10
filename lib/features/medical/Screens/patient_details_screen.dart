import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class AddPatientDetailsScreen extends StatefulWidget {
  const AddPatientDetailsScreen({super.key});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<AddPatientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();

  String? _selectedGender;
  final List<String> _genderOptions = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    // Get the logged-in user's email
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _emailController.text = user.email ?? '';
    }
  }

  Future<void> _savePatientDetails() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Save patient details to Firestore
        await FirebaseFirestore.instance.collection('patients').add({
          'fullName': _fullNameController.text,
          'dob': _dobController.text,
          'email': _emailController.text, // Pre-filled email
          'address': _addressController.text,
          'allergies': _allergiesController.text,
          'gender': _selectedGender,
          'medicalNotes': _medicalNotesController.text,
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient details saved successfully!')),
        );

        // Clear form after submission
        _formKey.currentState!.reset();
        setState(() {
          _selectedGender = null;
        });
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving patient details: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details Form'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Center(
                child: Text(
                  'Enter Patient Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _dobController,
                label: 'Date of Birth (DD/MM/YYYY)',
                icon: Icons.cake,
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                label: 'Email',
                icon: Icons.email,
                readOnly: true, // Make the email field uneditable
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.home,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies',
                icon: Icons.local_hospital,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: const Icon(Icons.wc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                ),
                items: _genderOptions.map((String gender) {
                  return DropdownMenuItem<String>(
                    value: gender,
                    child: Text(gender),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _medicalNotesController,
                label: 'Medical Notes',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    foregroundColor: Colors.blue,
                  ),
                  icon: const Icon(Icons.save),
                  label: const Text('Submit'),
                  onPressed: _savePatientDetails,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }
}
