import 'dart:async';

import 'package:sensors_plus/sensors_plus.dart';

class ShakeDetector {
  final Function onShake;
  double shakeThreshold;
  StreamSubscription? _subscription;
  List<double> _accelerometerValues = [0, 0, 0];
  DateTime _lastShake = DateTime.now();

  ShakeDetector({
    required this.onShake,
    this.shakeThreshold = 18.0,
  }) {
    _startListening();
  }

  void _startListening() {
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      _accelerometerValues = [event.x, event.y, event.z];
      _checkForShake();
    });
  }

  void _checkForShake() {
    double acceleration = _accelerometerValues
        .map((value) => value.abs())
        .reduce((sum, value) => sum + value);

    DateTime now = DateTime.now();
    if (acceleration > shakeThreshold &&
        now.difference(_lastShake).inMilliseconds > 2000) {
      _lastShake = now;
      onShake();
    }
  }

  void updateSensitivity(double sensitivity) {
    shakeThreshold = sensitivity;
  }

  void dispose() {
    _subscription?.cancel();
  }
}
