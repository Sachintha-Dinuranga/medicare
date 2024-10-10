class UserModel {
  String? fullName;
  String? age;
  String? bloodGroup;
  String? emergencyContact;

  UserModel({
    required this.fullName,
    required this.age,
    required this.bloodGroup,
    required this.emergencyContact,
  });

  // Convert UserModel to JSON for SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'age': age,
      'bloodGroup': bloodGroup,
      'emergencyContact': emergencyContact,
    };
  }

  // Create a UserModel from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      fullName: json['fullName'],
      age: json['age'],
      bloodGroup: json['bloodGroup'],
      emergencyContact: json['emergencyContact'],
    );
  }
}
