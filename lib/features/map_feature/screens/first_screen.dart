import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';

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
  final Set<Marker> _markers = {};
  final Logger _logger = Logger();

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
              _fetchNearbyHospitals(newPosition);
            });
          },
        );
        _markers.add(_origin!);
        _fetchNearbyHospitals(_initialPosition);
      });
    } else {
      _showPermissionDeniedDialog();
    }
  }

  Future<void> _fetchNearbyHospitals(LatLng position) async {
    const apiKey = 'AlzaSyOoGa5besFuSJ2dFj1Ta0MdQA7ZC6c2Y_J';
    final url = 'https://maps.gomaps.pro/maps/api/place/nearbysearch/json'
        '?location=${position.latitude},${position.longitude}'
        '&radius=2000' // 2 km radius
        '&type=hospital|doctor|pharmacy|Hospital' // Restrict to medical places
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        _logger.i('Fetched data: $results'); // Log fetched data

        setState(() {
          // Clear previous markers except current location
          _markers.removeWhere((marker) => marker.markerId.value != 'current-location');
          
          // Add new markers for medical facilities
          for (var result in results) {
            final LatLng hospitalPosition = LatLng(
              result['geometry']['location']['lat'],
              result['geometry']['location']['lng'],
            );

            // Add the medical facility marker with green color
            _markers.add(
              Marker(
                markerId: MarkerId(result['place_id']),
                position: hospitalPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen), // Green markers
                infoWindow: InfoWindow(
                  title: result['name'],
                  snippet: result['vicinity'],
                ),
              ),
            );
          }
        });
      } else {
        _logger.e('Failed to fetch nearby hospitals: ${response.statusCode}'); // Log error status code
      }
    } catch (e) {
      _logger.e('Error fetching nearby hospitals: $e'); // Log exception
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
                markers: _markers,
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
