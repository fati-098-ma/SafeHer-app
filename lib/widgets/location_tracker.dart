import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safeher/services/location_service.dart'; // Add this import

class LocationTracker extends StatefulWidget {
  final bool isTracking;

  const LocationTracker({
    super.key,
    required this.isTracking,
  });

  @override
  _LocationTrackerState createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  final Set<Marker> _markers = {};
  final LocationService _locationService = LocationService(); // Add this

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    // First, initialize location service
    bool initialized = await _locationService.initialize();

    if (initialized) {
      // Get current location
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _updateMarker();
        });
      } else {
        // Fallback to default location if can't get current location
        setState(() {
          _currentLocation = const LatLng(28.6139, 77.2090);
          _updateMarker();
        });
      }
    }
  }

  void _updateMarker() {
    if (_currentLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status indicator
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: widget.isTracking ? Colors.green.shade50 : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isTracking ? Colors.green : Colors.grey,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isTracking ? Icons.location_on : Icons.location_off,
                color: widget.isTracking ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 10),
              Text(
                widget.isTracking ? 'Tracking Active' : 'Tracking Inactive',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.isTracking ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Map container
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildMap(),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // Location info
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.blue.shade700),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _currentLocation != null
                      ? 'Lat: ${_currentLocation!.latitude.toStringAsFixed(6)}, '
                      'Lng: ${_currentLocation!.longitude.toStringAsFixed(6)}'
                      : 'Getting location...',
                  style: TextStyle(color: Colors.blue.shade900),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    if (_currentLocation == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: (controller) {
        _mapController = controller;
      },
      initialCameraPosition: CameraPosition(
        target: _currentLocation!,
        zoom: 15,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      compassEnabled: true,
      mapToolbarEnabled: true,
    );
    // In your LocationTracker widget, update the map markers:
    Widget buildMap() {
      final markers = <Marker>{};

      if (_currentLocation != null) {
        markers.add(
          Marker(
            markerId: MarkerId('current'),
            position: _currentLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
      }



      return GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentLocation ?? const LatLng(28.6139, 77.2090),
          zoom: 12,
        ),
        markers: markers,
        // ... rest of map config
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}