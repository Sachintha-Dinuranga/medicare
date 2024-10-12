import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  _EmergencyContactsScreenState createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  List<Map<String, String>> _emergencyContacts = []; // List to store contacts

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts(); // Load contacts on startup
  }

  // Load emergency contacts from SharedPreferences
  Future<void> _loadEmergencyContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedContacts = prefs.getStringList('emergencyContacts') ?? [];
    setState(() {
      _emergencyContacts = savedContacts
          .map((contactJson) => Map<String, String>.from(
              Map<String, dynamic>.from(_decodeJson(contactJson))))
          .toList();
    });
  }

  // Save emergency contacts to SharedPreferences
  Future<void> _saveEmergencyContacts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> contactJsonList =
        _emergencyContacts.map((contact) => _encodeJson(contact)).toList();
    await prefs.setStringList('emergencyContacts', contactJsonList);
  }

  // Add or edit contact
  Future<void> _addOrEditContact(
      {Map<String, String>? contact, int? index}) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController phoneController = TextEditingController();
    TextEditingController nicknameController = TextEditingController();

    if (contact != null) {
      nameController.text = contact['name']!;
      phoneController.text = contact['phone']!;
      nicknameController.text = contact['nickname']!;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Nickname'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.isEmpty ||
                    phoneController.text.isEmpty ||
                    nicknameController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("All fields are required!")),
                  );
                  return;
                }

                setState(() {
                  if (contact == null) {
                    _emergencyContacts.add({
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'nickname': nicknameController.text,
                    });
                  } else {
                    _emergencyContacts[index!] = {
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'nickname': nicknameController.text,
                    };
                  }
                  _saveEmergencyContacts(); // Save the updated list
                });

                Navigator.pop(context); // Close the dialog after saving
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Delete a contact from the list
  Future<void> _deleteContact(int index) async {
    setState(() {
      _emergencyContacts.removeAt(index);
      _saveEmergencyContacts(); // Save the updated list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("MediCare SOS"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addOrEditContact(); // Open dialog to add a new contact
            },
          ),
        ],
      ),
      body: _emergencyContacts.isEmpty
          ? const Center(
              child: Text("No emergency contacts added yet"),
            )
          : ListView.builder(
              itemCount: _emergencyContacts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_emergencyContacts[index]['name']!),
                  subtitle: Text(
                      "Nickname: ${_emergencyContacts[index]['nickname']}"),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _addOrEditContact(
                          contact: _emergencyContacts[index],
                          index: index,
                        );
                      } else if (value == 'delete') {
                        _deleteContact(index);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Text(
                      _emergencyContacts[index]['name']![0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Encode contact as JSON string
  String _encodeJson(Map<String, String> contact) {
    return contact.toString();
  }

  // Decode JSON string to Map
  Map<String, dynamic> _decodeJson(String contactJson) {
    List<String> parts = contactJson.split(', ');
    return {
      'name': parts[0].split(': ')[1],
      'phone': parts[1].split(': ')[1],
      'nickname': parts[2].split(': ')[1],
    };
  }
}
