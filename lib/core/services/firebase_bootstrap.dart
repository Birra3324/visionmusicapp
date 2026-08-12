import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:visionmusicapp/firebase_options.dart';

class FirebaseBootstrapResult {
  final FirebaseApp? app;
  final Object? error;
  final bool isConfigured;

  const FirebaseBootstrapResult({
    required this.app,
    required this.error,
    required this.isConfigured,
  });

  bool get isReady => app != null && error == null && isConfigured;
}

class FirebaseBootstrap {
  /// Returns true if the options for the *current* platform still have
  /// placeholder values. Hardened to check the live platform only — so having
  /// REPLACE_WITH_ values left over for Linux/Windows does not block iOS.
  static bool get hasPlaceholderConfig {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      return _looksLikePlaceholder(options.apiKey) ||
          _looksLikePlaceholder(options.appId) ||
          _looksLikePlaceholder(options.projectId) ||
          _looksLikePlaceholder(options.messagingSenderId);
    } catch (_) {
      // currentPlatform throws on unsupported platforms (e.g. web without
      // web options). Treat that as "not configured".
      return true;
    }
  }

  static bool _looksLikePlaceholder(String value) {
    return value.isEmpty || value.startsWith('REPLACE_WITH_');
  }

  static Future<FirebaseBootstrapResult> initialize() async {
    if (hasPlaceholderConfig) {
      debugPrint(
        'Firebase not configured for this platform. Skipping Firebase.initializeApp().',
      );
      return const FirebaseBootstrapResult(
        app: null,
        error: null,
        isConfigured: false,
      );
    }

    try {
      final app = await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );

      FirebaseAuth.instance;
      FirebaseStorage.instance;

      // App Check enforcement is enabled from the Firebase console only after
      // monitoring confirms legitimate production traffic is receiving valid
      // tokens. Debug providers keep simulator/development builds usable.
      await FirebaseAppCheck.instance.activate(
        androidProvider: kReleaseMode
            ? AndroidProvider.playIntegrity
            : AndroidProvider.debug,
        appleProvider: kReleaseMode
            ? AppleProvider.appAttestWithDeviceCheckFallback
            : AppleProvider.debug,
      );

      return FirebaseBootstrapResult(app: app, error: null, isConfigured: true);
    } catch (error) {
      debugPrint('Firebase bootstrap failed: $error');
      return FirebaseBootstrapResult(
        app: null,
        error: error,
        isConfigured: true,
      );
    }
  }
}
