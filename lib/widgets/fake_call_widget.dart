import 'dart:async';
import 'package:flutter/material.dart';

class FakeCallWidget {
  void showFakeCall(BuildContext context) {
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fake call will arrive in 10 seconds'),
        backgroundColor: Colors.purple,
      ),
    );

    // Simulate a fake call after 10 seconds
    Timer(const Duration(seconds: 10), () {
      _showIncomingCallDialog(context);
    });
  }

  void _showIncomingCallDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.phone, color: Colors.green),
              SizedBox(width: 10),
              Text('Incoming Call'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 30,
                child: Icon(Icons.person, size: 40),
              ),
              SizedBox(height: 10),
              Text('Mom', style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              )),
              SizedBox(height: 5),
              Text('Mobile', style: TextStyle(
                  color: Colors.grey
              )),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Decline', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Call declined')),
                );
              },
            ),
            TextButton(
              child: const Text('Answer', style: TextStyle(color: Colors.green)),
              onPressed: () {
                Navigator.of(context).pop();
                _showOngoingCallDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showOngoingCallDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 50),
              ),
              const SizedBox(height: 20),
              const Text('Mom', style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
              )),
              const SizedBox(height: 10),
              const Text('00:30', style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey
              )),
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
        );
      },
    );
  }
}