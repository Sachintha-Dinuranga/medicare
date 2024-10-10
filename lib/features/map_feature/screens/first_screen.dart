import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:medicare/features/map_feature/database_helper.dart';

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
  bool _showOverview = false;
  List _locationSummaries = [];
  List<Map<String, dynamic>> savedLocations = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndGetLocation();
    _loadLocations();
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
          _markers.removeWhere(
              (marker) => marker.markerId.value != 'current-location');
          _locationSummaries = results;

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
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
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
          content: const Text(
              'Location permission is required to use this feature. Please enable it in the app settings.'),
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

  // Load saved locations from SQLite database
  Future<void> _loadLocations() async {
    List<Map<String, dynamic>> locations =
        await DatabaseHelper.instance.getAllLocations();
    setState(() {
      savedLocations = locations;
    });
  }

  void _editLocation(int id, String newName) {
    DatabaseHelper.instance.updateLocation(id, newName);
    _loadLocations();
  }

  void _deleteLocation(int id) {
    DatabaseHelper.instance.deleteLocation(id);
    Navigator.of(context).pop();
    _loadLocations();
  }

  void _showSavedLocations() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SavedLocationsPopup(
          locations: savedLocations,
          onEdit: _editLocation,
          onDelete: _deleteLocation,
          onClose: () => Navigator.of(context).pop(),
          onGoTo: _goTo,
        );
      },
    );
  }

  void _goTo(LatLng position) {
  Navigator.of(context).pop();

  // _logger.i('Navigating to position: ${position.latitude}, ${position.longitude}');

  setState(() {
    if (_origin != null) {
      // Create a new marker with the updated position
      _origin = Marker(
        markerId: _origin!.markerId,
        position: position, // New position
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _origin = _origin!.copyWith(positionParam: newPosition);
          });
        },
      );

      _fetchNearbyHospitals(position);

      // Update the markers set
      _markers.removeWhere((marker) => marker.markerId == _origin!.markerId);
      _markers.add(_origin!);

      // Animate camera to new position
      mapController.animateCamera(CameraUpdate.newLatLng(position));

      // Load locations or perform any other necessary actions
      _loadLocations();
    }
  });
}


  // Function to show the long press dialog for adding new location
  void _showAddLocationDialog() {
    TextEditingController locationController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Location'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'Enter location name',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String locationName = locationController.text;
                if (locationName.isNotEmpty) {
                  DatabaseHelper.instance.insertLocation(
                      locationName,
                      _initialPosition.latitude,
                      _initialPosition
                          .longitude); // Example coordinates (San Francisco)
                  _loadLocations();
                  Navigator.of(context).pop();
                } else {
                  // If location name is empty, show a warning
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Location name cannot be empty!')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
        body: Stack(
          children: [
            _locationPermissionGranted
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14.0,
                    ),
                    myLocationEnabled: true,
                    markers: _markers,
                    polylines: _polylines,
                    trafficEnabled: true,
                    layoutDirection: TextDirection.ltr,
                    onMapCreated: (GoogleMapController controller) {
                      mapController = controller;
                    },
                  )
                : const Center(
                    child: CircularProgressIndicator(),
                  ),
            Positioned(
              top: 80.0,
              right: 10.0,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showOverview = !_showOverview;
                  });
                },
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _showOverview ? Icons.close : Icons.list,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140.0,
              right: 10.0,
              child: GestureDetector(
                onTap: () async {
                  await _checkPermissionAndGetLocation();
                },
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.restore,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 200.0,
              right: 10.0,
              child: GestureDetector(
                onTap: _showSavedLocations,
                onLongPress: _showAddLocationDialog,
                child: Opacity(
                  opacity: 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.save,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            if (_showOverview)
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                height: screenHeight / 3,
                child: Container(
                  color: Colors.white.withOpacity(0.9),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _locationSummaries.length,
                    itemBuilder: (context, index) {
                      final location = _locationSummaries[index];
                      final List photos = location['photos'] ?? [];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 10.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: screenWidth * 0.4,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Expanded(
                                child: CarouselSlider(
                                  options: CarouselOptions(
                                    height: screenHeight / 6,
                                    viewportFraction: 1.0,
                                    enlargeCenterPage: true,
                                  ),
                                  items: photos.map((photo) {
                                    final photoReference =
                                        photo['photo_reference'];
                                    final photoUrl =
                                        'https://maps.gomaps.pro/maps/api/place/photo'
                                        '?maxwidth=400&photoreference=$photoReference&key=AlzaSyOoGa5besFuSJ2dFj1Ta0MdQA7ZC6c2Y_J';

                                    return Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: NetworkImage(photoUrl),
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Location Details (Bottom Half)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    location['vicinity'] ??
                                        'No address available',
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SavedLocationsPopup extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final Function(int, String) onEdit;
  final Function(int) onDelete;
  final Function(LatLng) onGoTo;
  final VoidCallback onClose;
  final Logger _logger = Logger();

  SavedLocationsPopup({
    super.key,
    required this.locations,
    required this.onEdit,
    required this.onDelete,
    required this.onClose,
    required this.onGoTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saved Locations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    LatLng position = LatLng(locations[index]['latitude'],
                        locations[index]['longitude']);
                    onGoTo(position);
                  },
                  child: ListTile(
                    title: Text(locations[index]['name']),
                    subtitle: Text(
                        'Lat: ${locations[index]['latitude']}, Long: ${locations[index]['longitude']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editDialog(context,
                              locations[index]['id'], locations[index]['name']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => {onDelete(locations[index]['id'])},
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Function to show edit dialog
  void _editDialog(BuildContext context, int id, String currentName) {
    TextEditingController controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Location'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                onEdit(id, controller.text);
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
