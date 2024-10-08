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
  Marker? _origin;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
  }

  Future<void> _checkPermissionAndGetLocation() async {
    var status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _locationPermissionGranted = true;
        _origin = Marker(
          markerId: const MarkerId('current-location'),
          position: _initialPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _initialPosition = newPosition;
              mapController.animateCamera(CameraUpdate.newLatLng(newPosition));
            });
          },
        );
      });
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: const Text('Location permission is required to use this feature. Please enable it in the app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
            letterSpacing: 1.5,
          ),
        ),
        body: _locationPermissionGranted
            ? GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14.0,
                ),
                myLocationEnabled: true,
                markers: _origin != null ? {_origin!} : {},
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
