import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({super.key});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  late GoogleMapController mapController;
  LatLng _initialPosition = const LatLng(0.0, 0.0);
  bool _locationPermissionGranted = false;


  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }


   Future<void> _checkPermissionAndGetLocation() async {
    // Request location permission
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _locationPermissionGranted = true;
      });
    } else {
      // Handle the case where permission is denied
      print('Location permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('First Screen'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          titleTextStyle: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5
          ),
        ),
        body: _locationPermissionGranted
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}