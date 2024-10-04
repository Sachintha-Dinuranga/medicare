import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:medicare/features/reminder/reminder_list.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final _formKey = GlobalKey<FormState>();

  //form input variable
  String medicationName = '';
  String dosage = '';
  String frequency = '';
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String priority = 'Low'; // Default value
  String instructions = '';

  List<Map<String, dynamic>> reminders = [];

  // Format date and time for display
  // String formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  // String formatTime(TimeOfDay time) => time.format(context);

  // Function to submit the form
  // Function to submit the form
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a new reminder map
      final newReminder = {
        'name': medicationName,
        'dosage': dosage,
        'frequency': frequency,
        'date': selectedDate.millisecondsSinceEpoch,
        'time': {
          'hour': selectedTime.hour,
          'minute': selectedTime.minute,
        },
        'priority': priority,
        'instructions': instructions,
      };

      // Pop the current screen
      Navigator.pop(context, newReminder);
    }
  }

  // Function to save reminders in SharedPreferences
  // Future<void> _saveReminder(Map<String, dynamic> newReminder) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // Get the existing reminders
  //   List<String>? savedReminders = prefs.getStringList('reminders') ?? [];

  //   // Add the new reminder (converted to JSON string)
  //   savedReminders.add(jsonEncode(newReminder));

  //   // Save the updated list back to SharedPreferences
  //   await prefs.setStringList('reminders', savedReminders);
  // }

  // Function to pick date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to pick time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medication Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Medication Name
              TextFormField(
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter medication name';
                  }
                  return null;
                },
                onSaved: (value) {
                  medicationName = value!;
                },
              ),

              // Dosage
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dosage'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
                onSaved: (value) {
                  dosage = value!;
                },
              ),

              // Frequency
              TextFormField(
                decoration: const InputDecoration(labelText: 'Frequency'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter frequency';
                  }
                  return null;
                },
                onSaved: (value) {
                  frequency = value!;
                },
              ),

              // Date
              ListTile(
                title: Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),

              // Time
              ListTile(
                title: Text("Time: ${selectedTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),

              // Priority Level
              DropdownButtonFormField<String>(
                value: priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['High', 'Medium', 'Low'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    priority = value!;
                  });
                },
                onSaved: (value) {
                  priority = value!;
                },
              ),

              // Additional Instructions
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Additional Instructions'),
                onSaved: (value) {
                  instructions = value ?? '';
                },
              ),

              // Buttons: Cancel and Submit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
