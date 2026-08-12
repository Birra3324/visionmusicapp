import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:visionmusicapp/core/services/firebase_bootstrap.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  bool get isFirebaseReady => !FirebaseBootstrap.hasPlaceholderConfig;

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
