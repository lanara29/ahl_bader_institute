import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Master Credentials for Admin / Institute Management
  static const String masterUsername = 'أهل بدر';
  static const String masterPassword = '1122';

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Authentication check (Firebase Auth + Master Credentials Support)
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanInput = email.trim();
    final cleanPass = password.trim();

    // 1️⃣ Check Master Credentials first
    final enteredUser = cleanInput
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');

    final targetUser = masterUsername
        .trim()
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا');

    if (enteredUser.toLowerCase() == targetUser.toLowerCase() &&
        cleanPass == masterPassword) {
      try {
        if (_auth.currentUser == null) {
          await _auth.signInAnonymously();
        }
      } catch (_) {
        // Continue even if anonymous sign-in is disabled in Firebase console
      }
      return true;
    }

    // 2️⃣ Firebase Auth Email/Password Sign-In
    if (cleanInput.contains('@')) {
      try {
        await _auth.signInWithEmailAndPassword(
          email: cleanInput,
          password: cleanPass,
        );
        return true;
      } on FirebaseAuthException catch (e) {
        debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
        rethrow;
      } catch (e) {
        debugPrint('Auth error: $e');
        return false;
      }
    }

    return false;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}
