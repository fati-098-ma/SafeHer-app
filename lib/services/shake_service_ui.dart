import 'package:flutter/material.dart';
import 'package:safeher/services/shake_detector.dart';
import 'package:safeher/services/local_storage_service.dart';

class ShakeServiceUI extends StatefulWidget {
  const ShakeServiceUI({super.key});

  @override
  _ShakeServiceUIState createState() => _ShakeServiceUIState();
}

class _ShakeServiceUIState extends State<ShakeServiceUI> {
  final LocalStorageService _storage = LocalStorageService();
  bool _shakeEnabled = false;
  double _sensitivity = 15.0;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _sensitivity = _storage.getShakeSensitivity();
      _shakeEnabled = true; // Default to enabled
    });
    _initializeShakeDetector();
  }

  void _initializeShakeDetector() {
    if (_shakeEnabled) {
      _shakeDetector?.dispose();
      _shakeDetector = ShakeDetector(
        onShake: _onShakeDetected,
        shakeThreshold: _sensitivity,
      );
    }
  }

  void _onShakeDetected() {
    // Show notification or trigger SOS
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Shake detected! Sending SOS...'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Cancel',
          onPressed: () {
            // Cancel SOS if needed
          },
        ),
      ),
    );

    // Trigger your SOS function here
    // Example: _sendSOS();
  }

  void _updateSensitivity(double value) {
    setState(() {
      _sensitivity = value;
      _storage.saveShakeSensitivity(value);
    });
    _initializeShakeDetector();
  }

  void _toggleShakeDetection(bool value) {
    setState(() {
      _shakeEnabled = value;
    });
    if (value) {
      _initializeShakeDetector();
    } else {
      _shakeDetector?.dispose();
      _shakeDetector = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Shake Detection',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _shakeEnabled,
                  onChanged: _toggleShakeDetection,
                  activeThumbColor: Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 16),

            Text(
              'Shake Sensitivity',
              style: TextStyle(
                color: Colors.grey[700],
              ),
            ),

            Slider(
              value: _sensitivity,
              min: 5.0,
              max: 30.0,
              divisions: 5,
              label: _sensitivity.toStringAsFixed(1),
              onChanged: _updateSensitivity,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  'High',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Shake your phone to send emergency SOS',
                      style: TextStyle(
                        color: Colors.purple[800],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _shakeDetector?.dispose();
    super.dispose();
  }
}