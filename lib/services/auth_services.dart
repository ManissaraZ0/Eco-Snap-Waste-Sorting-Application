import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );

  // Current user
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---------------------------
  // Email Login
  // ---------------------------
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return {
        'success': true,
        'user': result.user,
        'message': 'Login successful',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    }
  }

  // ---------------------------
  // Email Sign Up
  // ---------------------------
  Future<Map<String, dynamic>> signUpWithEmail({
    required String email,
    required String password,
    String displayName = '',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await result.user?.sendEmailVerification();

      // สร้างเอกสารใน Firestore สำหรับผู้ใช้ใหม่
      final user = result.user!;
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'display_name': displayName,
        'profile_picture': 'assets/img/u1.png',
        'high_score': 0,
        'created_at': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': user,
        'message': 'Account created successfully',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    }
  }

  // ---------------------------
  // Google Sign-In
  // ---------------------------
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return {'success': false, 'message': 'Google sign-in cancelled'};
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      final user = result.user!;

      // ⭐ สร้างเอกสารใน Firestore หากยังไม่มี
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      final docSnapshot = await userDoc.get();
      if (!docSnapshot.exists) {
        await userDoc.set({
          'uid': user.uid,
          'email': user.email,
          'display_name': user.displayName ?? '',
          'profile_picture': user.photoURL ?? '',
          'high_score': 0,
          'created_at': FieldValue.serverTimestamp(),
        });
      }

      return {
        'success': true,
        'user': user,
        'message': 'Google sign-in successful',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } on PlatformException catch (e) {
      return {'success': false, 'message': 'Platform error: ${e.message}'};
    }
  }

  // ---------------------------
  // Password Reset
  // ---------------------------
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      final trimmedEmail = email.trim();
      await _auth.sendPasswordResetEmail(email: trimmedEmail);

      return {
        'success': true,
        'message': 'Password reset email sent',
        'email': trimmedEmail,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    }
  }

  // ---------------------------
  // Sign Out
  // ---------------------------
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // ---------------------------
  // Error messages
  // ---------------------------
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      default:
        return 'An error occurred. Please try again';
    }
  }
}
