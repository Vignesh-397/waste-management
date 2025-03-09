import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Register User with Email & Password
  Future<String?> registerUser(
    String email,
    String password,
    String role,
  ) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'role': role,
      });

      return null; // Registration successful, return null (no error)
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Login User with Email & Password
  Future<String?> loginUser(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Login successful, return null (no error)
    } on FirebaseAuthException catch (e) {
      return _handleAuthError(e);
    } catch (e) {
      return "An unexpected error occurred. Please try again.";
    }
  }

  // Logout User
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Error Handling Helper
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return "This email is already registered. Try logging in.";
      case 'weak-password':
        return "The password is too weak. Use a stronger password.";
      case 'invalid-email':
        return "The email address is invalid. Check and try again.";
      case 'user-not-found':
        return "No account found with this email. Please register first.";
      case 'wrong-password':
        return "Incorrect password. Please try again.";
      case 'too-many-requests':
        return "Too many login attempts. Try again later.";
      default:
        return "Authentication failed. Please try again.";
    }
  }
}
