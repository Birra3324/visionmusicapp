import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Placeholder Firebase options file.
/// Replace these values by running:
/// flutterfire configure
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform. Run flutterfire configure.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKkEKhXtW95s5ys5EyR8JqaCXYLQ_JpeE',
    appId: '1:190873708714:android:57de878985e6c1782b08d3',
    messagingSenderId: '190873708714',
    projectId: 'visionmusic-dev',
    storageBucket: 'visionmusic-dev.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDx0xJc4xpiwYYplS7alaL_xO0H6B56Gro',
    appId: '1:190873708714:ios:a219e9ab0dcc4fd72b08d3',
    messagingSenderId: '190873708714',
    projectId: 'visionmusic-dev',
    storageBucket: 'visionmusic-dev.firebasestorage.app',
    iosBundleId: 'com.visionmusic.app',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDx0xJc4xpiwYYplS7alaL_xO0H6B56Gro',
    appId: '1:190873708714:ios:a219e9ab0dcc4fd72b08d3',
    messagingSenderId: '190873708714',
    projectId: 'visionmusic-dev',
    storageBucket: 'visionmusic-dev.firebasestorage.app',
    iosBundleId: 'com.visionmusic.app',
  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_WINDOWS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'REPLACE_WITH_FIREBASE_API_KEY',
    appId: 'REPLACE_WITH_LINUX_APP_ID',
    messagingSenderId: 'REPLACE_WITH_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBMab5GyKpcsmDHyJMpHFqzev2UxKMJTwA',
    appId: '1:190873708714:web:941ac983abaa714a2b08d3',
    messagingSenderId: '190873708714',
    projectId: 'visionmusic-dev',
    authDomain: 'visionmusic-dev.firebaseapp.com',
    storageBucket: 'visionmusic-dev.firebasestorage.app',
    measurementId: 'G-GKZ8HSXCET',
  );
}
