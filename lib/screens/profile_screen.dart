import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _name = "Your name";
  String? _birthdate = "-- No Date given--";
  String? _bloodType = "--";
  String? _height = "--";
  String? _weight = "--";
  String? _address = "--";
  String? _phoneNumber = "--";
  String? _gender = "--";
  String? _allergies = "--";
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Load profile data from SharedPreferences
  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _name = prefs.getString('name') ?? _name;
      _birthdate = prefs.getString('birthdate') ?? _birthdate;
      _bloodType = prefs.getString('blood_group') ?? _bloodType;
      _height = prefs.getString('height') ?? _height;
      _weight = prefs.getString('weight') ?? _weight;
      _address = prefs.getString('address') ?? _address;
      _phoneNumber = prefs.getString('phone') ?? _phoneNumber;
      _gender = prefs.getString('gender') ?? _gender;
      _allergies = prefs.getString('allergies') ?? _allergies;
      _profileImagePath = prefs.getString('profile_image');
    });
  }

  // Navigate to edit profile screen and refresh when returning
  Future<void> _editProfile() async {
    final result = await Navigator.pushNamed(context, '/editProfile');
    if (result == 'updated') {
      _loadProfileData(); // Reload the data when the profile is updated
    }
  }

  @override

  /// Builds the ProfileScreen UI.
  ///
  /// Displays the user's health profile data, with options to edit the profile.
  /// The screen also displays general information about the user, such as their
  /// address, phone number, and allergies.
  ///
  /// The UI is organized into sections for the user's health profile and extra
  /// information. The health profile section displays the user's name, birthdate,
  /// blood type, height, and weight. The extra information section displays the
  /// user's address, phone number, gender, and allergies.
  ///
  /// The screen also includes an "Edit Profile" button in the top right corner,
  /// which navigates to the [EditProfileScreen] when pressed.
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              // Health Profile Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Health Profile",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      border: Border.all(
                        color: Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: IconButton(
                      onPressed: _editProfile,
                      icon: const Icon(Icons.edit),
                      iconSize: 25,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(
                thickness: 1,
                color: Color.fromARGB(96, 158, 158, 158),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 20),

              // Profile Image
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.red[300],
                  backgroundImage: _profileImagePath != null
                      ? FileImage(File(_profileImagePath!))
                      : null,
                  child: _profileImagePath == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Name and Birthdate
              Center(
                child: Column(
                  children: [
                    Text(
                      _name ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Birthday: ${_birthdate ?? ''}',
                      semanticsLabel: _birthdate ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Blood Type, Height, Weight in a Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHealthData("Blood T", _bloodType ?? ''),
                  _buildHealthData("Height", '${_height ?? ''}cm'),
                  _buildHealthData("Weight", '${_weight ?? ''}Kg'),
                ],
              ),
              const SizedBox(height: 30),

              // Extra Information Section
              const Text(
                "Extra Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Address, Phone, Gender
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildExtraInfo(Icons.location_on, _address ?? ''),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildExtraInfo(Icons.phone, _phoneNumber ?? ''),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildExtraInfo(Icons.person, _gender ?? ''),
              ),
              const SizedBox(height: 30),

              // General Information Section (Allergies)
              const Text(
                "General Information",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _allergies ?? 'Allergies (Additional Notes)',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// A widget to display a health data item (e.g. blood type, height, weight).
  ///
  /// Shows a bolded [title] followed by the [value] below it.
  ///
  /// Useful for displaying health data in a consistent format.
  Widget _buildHealthData(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  /// A widget to display extra information about the user.
  ///
  /// This widget takes an [icon] and an [info] string, and displays them in a
  /// row, with the icon to the left of the text. The row is padded by 8px
  /// vertically.
  ///
  /// Useful for displaying extra information such as the user's address, phone
  /// number, or gender.
  Widget _buildExtraInfo(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.redAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
