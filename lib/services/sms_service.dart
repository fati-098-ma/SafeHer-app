import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/emergency_contact.dart';

class SmsService {
  Future<bool> requestSMSPermission() async {
    // Check current permission status
    final status = await Permission.sms.status;

    if (status.isGranted) {
      return true;
    } else if (status.isDenied) {
      // Request permission
      final result = await Permission.sms.request();
      return result.isGranted;
    } else if (status.isPermanentlyDenied) {
      // Open app settings for manual permission
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<void> sendSMS(String phoneNumber, String message) async {
    try {
      bool hasPermission = await requestSMSPermission();
      if (!hasPermission) {
        throw Exception('SMS permission not granted');
      }

      // Using platform channels to send SMS (Android only)
      // This is a workaround since SMS plugin is deprecated
      // You'll need to implement platform-specific code

      // For now, we'll use a dummy implementation
      // In production, you need to implement MethodChannel
      print('SMS would be sent to: $phoneNumber');
      print('Message: $message');

      // TODO: Implement actual SMS sending via platform channel
      // This is just a placeholder
      await _sendSMSViaPlatform(phoneNumber, message);

    } catch (e) {
      print('SMS sending error: $e');
      rethrow;
    }
  }

  Future<void> _sendSMSViaPlatform(String phoneNumber, String message) async {
    // This is a placeholder for actual SMS implementation
    // You need to create platform-specific code
    // For now, we'll just simulate success
    await Future.delayed(const Duration(milliseconds: 500));
    print('Simulated SMS sent to $phoneNumber');
  }

  Future<void> sendEmergencySMS(List<EmergencyContact> contacts, String message) async {
    print('Sending emergency SMS to ${contacts.length} contacts');

    for (EmergencyContact contact in contacts) {
      try {
        print('Sending to: ${contact.name} - ${contact.phone}');
        await sendSMS(contact.phone, message);
        print('✅ Emergency SMS sent to ${contact.name}');
      } catch (e) {
        print('❌ Failed to send SMS to ${contact.name}: $e');
        // Continue with other contacts even if one fails
      }
    }
  }

  Future<void> callEmergencyContact(EmergencyContact contact) async {
    try {
      print('Calling emergency contact: ${contact.name} - ${contact.phone}');
      await FlutterPhoneDirectCaller.callNumber(contact.phone);
      print('✅ Call initiated to ${contact.name}');
    } catch (e) {
      print('❌ Failed to call ${contact.name}: $e');
      rethrow;
    }
  }

  Future<void> sendSafeWalkMessage(List<EmergencyContact> contacts, String destination, String eta) async {
    final message = "✅ I have reached my destination: $destination safely. ETA: $eta";

    for (EmergencyContact contact in contacts) {
      try {
        await sendSMS(contact.phone, message);
        print('✅ Safe walk message sent to ${contact.name}');
      } catch (e) {
        print('❌ Failed to send safe walk message to ${contact.name}: $e');
      }
    }
  }

  Future<void> sendFakeCallAlert(List<EmergencyContact> contacts) async {
    const message = "🚨 This is an automated alert: I triggered a fake call as a safety precaution. If I don't check in within 10 minutes, please check on me.";

    for (EmergencyContact contact in contacts) {
      try {
        await sendSMS(contact.phone, message);
        print('✅ Fake call alert sent to ${contact.name}');
      } catch (e) {
        print('❌ Failed to send fake call alert to ${contact.name}: $e');
      }
    }
  }

  Future<void> sendSOSMessage(List<EmergencyContact> contacts, String locationUrl) async {
    final message = "🚨 SOS ALERT! I'm in danger! Please help immediately! My location: $locationUrl";

    for (EmergencyContact contact in contacts) {
      try {
        await sendSMS(contact.phone, message);
        print('✅ SOS SMS sent to ${contact.name}');
      } catch (e) {
        print('❌ Failed to send SOS SMS to ${contact.name}: $e');
      }
    }
  }

  // Method to share location via SMS (not emergency)
  Future<void> shareLocationViaSMS(String phoneNumber, String locationUrl, String message) async {
    final fullMessage = "$message\nLocation: $locationUrl";
    await sendSMS(phoneNumber, fullMessage);
  }
}