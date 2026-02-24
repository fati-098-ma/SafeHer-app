import 'package:flutter/material.dart';
import 'package:safeher/services/location_service.dart';
import 'package:safeher/widgets/location_tracker.dart' hide LocationService;

class SafeWalkScreen extends StatefulWidget {
  const SafeWalkScreen({super.key});

  @override
  _SafeWalkScreenState createState() => _SafeWalkScreenState();
}

class _SafeWalkScreenState extends State<SafeWalkScreen> {
  final LocationService _locationService = LocationService();
  final TextEditingController _destinationController = TextEditingController();
  bool _isTracking = false;
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    await _locationService.getCurrentLocation();
  }

  void _startSafeWalk() {
    if (_destinationController.text.isNotEmpty) {
      setState(() {
        _isTracking = true;
      });

      // Start location tracking
      _locationService.startBackgroundTracking();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Safe Walk mode activated. You are being monitored.'),
          backgroundColor: Colors.green,
        ),
      );

      // Calculate mock distance for demo
      setState(() {
        _distance = 1.5; // Mock distance in km
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a destination.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _stopSafeWalk() {
    setState(() {
      _isTracking = false;
    });
    _locationService.stopBackgroundTracking();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Safe Walk mode deactivated.'),
      ),
    );
  }

  void _simulateDestinationReached() {
    setState(() {
      _isTracking = false;
    });
    _locationService.stopBackgroundTracking();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('✅ Destination Reached'),
        content: Text('You have safely reached ${_destinationController.text}. Distance traveled: ${_distance.toStringAsFixed(2)} km'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safe Walk'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Destination Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Enter Your Destination',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination Address',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_distance > 0)
                      Text(
                        'Approximate distance: ${_distance.toStringAsFixed(2)} km',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 10),
                    if (!_isTracking)
                      ElevatedButton(
                        onPressed: _startSafeWalk,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Start Safe Walk',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    if (_isTracking)
                      Column(
                        children: [
                          const Text(
                            '✅ Safe Walk Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _stopSafeWalk,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Stop Safe Walk'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _simulateDestinationReached,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Destination Reached'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Map View
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Live Location Tracking',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: LocationTracker(
                          isTracking: _isTracking,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Status Information
            if (_isTracking)
              Card(
                color: Colors.green[50],
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.green),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You are being monitored',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            Text('Emergency contacts will be alerted if you deviate from route.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _destinationController.dispose();
    _locationService.dispose();
    super.dispose();
  }
}