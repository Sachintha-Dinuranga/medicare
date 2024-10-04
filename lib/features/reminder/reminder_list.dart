import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:medicare/features/reminder/add_reminder.dart';

class ReminderList extends StatefulWidget {
  const ReminderList({super.key});

  @override
  _ReminderListState createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  // Move the reminders list into the widget's state
  List<Map<String, dynamic>> reminders = [];
  String searchQuery = ''; // Variable to hold the search query

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    final box = Hive.box('reminders');
    setState(() {
      reminders = List<Map<String, dynamic>>.from(box.toMap().values);
    });
  }

  void _saveReminders() {
    final box = Hive.box('reminders');
    box.clear(); // Clear existing reminders
    for (var reminder in reminders) {
      box.add(reminder); // Save each reminder to the box
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value; // Update the search query
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Reminders',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
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
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          _deleteReminder(index);
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
                              'Date: ${DateFormat('yyyy-MM-dd').format(reminder['date'])} - Time: ${reminder['time'].format(context)}',
                              style: const TextStyle(
                                  color: Colors
                                      .black54), // Lighter color for subtitle
                            ),
                            trailing: Text(
                              reminder['priority'],
                              style: TextStyle(
                                  color: reminder['priority'] == 'High'
                                      ? Colors.red
                                      : Colors.blue),
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
          if (result != null) {
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
