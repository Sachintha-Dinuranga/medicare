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
  final Set<Polyline> _polylines = {}; 
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

//fetch locations from gomap
  Future<void> _fetchNearbyHospitals(LatLng position) async {
    const apiKey = 'AlzaSyOoGa5besFuSJ2dFj1Ta0MdQA7ZC6c2Y_J';
    final url = 'https://maps.gomaps.pro/maps/api/place/nearbysearch/json'
        '?location=${position.latitude},${position.longitude}'
        '&radius=2000' // 2 km radius
        '&type=hospital|doctor|pharmacy|Hospital' 
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        _logger.i('Fetched data: $results');

        setState(() {
          // Clear previous markers except current location
          _markers.removeWhere((marker) => marker.markerId.value != 'current-location');
          
          // marker formatting
          for (var result in results) {
            final LatLng hospitalPosition = LatLng(
              result['geometry']['location']['lat'],
              result['geometry']['location']['lng'],
            );

            _markers.add(
              Marker(
                markerId: MarkerId(result['place_id']),
                position: hospitalPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(
                  title: result['name'],
                  snippet: result['vicinity'],
                ),
                onTap: () {
                  _getDirections(_initialPosition, hospitalPosition);
                },
              ),
            );
          }
        });
      } else {
        _logger.e('Failed to fetch nearby hospitals: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('Error fetching nearby hospitals: $e');
    }
  }

  
  // get directions from gomap
  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    const apiKey = 'AlzaSyOoGa5besFuSJ2dFj1Ta0MdQA7ZC6c2Y_J';
    final url = 'https://maps.gomaps.pro/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=driving'  
      '&avoid=tolls'  
      '&traffic_model=best_guess' 
      '&departure_time=now' 
      '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final points = data['routes'][0]['overview_polyline']['points'];

      _logger.i('Polyline points: $points');

      _createPolyline(points);
    } else {
      _logger.e('Failed to fetch directions: ${response.statusCode}');
    }
  } catch (e) {
    _logger.e('Error fetching directions: $e');
  }
  }


//create polylines to display roads
  void _createPolyline(String encodedPolyline) {
    setState(() {
      _polylines.clear(); 
      _polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          width: 5,
          color: Colors.blue,
          points: _decodePolyline(encodedPolyline),
        ),
      );
    });
  }


  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      final latitude = lat / 1E5;
      final longitude = lng / 1E5;
      polylineCoordinates.add(LatLng(latitude, longitude));
    }

    return polylineCoordinates;
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
                polylines: _polylines,
                trafficEnabled: true,
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
