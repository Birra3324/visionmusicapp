import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:visionmusicapp/core/services/firebase_bootstrap.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// True only when this platform has real Firebase options **and**
  /// [Firebase.initializeApp] has actually succeeded.
  ///
  /// Checking options alone was not enough: Android/iOS client keys are
  /// present in-repo, so a failed or skipped bootstrap still looked "ready"
  /// and enabled Google Sign-In, which then crashed on `FirebaseAuth`.
  bool get isFirebaseReady {
    if (FirebaseBootstrap.hasPlaceholderConfig) return false;
    return Firebase.apps.isNotEmpty;
  }

  Stream<User?> authStateChanges() {
    if (!isFirebaseReady) {
      return const Stream<User?>.empty();
    }
    return FirebaseAuth.instance.authStateChanges();
  }

  Future<UserCredential> signInWithGoogle() async {
    if (!isFirebaseReady) {
      throw Exception(
        'Firebase is not configured yet. Run flutterfire configure first.',
      );
    }

    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return FirebaseAuth.instance.signInWithPopup(provider);
    }

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw Exception('Google sign-in was cancelled.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    if (!isFirebaseReady) {
      return;
    }

    await Future.wait([
      FirebaseAuth.instance.signOut(),
      GoogleSignIn().signOut(),
    ]);
  }
}
