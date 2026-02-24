import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safeher/models/emergency_contact.dart';
import 'package:safeher/models/user_model.dart';
import 'package:safeher/utils/constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // User Operations
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersPath)
          .doc(user.uid)
          .set(user.toMap());
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(FirebaseConstants.usersPath)
          .doc(uid)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection(FirebaseConstants.usersPath)
          .doc(user.uid)
          .update(user.toMap());
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  // Emergency Contacts Operations
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      if (currentUserId == null) return [];

      DocumentSnapshot userDoc = await _firestore
          .collection(FirebaseConstants.usersPath)
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<dynamic> contactsData = data[FirebaseConstants.contactsPath] ?? [];

        return contactsData
            .map((contactData) => EmergencyContact.fromMap(contactData))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error getting emergency contacts: $e');
      return [];
    }
  }

  Future<void> addEmergencyContact(EmergencyContact contact) async {
    try {
      if (currentUserId == null) return;

      DocumentReference userRef = _firestore
          .collection(FirebaseConstants.usersPath)
          .doc(currentUserId);

      // Get current contacts
      DocumentSnapshot userDoc = await userRef.get();
      List<dynamic> currentContacts = [];

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        currentContacts = data[FirebaseConstants.contactsPath] ?? [];
      }

      // Check contact limit
      if (currentContacts.length >= AppConstants.maxEmergencyContacts) {
        throw Exception('Maximum emergency contacts limit reached');
      }

      // Add new contact
      currentContacts.add(contact.toMap());

      // Update user document
      await userRef.update({
        FirebaseConstants.contactsPath: currentContacts,
      });
    } catch (e) {
      print('Error adding emergency contact: $e');
      rethrow;
    }
  }

  Future<void> updateEmergencyContact(int index, EmergencyContact contact) async {
    try {
      if (currentUserId == null) return;

      DocumentReference userRef = _firestore
          .collection(FirebaseConstants.usersPath)
          .doc(currentUserId);

      // Get current contacts
      DocumentSnapshot userDoc = await userRef.get();
      List<dynamic> currentContacts = [];

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        currentContacts = data[FirebaseConstants.contactsPath] ?? [];
      }

      // Update contact at index
      if (index >= 0 && index < currentContacts.length) {
        currentContacts[index] = contact.toMap();

        // Update user document
        await userRef.update({
          FirebaseConstants.contactsPath: currentContacts,
        });
      }
    } catch (e) {
      print('Error updating emergency contact: $e');
      rethrow;
    }
  }

  Future<void> deleteEmergencyContact(int index) async {
    try {
      if (currentUserId == null) return;

      DocumentReference userRef = _firestore
          .collection(FirebaseConstants.usersPath)
          .doc(currentUserId);

      // Get current contacts
      DocumentSnapshot userDoc = await userRef.get();
      List<dynamic> currentContacts = [];

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        currentContacts = data[FirebaseConstants.contactsPath] ?? [];
      }

      // Remove contact at index
      if (index >= 0 && index < currentContacts.length) {
        currentContacts.removeAt(index);

        // Update user document
        await userRef.update({
          FirebaseConstants.contactsPath: currentContacts,
        });
      }
    } catch (e) {
      print('Error deleting emergency contact: $e');
      rethrow;
    }
  }

  // SOS Alerts Operations
  Future<void> logSOSAlert({
    required String userId,
    required double latitude,
    required double longitude,
    required String address,
    required List<String> notifiedContacts,
  }) async {
    try {
      await _firestore
          .collection(FirebaseConstants.sosAlertsPath)
          .add({
        'userId': userId,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'notifiedContacts': notifiedContacts,
        'timestamp': FieldValue.serverTimestamp(),
        'resolved': false,
      });
    } catch (e) {
      print('Error logging SOS alert: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSOSAlerts(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(FirebaseConstants.sosAlertsPath)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => {
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      })
          .toList();
    } catch (e) {
      print('Error getting SOS alerts: $e');
      return [];
    }
  }

  // Settings Operations
  Future<void> updateUserSettings({
    required String userId,
    String? sosMessage,
    double? shakeSensitivity,
    bool? darkMode,
  }) async {
    try {
      Map<String, dynamic> updates = {};

      if (sosMessage != null) updates['sosMessage'] = sosMessage;
      if (shakeSensitivity != null) updates['shakeSensitivity'] = shakeSensitivity;
      if (darkMode != null) updates['darkMode'] = darkMode;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(FirebaseConstants.usersPath)
            .doc(userId)
            .update(updates);
      }
    } catch (e) {
      print('Error updating user settings: $e');
      rethrow;
    }
  }

  // ADD THIS METHOD: Incident Report
  Future<void> logIncidentReport({
    required String userId,
    required String incidentType,
    required String description,
    required String location,
    required String time,
    bool isAnonymous = false,
    String? imageUrl,
  }) async {
    try {
      await _firestore.collection('incident_reports').add({
        'userId': userId,
        'incidentType': incidentType,
        'description': description,
        'location': location,
        'time': time,
        'isAnonymous': isAnonymous,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e) {
      print('Error logging incident report: $e');
      rethrow;
    }
  }

  // ADD THIS METHOD: Update User Profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (profileImage != null) updates['profileImage'] = profileImage;

      if (updates.isNotEmpty) {
        await _firestore
            .collection(FirebaseConstants.usersPath)
            .doc(userId)
            .update(updates);
      }
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }
}