import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:safeher/screens/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait a bit to show splash screen
    await Future.delayed(const Duration(seconds: 2));

    // Request permissions
    await _requestPermissions();

    // Navigate to login
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _requestPermissions() async {
    try {
      print('Requesting permissions...');

      // Request location permission
      var locationStatus = await Permission.location.status;
      if (locationStatus.isDenied) {
        await Permission.location.request();
      }

      // Request SMS permission
      var smsStatus = await Permission.sms.status;
      if (smsStatus.isDenied) {
        await Permission.sms.request();
      }

      // Request contacts permission
      var contactsStatus = await Permission.contacts.status;
      if (contactsStatus.isDenied) {
        await Permission.contacts.request();
      }

      print('Permissions requested');
    } catch (e) {
      print('Permission error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.security,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'SafeHer',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Women Safety App',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 50),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading app...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white60,
              ),
            ),
          ],
        ),
      ),
    );
  }
}