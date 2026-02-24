class AppConstants {
  // App Info
  static const String appName = 'SafeHer';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String emergencyContactsCollection = 'emergency_contacts';
  static const String sosAlertsCollection = 'sos_alerts';

  // Storage Keys
  static const String shakeSensitivityKey = 'shake_sensitivity';
  static const String sosMessageKey = 'sos_message';
  static const String darkModeKey = 'dark_mode';
  static const String emergencyContactsKey = 'emergency_contacts';

  // Default Values
  static const double defaultShakeSensitivity = 18.0;
  static const String defaultSosMessage = 'I need help! My current location is: ';
  static const int maxEmergencyContacts = 5;

  // SOS Configuration
  static const int sosLongPressDuration = 2000; // 2 seconds
  static const int fakeCallDelay = 10; // 10 seconds

  // Colors
  static const int primaryColor = 0xFF6A1B9A;
  static const int secondaryColor = 0xFF8E24AA;
  static const int accentColor = 0xFFE91E63;
  static const int successColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFF9800;
  static const int errorColor = 0xFFF44336;

  // Messages
  static const String sosActivatedMessage = 'SOS Activated! Emergency contacts notified.';
  static const String locationTrackingMessage = 'Location tracking active';
  static const String safeWalkActiveMessage = 'Safe Walk mode activated';
  static const String fakeCallIncomingMessage = 'Fake call incoming in 10 seconds';

  // Permissions
  static const List<String> requiredPermissions = [
    'location',
    'sms',
    'phone',
    'notification',
  ];
}

class FirebaseConstants {
  static const String usersPath = 'users';
  static const String contactsPath = 'emergencyContacts';
  static const String sosAlertsPath = 'sosAlerts';
}