// File generated from google-services.json — traveloop-be00e
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // ── ANDROID ─────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'AIzaSyCSR7U0UmJle6cZRYufENUkZsdwGAe7IJU',
    appId:             '1:278960721253:android:b21447c3e5ced17a7fe58c',
    messagingSenderId: '278960721253',
    projectId:         'traveloop-be00e',
    storageBucket:     'traveloop-be00e.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────────
  // Add your iOS app in Firebase Console to get these values
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey:            'AIzaSyCSR7U0UmJle6cZRYufENUkZsdwGAe7IJU',
    appId:             '1:278960721253:ios:placeholder',
    messagingSenderId: '278960721253',
    projectId:         'traveloop-be00e',
    storageBucket:     'traveloop-be00e.firebasestorage.app',
    iosClientId:       '278960721253-7kjuv5ag4p8m4vo10kjf96bkbf56k0e8.apps.googleusercontent.com',
    iosBundleId:       'com.example.traveloop',
  );

  // ── macOS ────────────────────────────────────────────────────
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey:            'AIzaSyCSR7U0UmJle6cZRYufENUkZsdwGAe7IJU',
    appId:             '1:278960721253:ios:placeholder',
    messagingSenderId: '278960721253',
    projectId:         'traveloop-be00e',
    storageBucket:     'traveloop-be00e.firebasestorage.app',
    iosClientId:       '278960721253-7kjuv5ag4p8m4vo10kjf96bkbf56k0e8.apps.googleusercontent.com',
    iosBundleId:       'com.example.traveloop',
  );

  // ── Web ──────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyCSR7U0UmJle6cZRYufENUkZsdwGAe7IJU',
    appId:             '1:278960721253:web:placeholder',
    messagingSenderId: '278960721253',
    projectId:         'traveloop-be00e',
    storageBucket:     'traveloop-be00e.firebasestorage.app',
    authDomain:        'traveloop-be00e.firebaseapp.com',
  );
}