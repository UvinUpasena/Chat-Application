import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserModel?> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Create user model
        UserModel userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email,
          photoUrl: '',
          lastSeen: DateTime.now().toString(),
        );

        // Add user to firestore
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

        return userModel;
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = result.user;
      if (user != null) {
        // Get user data from firestore
        DocumentSnapshot doc =
            await _firestore.collection('users').doc(user.uid).get();

        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  // Update user online status
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      await _firestore.collection('users').doc(currentUser?.uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().toString(),
      });
    } catch (e) {
      print(e.toString());
    }
  }
}