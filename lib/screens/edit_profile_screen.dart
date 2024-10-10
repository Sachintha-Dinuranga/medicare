import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // For formatting date

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  File? _profileImage;
  String? _selectedBloodGroup;
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Load the saved profile data from SharedPreferences
  }

  // Load saved profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('name') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _allergiesController.text = prefs.getString('allergies') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      _weightController.text = prefs.getString('weight') ?? '';
      _birthdayController.text = prefs.getString('birthdate') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
      _selectedBloodGroup =
          prefs.getString('blood_group') ?? _bloodGroups.first;
      String? profileImagePath = prefs.getString('profile_image');
      if (profileImagePath != null) {
        _profileImage = File(profileImagePath); // Load saved image
      }
    });
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // Save updated profile data to SharedPreferences
  Future<void> _saveProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', _nameController.text);
    await prefs.setString('phone', _phoneController.text);
    await prefs.setString('blood_group', _selectedBloodGroup ?? '');
    await prefs.setString('allergies', _allergiesController.text);
    await prefs.setString('height', _heightController.text);
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('birthdate', _birthdayController.text);
    await prefs.setString('address', _addressController.text);

    if (_profileImage != null) {
      await prefs.setString('profile_image', _profileImage!.path);
    }
    Navigator.pop(context, 'updated'); // Return to ProfileScreen
  }

  // Delete profile data from SharedPreferences
  Future<void> _deleteProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all the saved data
    Navigator.pop(context, 'updated'); // Return to ProfileScreen
  }

  // Show the date picker to select the birthday
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_birthdayController.text.isNotEmpty) {
      initialDate = DateFormat('yyyy-MM-dd').parse(_birthdayController.text);
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _birthdayController.text = DateFormat('yyyy-MM-dd')
            .format(pickedDate); // Format and set the selected date
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 24),
              const Text('Health Profile.',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              const SizedBox(height: 1),
              const Text('To keep you safe we get those',
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 20),

              // Profile Image + Form fields layout
              Row(
                children: [
                  // Profile Image
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      backgroundColor: Colors.grey,
                      child: _profileImage == null
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Name Field
                  Expanded(
                    child: _buildTextField(_nameController, 'Name'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Address Field
              _buildTextField(_addressController, 'Address'),
              const SizedBox(height: 16),

              // Phone Number and Blood Group in one row
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_phoneController, 'Phone Number',
                          keyboardType: TextInputType.number)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: _buildInputDecoration('Blood Group'),
                      value: _selectedBloodGroup,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedBloodGroup = newValue!;
                        });
                      },
                      items: _bloodGroups.map((String bloodGroup) {
                        return DropdownMenuItem<String>(
                          value: bloodGroup,
                          child: Text(bloodGroup),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Allergies Field
              _buildTextField(
                  _allergiesController, 'Allergies (Additional Notes)'),
              const SizedBox(height: 16),

              // Height and Weight in one row
              Row(
                children: [
                  Expanded(
                      child: _buildTextField(_heightController, 'Height (cm)')),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildTextField(_weightController, 'Weight (Kg)')),
                ],
              ),
              const SizedBox(height: 16),

              // Birthday Field (with calendar picker)
              GestureDetector(
                onTap: () => _selectDate(context), // Show Date Picker
                child: AbsorbPointer(
                  // Prevent keyboard from appearing
                  child: _buildTextField(_birthdayController, 'Birthday'),
                ),
              ),
              const SizedBox(height: 40),

              // Save Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _saveProfileData(); // Save updated profile data
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save my profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(height: 16),

              // Delete Profile Button
              ElevatedButton(
                onPressed: _deleteProfile, // Clear profile data
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Delete my profile',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build text fields
  TextFormField _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      decoration: _buildInputDecoration(label),
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  // Input decoration for fields
  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
