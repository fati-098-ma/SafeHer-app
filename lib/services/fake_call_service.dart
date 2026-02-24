// lib/services/fake_call_service.dart
import 'dart:async';
import 'package:flutter/material.dart';

class FakeCallService {
  static Timer? _callTimer;

  static void scheduleFakeCall(BuildContext context) {
    // Cancel any existing timer
    _callTimer?.cancel();

    // Show immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📞 Fake call scheduled in 10 seconds...'),
        backgroundColor: Colors.purple,
      ),
    );

    // Start 10-second timer
    _callTimer = Timer(const Duration(seconds: 10), () {
      _showFakeCallDialog(context);
    });
  }

  static void _showFakeCallDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: Colors.green),
            SizedBox(width: 10),
            Text('Incoming Call'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: const Icon(Icons.person, size: 40),
            ),
            const SizedBox(height: 10),
            const Text(
              'Mom',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text('Mobile', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Call declined')),
              );
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showActiveCall(context);
            },
            child: const Text('Answer', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  static void _showActiveCall(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 20),
            const Text('Mom', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('00:30', style: TextStyle(fontSize: 18, color: Colors.grey)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.mic_off),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
        actions: [
          Center(
            child: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Call ended')),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}