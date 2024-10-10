import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicare/features/reminder/notification_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert'; // For encoding and decoding JSON
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
// import 'package:medicare/features/reminder/reminder_list.dart';

class AddReminder extends StatefulWidget {
  final Map<String, dynamic>? existingReminder;
  const AddReminder({super.key, this.existingReminder});

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
  @override
  void initState() {
    super.initState();

    // Check if an existing reminder was passed to the form
    if (widget.existingReminder != null) {
      final reminder = widget.existingReminder!;
      medicationName = reminder['name'];
      dosage = reminder['dosage'];
      frequency = reminder['frequency'];
      selectedDate = DateTime.fromMillisecondsSinceEpoch(reminder['date']);
      selectedTime = TimeOfDay(
          hour: reminder['time']['hour'], minute: reminder['time']['minute']);
      priority = reminder['priority'];
      instructions = reminder['instructions'];
    }
  }

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

      DateTime scheduledTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour % 12 +
            (selectedTime.period == DayPeriod.pm
                ? 12
                : 0), // Convert to 24-hour format
        selectedTime.minute,
      );

      if (scheduledTime.isBefore(DateTime.now())) {
        // Show an error if the selected time is in the past
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scheduled time cannot be in the past")),
        );
        return;
      }

      // Schedule the notification
      NotificationService.scheduleNotification(
        'Medication Reminder',
        'It\'s time to take $medicationName',
        scheduledTime,
        priority,
      );

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
        title: const Text('Add Reminders'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Medication Name
              TextFormField(
                initialValue: medicationName,
                decoration: InputDecoration(
                  labelText: 'Medication Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              const SizedBox(height: 16),

              // Dosage
              TextFormField(
                initialValue: dosage,
                decoration: InputDecoration(
                  labelText: 'Dosage',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              const SizedBox(height: 16),

              // Frequency
              TextFormField(
                initialValue: frequency,
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              const SizedBox(height: 16),

              // Date picker
              ListTile(
                title: Text(
                    "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),

              // Time picker
              ListTile(
                title: Text("Time: ${selectedTime.format(context)}"),
                trailing: const Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),

              // Priority Level
              DropdownButtonFormField<String>(
                value: priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
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
              const SizedBox(height: 16),

              // Additional Instructions
              TextFormField(
                initialValue: instructions,
                decoration: InputDecoration(
                  labelText: 'Additional Instructions',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                ),
                maxLines: 4,
                onSaved: (value) {
                  instructions = value ?? '';
                },
              ),
              const SizedBox(height: 24),

              // Buttons: Cancel and Submit
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
