import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<void> saveUserInfo({
    required String fullName,
    required String age,
    required String bloodGroup,
    required String emergencyContact,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', fullName);
    await prefs.setString('age', age);
    await prefs.setString('bloodGroup', bloodGroup);
    await prefs.setString('emergencyContact', emergencyContact);
  }

  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'fullName': prefs.getString('fullName'),
      'age': prefs.getString('age'),
      'bloodGroup': prefs.getString('bloodGroup'),
      'emergencyContact': prefs.getString('emergencyContact'),
    };
  }

  static Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Remove all user info
  }
}
