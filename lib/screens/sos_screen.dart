import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ueehe/screens/EmergencyContactsScreen.dart';
import 'package:url_launcher/url_launcher.dart'; // For phone call functionality
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/services.dart'; // Import the services package for HapticFeedback
import '../widgets/custom_bottom_navigation_bar.dart'; // Import the custom navigation bar
import 'profile_screen.dart';
import 'history_screen.dart';
import 'countdown_screen.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  _SosScreenState createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen>
    with SingleTickerProviderStateMixin {
  String _currentLocation = "Fetching location...";
  double? _latitude;
  double? _longitude;

  int _selectedIndex = 0; // Current tab index for BottomNavigationBar

  // List of screens for each tab
  final List<Widget> _screens = [];

  late AnimationController
      _controller; // Controller for the breathing animation
  //late Animation<double> _animation; // Animation value for scaling

  @override
  void initState() {
    super.initState();

    // Initialize the screens for bottom navigation
    _screens.add(SosScreenContent(
      location: _currentLocation,
      onEmergencyPressed: _startEmergencyProcedure,
    ));
    _screens.add(EmergencyContactsScreen()); // History Screen (Second Tab)
    _screens.add(ProfileScreen()); // Profile Screen (Third Tab)

    _requestPermissions();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Duration for one breathing cycle
    )..repeat(reverse: true); // Repeat the animation (breathing effect)

    // Tween to scale between 0.9x and 1.0x
    // _animation = Tween<double>(begin: 0.9, end: 1.0).animate(
    //   CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    // );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the animation controller
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    var locationPermission = await Permission.location.request();
    if (locationPermission.isGranted) {
      _determinePosition();
    } else {
      setState(() {
        _currentLocation = "Location permissions are denied.";
      });
    }
  }

  Future<void> _determinePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = "${position.latitude}, ${position.longitude}";
        _latitude = position.latitude;
        _longitude = position.longitude;
        // Update the SosScreenContent with the new location
        _screens[0] = SosScreenContent(
          location: _currentLocation,
          onEmergencyPressed: _startEmergencyProcedure,
        );
      });
    } catch (e) {
      setState(() {
        _currentLocation = "Failed to fetch location: $e";
      });
    }
  }

  // Method to start the emergency procedure
  void _startEmergencyProcedure() {
    if (_latitude != null && _longitude != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CountdownScreen(
            location: _currentLocation,
            latitude: _latitude!,
            longitude: _longitude!,
          ),
        ),
      );
    } else {
      // Handle the case where the location is not available
      // Show success message
      // ignore: unused_local_variable
      final snackBar = SnackBar(
        /// need to set following properties for best effect of awesome_snackbar_content
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,

        content: AwesomeSnackbarContent(
          title: 'Wait',
          message: 'Please wait while we are fetching your location.',

          /// change contentType to ContentType.success, ContentType.warning or ContentType.help for variants
          contentType: ContentType.warning,
        ),
      );
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(snackBar);
    }
  }

  // Method to handle tab selection in the bottom navigation bar
  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS'),
        backgroundColor: Colors.blue,
        centerTitle: true,
        titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // Navigate to notifications screen
            },
          ),
        ],
      ),
      body: SafeArea(
        child: _screens[_selectedIndex], // Display the selected screen
      ),// Add the drawer here
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex, // Pass the current index
        onTabSelected: _onTabSelected, // Pass the tab selection callback
      ),
    );
  }

  // Method to build the drawer with interactive menu options
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<String?>(
                  future: SharedPreferences.getInstance().then((prefs) {
                    return prefs.getString('profile_image');
                  }),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                      );
                    } else if (snapshot.hasError || !snapshot.hasData) {
                      return const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                      );
                    } else {
                      return CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage(snapshot.data!),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                FutureBuilder<String>(
                  future: SharedPreferences.getInstance().then((prefs) {
                    return prefs.getString('name') ?? 'Guest';
                  }),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? 'Guest',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.black54),
            title: const Text('Profile'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.black54),
            title: const Text('History'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.black54),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings screen
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.black54),
            title: const Text('Logout'),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.clear(); // Clear user data on logout
              Navigator.pop(context); // Close drawer
              // Navigate to the login screen or any other action
            },
          ),
        ],
      ),
    );
  }
}

// SosScreenContent widget with pulsing animation for SOS button
class SosScreenContent extends StatefulWidget {
  final VoidCallback onEmergencyPressed;
  final String location;

  const SosScreenContent(
      {super.key, required this.onEmergencyPressed, required this.location});

  @override
  _SosScreenContentState createState() => _SosScreenContentState();
}

class _SosScreenContentState extends State<SosScreenContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this, // Ticker provider for the animation
      duration: const Duration(seconds: 1), // Duration for one breathing cycle
    )..repeat(
        reverse:
            true); // Repeat the animation in reverse for the breathing effect

    // Define the animation tween (scale between 0.9 and 1.0)
    _animation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the controller when the widget is removed
    super.dispose();
  }

  // Method to make a call to "1990"

  /// Makes a call to 1990 emergency service. If the call cannot be made, shows
  /// a custom alert dialog with a 'Try again' button.
  Future<void> _callEmergencyService() async {
    const emergencyNumber = 'tel:1990';

    try {
      if (await canLaunchUrl(Uri.parse(emergencyNumber))) {
        await launchUrl(
            Uri.parse(emergencyNumber)); // Launches the dialer with 1990
      } else {
        // Add haptic feedback pulse
        HapticFeedback.heavyImpact(); // Provides haptic feedback -- heavy
        HapticFeedback.vibrate(); // Provides haptic feedback -- vibrate
        // Show custom alert dialog if the call cannot be made
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4), // Shadow positioning
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Error icon
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.red[100], // Light pink background
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close, // Error close icon
                          size: 30,
                          color: Colors.blue, // Pink accent for the icon
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Title
                      const Text(
                        'Failed to call 1990',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Subtitle / description
                      const Text(
                        'Hmm, seems like we have no permission to call 1990.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Try again button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Rounded button
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 8,
                          ),
                        ),
                        child: const Text(
                          'Try again',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
    } on Exception catch (e) {
      // Handle any unexpected errors
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override

  /// Builds the SOS screen, with a top app bar and a SOS button in the center.
  /// The SOS button has a breathing animation and a long press detector to
  /// activate the emergency service.
  /// The location is displayed below the SOS button, and a button to call the
  /// 1990 Suwa Seriya emergency service is at the bottom of the screen.
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // children: [
            //   IconButton(
            //     icon: const Icon(Icons.menu, size: 28, color: Colors.black54),
            //     onPressed: () {
            //       Scaffold.of(context).openDrawer(); // Open the side drawer
            //     },
            //   ),
            //   FutureBuilder<String>(
            //     future: SharedPreferences.getInstance().then((prefs) {
            //       return 'Hello, ${prefs.getString('name') ?? 'there'}';
            //     }),
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Text(
            //           'Loading...',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.black87,
            //           ),
            //         );
            //       } else if (snapshot.hasError) {
            //         return const Text(
            //           'Error',
            //           style: TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.black87,
            //           ),
            //         );
            //       } else {
            //         return Text(
            //           snapshot.data ?? '',
            //           style: const TextStyle(
            //             fontSize: 16,
            //             fontWeight: FontWeight.w500,
            //             color: Colors.black87,
            //           ),
            //         );
            //       }
            //     },
            //   ),
            //   IconButton(
            //     icon: const Icon(Icons.notifications_none,
            //         size: 28, color: Colors.blue),
            //     onPressed: () {},
            //   ),
            // ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Are you in an emergency?",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 40.0),
          child: Text(
            "Hold the SOS button for a while, if you are in an urgent situation and needed help. Your live location will be shared with your homies.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Breathing SOS button with animation
        GestureDetector(
          onLongPress: widget.onEmergencyPressed,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _animation.value, // Apply the scaling from animation
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "SOS",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 70),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.grey[300]!, blurRadius: 20)],
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(FontAwesomeIcons.locationDot,
                  color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your current location",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    widget.location == null
                        ? const Text(
                            "Loading location",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          )
                        : Text(
                            widget.location, // Check for null before accessing
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Call 1990 Suwa Seriya Button
        Container(
          margin:
              const EdgeInsets.symmetric(horizontal: 20), // Horizontal margin
          child: ElevatedButton(
            onPressed: () => _callEmergencyService(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the content horizontally
              children: [
                const Icon(FontAwesomeIcons.ambulance, color: Colors.blue),
                const SizedBox(
                    width: 10), // Adjust spacing between icon and text
                const Text(
                  "Call 1990 සුව සැරිය  ", // Check for null before accessing
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
