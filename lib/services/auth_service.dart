import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safeher/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore? _firestore;

  AuthService() {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      print('⚠️ Firestore not initialized: $e');
    }
  }

  // Check current user
  User? get currentUser => _auth.currentUser;

  // Login with email and password
  Future<UserModel?> login(String email, String password) async {
    try {
      print('🚀 Attempting login with email: $email');

      // Try to sign in
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase login successful, uid: ${result.user!.uid}');

      // If Firestore is available, try to get user data
      UserModel? userModel;
      if (_firestore != null) {
        try {
          DocumentSnapshot doc = await _firestore!.collection('users').doc(result.user!.uid).get();
          if (doc.exists) {
            userModel = UserModel.fromMap(doc.data() as Map<String, dynamic>);
            print('📄 User document found in Firestore');
          }
        } catch (e) {
          print('⚠️ Error reading from Firestore: $e');
        }
      }

      // If no user data in Firestore, create default user
      userModel ??= UserModel(
        uid: result.user!.uid,
        name: result.user!.displayName ?? 'User',
        email: result.user!.email ?? email,
        phone: result.user!.phoneNumber ?? '',
        sosMessage: "I'm in danger! Please help me. My location is: ",
        shakeSensitivity: 15.0,
        pin: '0000',
        emergencyContacts: [],
        darkMode: false,
      );

      // Try to save to Firestore if available
      if (_firestore != null) {
        try {
          await _firestore!.collection('users').doc(result.user!.uid).set(userModel.toMap());
          print('💾 User saved to Firestore');
        } catch (e) {
          print('⚠️ Error saving to Firestore: $e');
        }
      }

      return userModel;
    } catch (e) {
      print('❌ Login error: $e');
      return null;
    }
  }

  // Sign up new user
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      print('🚀 Attempting signup: $email, name: $name');

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ Firebase signup successful, uid: ${result.user!.uid}');

      // Create user model
      UserModel user = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
        phone: '',
        sosMessage: "I'm in danger! Please help me. My location is: ",
        shakeSensitivity: 15.0,
        pin: '0000',
        emergencyContacts: [],
        darkMode: false,
      );

      // Try to save to Firestore if available
      if (_firestore != null) {
        try {
          await _firestore!.collection('users').doc(result.user!.uid).set(user.toMap());
          print('💾 User saved to Firestore');
        } catch (e) {
          print('⚠️ Error saving to Firestore: $e');
        }
      }

      return user;
    } catch (e) {
      print('❌ Signup error: $e');
      return null;
    }
  }

  // Get user data by UID
  Future<UserModel?> getUserData(String uid) async {
    try {
      if (_firestore != null) {
        DocumentSnapshot doc = await _firestore!.collection('users').doc(uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('⚠️ Error getting user data: $e');
      return null;
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Check if user is logged in
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user != null) {
        return await getUserData(user.uid);
      }
      return null;
    });
  }
}