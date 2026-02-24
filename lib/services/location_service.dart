import 'dart:async';

import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _currentPosition;
  bool _isTracking = false;
  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;

  Future<bool> initialize() async {
    try {
      return await _requestLocationPermission();
    } catch (e) {
      print('Location service initialization error: $e');
      return false;
    }
  }

  Future<bool> _requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (e) {
      print('Permission request error: $e');
      return false;
    }
  }

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      bool hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        print('Location permission not granted');
        return null;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return _currentPosition;
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Stream<Position> getLocationStream() {
    _positionStream ??= Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    return _positionStream!;
  }

  // SIMPLIFIED VERSION - No Placemark dependency
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    // Return simple coordinates instead of address
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  Future<String> getLocationUrl(double lat, double lng) async {
    return 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  }

  Future<String> getGoogleMapsUrl(double lat, double lng) async {
    return 'https://www.google.com/maps?q=$lat,$lng';
  }

  Future<void> startBackgroundTracking() async {
    if (!_isTracking) {
      _isTracking = true;
      print('Background tracking started');

      _positionSubscription = getLocationStream().listen((Position position) {
        _currentPosition = position;
        print('Location updated: ${position.latitude}, ${position.longitude}');
      });
    }
  }

  void stopBackgroundTracking() {
    _isTracking = false;
    _positionSubscription?.cancel();
    _positionSubscription = null;
    print('Background tracking stopped');
  }

  bool get isTracking => _isTracking;

  Position? get currentPosition => _currentPosition;

  Future<double?> calculateDistance(double startLat, double startLng, double endLat, double endLng) async {
    try {
      return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
    } catch (e) {
      print('Error calculating distance: $e');
      return null;
    }
  }

  void dispose() {
    stopBackgroundTracking();
  }
}