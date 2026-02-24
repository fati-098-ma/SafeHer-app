// local_storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Theme
  bool getDarkMode() {
    return _prefs?.getBool('dark_mode') ?? false;
  }

  Future<void> saveDarkMode(bool value) async {
    await _prefs?.setBool('dark_mode', value);
  }

  // Settings
  double getShakeSensitivity() {
    return _prefs?.getDouble('shake_sensitivity') ?? 15.0;
  }

  Future<void> saveShakeSensitivity(double value) async {
    await _prefs?.setDouble('shake_sensitivity', value);
  }

  String getSosMessage() {
    return _prefs?.getString('sos_message') ??
        "I need help! My current location is: ";
  }

  Future<void> saveSosMessage(String message) async {
    await _prefs?.setString('sos_message', message);
  }

  bool getLocationTracking() {
    return _prefs?.getBool('location_tracking') ?? true;
  }

  Future<void> saveLocationTracking(bool value) async {
    await _prefs?.setBool('location_tracking', value);
  }

  bool getNotifications() {
    return _prefs?.getBool('notifications') ?? true;
  }

  Future<void> saveNotifications(bool value) async {
    await _prefs?.setBool('notifications', value);
  }

  // Emergency Contacts
  List<String> getEmergencyContactIds() {
    return _prefs?.getStringList('emergency_contact_ids') ?? [];
  }

  Future<void> saveEmergencyContactIds(List<String> ids) async {
    await _prefs?.setStringList('emergency_contact_ids', ids);
  }

  // Last Known Location
  String getLastLocation() {
    return _prefs?.getString('last_location') ?? '';
  }

  Future<void> saveLastLocation(String location) async {
    await _prefs?.setString('last_location', location);
  }

  // Safety PIN
  String getSafetyPin() {
    return _prefs?.getString('safety_pin') ?? '';
  }

  Future<void> saveSafetyPin(String pin) async {
    await _prefs?.setString('safety_pin', pin);
  }

  // App Settings
  bool getVibrationEnabled() {
    return _prefs?.getBool('vibration_enabled') ?? true;
  }

  Future<void> saveVibrationEnabled(bool value) async {
    await _prefs?.setBool('vibration_enabled', value);
  }

  bool getSoundEnabled() {
    return _prefs?.getBool('sound_enabled') ?? true;
  }

  Future<void> saveSoundEnabled(bool value) async {
    await _prefs?.setBool('sound_enabled', value);
  }
}