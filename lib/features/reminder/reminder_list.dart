import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // For encoding and decoding JSON
import 'package:intl/intl.dart';
import 'package:medicare/features/reminder/add_reminder.dart';
import 'package:table_calendar/table_calendar.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  _ReminderListState createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  // Move the reminders list into the widget's state
  List<Map<String, dynamic>> reminders = [];
  List<Map<String, dynamic>> filteredDateReminders = [];
  bool isCalendarVisible = false; // Manage calendar visibility
  String searchQuery = ''; // Variable to hold the search query
  DateTime? selectedDate; // Variable to hold the selected date

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // Method to load reminders from SharedPreferences
  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedReminders =
        prefs.getStringList('reminders') ?? []; // Ensure it's a list

    setState(() {
      reminders = savedReminders
          .map((reminder) => jsonDecode(reminder))
          .toList()
          .cast<Map<String, dynamic>>();
    });
  }

  // Method to save reminders to SharedPreferences
  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> remindersString = reminders
        .map((reminder) => jsonEncode(reminder)) // Convert to JSON strings
        .toList();

    await prefs.setStringList('reminders', remindersString); // Save as list
  }

  // Method to show a confirmation dialog before deleting
  Future<void> _confirmDelete(BuildContext context, int index) async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without deleting
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                _deleteReminder(index); // Proceed with deletion
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
            ),
          ],
        );
      },
    );
  }

  // Method to delete a reminder
  void _deleteReminder(int index) {
    setState(() {
      reminders.removeAt(index);
      _saveReminders(); // Save the updated list
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reminder deleted')),
    );
  }

  // Method to filter reminders based on search query
  List<Map<String, dynamic>> get filteredReminders {
    if (selectedDate != null) {
      return filteredDateReminders;
    }
    if (searchQuery.isEmpty) {
      return reminders;
    } else {
      return reminders.where((reminder) {
        return reminder['name']
                .toLowerCase()
                .contains(searchQuery.toLowerCase()) ||
            reminder['instructions']
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
      }).toList();
    }
  }

// Method to filter reminders based on selected date
  void _filterRemindersByDate(DateTime selectedDate) {
    setState(() {
      filteredDateReminders = reminders.where((reminder) {
        DateTime reminderDate =
            DateTime.fromMillisecondsSinceEpoch(reminder['date']);
        return reminderDate.year == selectedDate.year &&
            reminderDate.month == selectedDate.month &&
            reminderDate.day == selectedDate.day;
      }).toList();
    });
  }

  //calendar
  // Show calendar dialog
  void _showCalendarDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 400,
                    width: double.maxFinite,
                    child: TableCalendar(
                      firstDay: DateTime(2000),
                      lastDay: DateTime(2100),
                      focusedDay: DateTime.now(),
                      calendarFormat: CalendarFormat.month,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          selectedDate = selectedDay;
                          _filterRemindersByDate(selectedDay);
                        });
                        Navigator.pop(context); // Close calendar dialog
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // // Method to filter reminders based on selected date
  // void _filterRemindersByDate(DateTime selectedDate) {
  //   setState(() {
  //     filteredDateReminders = reminders.where((reminder) {
  //       DateTime reminderDate =
  //           DateTime.fromMillisecondsSinceEpoch(reminder['date']);
  //       return reminderDate.year == selectedDate.year &&
  //           reminderDate.month == selectedDate.month &&
  //           reminderDate.day == selectedDate.day;
  //     }).toList();
  //   });
  // }

  // Method to edit reminder
  Future<void> _editReminder(BuildContext context, int index) async {
    final reminder = reminders[index]; // Get current reminder details

    // Navigate to AddReminder with current details
    final updatedReminder = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminder(
          existingReminder: reminder,
        ),
      ),
    );

    if (updatedReminder != null && updatedReminder is Map<String, dynamic>) {
      setState(() {
        reminders[index] = updatedReminder; // Update the reminder
        _saveReminders(); // Save to SharedPreferences
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder List'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar and Calendar Icon
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value; // Update the search query
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Search Reminders',
                      labelStyle: const TextStyle(
                          color: Colors.black), // Label text color
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.black), // Icon color
                      filled: true, // Enable fill
                      fillColor:
                          Colors.blue[300], // Set background color to blue
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Rounded corners
                        borderSide:
                            BorderSide.none, // No border for the default state
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20.0), // Rounded corners
                        borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2.0), // Blue border when focused
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 16.0), // Padding inside the field
                    ),
                    cursorColor: Colors.white, // Change cursor color
                  ),
                ),
                // Calendar Icon Button
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.blue),
                  onPressed: () {
                    _showCalendarDialog(); // Show calendar dialog
                  },
                ),
              ],
            ),
          ),
          //clear filter button
          if (selectedDate != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedDate = null; // Reset the selected date
                    filteredDateReminders.clear(); // Clear filtered reminders
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[300], // Customize button color
                ),
                child: const Text('Clear Filter',
                    style: TextStyle(color: Colors.black)),
              ),
            ),

          // Conditionally show calendar
          // Reminder List
          Expanded(
            child: filteredReminders.isEmpty
                ? const Center(child: Text('No reminders added yet'))
                : ListView.builder(
                    itemCount: filteredReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = filteredReminders[index];

                      return Dismissible(
                        key:
                            Key(reminder['name'] + reminder['date'].toString()),
                        background: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.only(left: 16),
                          alignment: Alignment.centerLeft,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        secondaryBackground: Container(
                          color: Colors.green,
                          padding: const EdgeInsets.only(right: 16),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.startToEnd) {
                            // Trigger delete confirmation dialog
                            await _confirmDelete(
                                context, reminders.indexOf(reminder));
                          } else if (direction == DismissDirection.endToStart) {
                            // Open edit form when swiped from start to end
                            await _editReminder(
                                context, reminders.indexOf(reminder));
                          }
                          return false;
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors
                                .blue[100], // Light blue color for the tile
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(
                                    0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              reminder['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold, // Bold title
                                color: Colors.blue,
                              ),
                            ),
                            subtitle: Text(
                              'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(reminder['date']))} - Time: ${TimeOfDay(hour: reminder['time']['hour'], minute: reminder['time']['minute']).format(context)}',
                              style: const TextStyle(
                                  color: Colors
                                      .black54), // Lighter color for subtitle
                            ),
                            trailing: Text(
                              reminder['priority'],
                              style: TextStyle(
                                color: reminder['priority'] == 'High'
                                    ? Colors.red
                                    : reminder['priority'] == 'Medium'
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: ElevatedButton.icon(
        onPressed: () async {
          // Navigate to AddReminder and wait for the result
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddReminder()),
          );

          // If a new reminder is returned, add it to the list
          if (result != null && result is Map<String, dynamic>) {
            setState(() {
              reminders.add(result); // Add the new reminder to the list
              _saveReminders(); // Save the updated list
            });
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Customize as needed
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
