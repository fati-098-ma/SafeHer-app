import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class SOSActivatedScreen extends StatefulWidget {
  const SOSActivatedScreen({super.key});

  @override
  _SOSActivatedScreenState createState() => _SOSActivatedScreenState();
}

class _SOSActivatedScreenState extends State<SOSActivatedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _countdown = 10;
  bool _isCancelled = false;

  @override
  void initState() {
    super.initState();
    _startAlert();
    _startCountdown();
  }

  void _startAlert() {
    // Start vibration pattern
    Vibration.vibrate(pattern: [500, 1000, 500, 1000]);

    // Start animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 1.0, end: 1.2).animate(_controller);
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isCancelled && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      } else if (!_isCancelled && _countdown == 0) {
        _confirmEmergency();
      }
    });
  }

  void _confirmEmergency() {
    // This is where you would send the actual emergency alerts
    // For now, we'll just show a success message

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alerts sent to all contacts!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
      ),
    );

    // Navigate back after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _cancelEmergency() {
    setState(() {
      _isCancelled = true;
    });
    Vibration.cancel();
    _controller.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency cancelled'),
        backgroundColor: Colors.orange,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Emergency Icon
            ScaleTransition(
              scale: _animation,
              child: const Icon(
                Icons.emergency,
                size: 120,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // Emergency Text
            const Text(
              'EMERGENCY ALERT',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'SOS signal activated',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // Countdown
            if (!_isCancelled)
              Column(
                children: [
                  const Text(
                    'Sending alerts in:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 48,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Emergency contacts will be notified\nwith your location',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            const Spacer(),
            // Cancel Button
            if (!_isCancelled)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _cancelEmergency,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'CANCEL EMERGENCY',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            if (_isCancelled)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Emergency cancelled',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
    Vibration.cancel();
    _controller.dispose();
    super.dispose();
  }
}