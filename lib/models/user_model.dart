import 'package:safeher/models/emergency_contact.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String pin; // Added pin field
  final List<EmergencyContact> emergencyContacts;
  final String sosMessage;
  final double shakeSensitivity;
  final bool darkMode;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.pin, // Added pin parameter
    required this.emergencyContacts,
    required this.sosMessage,
    required this.shakeSensitivity,
    required this.darkMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'pin': pin, // Added pin
      'emergencyContacts': emergencyContacts.map((contact) => contact.toMap()).toList(),
      'sosMessage': sosMessage,
      'shakeSensitivity': shakeSensitivity,
      'darkMode': darkMode,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      pin: map['pin'] ?? '0000', // Added pin with default
      emergencyContacts: List<EmergencyContact>.from(
        (map['emergencyContacts'] ?? []).map((contact) => EmergencyContact.fromMap(contact)),
      ),
      sosMessage: map['sosMessage'] ?? 'I need help! My current location is: ',
      shakeSensitivity: map['shakeSensitivity']?.toDouble() ?? 18.0,
      darkMode: map['darkMode'] ?? false,
    );
  }
}