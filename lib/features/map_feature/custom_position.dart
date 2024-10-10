import 'dart:convert';

class CustomPosition {
  final double latitude;
  final double longitude;

  CustomPosition({required this.latitude, required this.longitude});

  // Convert CustomPosition object to Map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Convert Map to CustomPosition object
  static CustomPosition fromMap(Map<String, dynamic> map) {
    return CustomPosition(
      latitude: map['latitude'],
      longitude: map['longitude'],
    );
  }

  // Convert CustomPosition object to JSON string
  String toJson() {
    return jsonEncode({'latitude': latitude, 'longitude': longitude});
  }

  // Convert JSON string to CustomPosition object
  static CustomPosition fromJson(String jsonStr) {
    Map<String, dynamic> map = jsonDecode(jsonStr);
    return CustomPosition.fromMap(map);
  }
}
