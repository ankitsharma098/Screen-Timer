// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC1C6SvFM74EhTOkBCQwNbIkbyEbL_fiwY',
    appId: '1:716242497418:web:54e748b80b12ff837e6273',
    messagingSenderId: '716242497418',
    projectId: 'tracker-d1e9d',
    authDomain: 'tracker-d1e9d.firebaseapp.com',
    storageBucket: 'tracker-d1e9d.appspot.com',
    measurementId: 'G-1VVNLNFBKL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCQ3CexXGGfrpiPcSBfYpFu1Osbl3ybtD8',
    appId: '1:716242497418:android:00c55044d8fdf5c17e6273',
    messagingSenderId: '716242497418',
    projectId: 'tracker-d1e9d',
    storageBucket: 'tracker-d1e9d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDv6-_ifsI1pQ4vwZvGJxv8NSxpE8HDwgQ',
    appId: '1:716242497418:ios:f7d028afc23d96727e6273',
    messagingSenderId: '716242497418',
    projectId: 'tracker-d1e9d',
    storageBucket: 'tracker-d1e9d.appspot.com',
    iosBundleId: 'com.example.untitled4',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDv6-_ifsI1pQ4vwZvGJxv8NSxpE8HDwgQ',
    appId: '1:716242497418:ios:f7d028afc23d96727e6273',
    messagingSenderId: '716242497418',
    projectId: 'tracker-d1e9d',
    storageBucket: 'tracker-d1e9d.appspot.com',
    iosBundleId: 'com.example.untitled4',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC1C6SvFM74EhTOkBCQwNbIkbyEbL_fiwY',
    appId: '1:716242497418:web:34e078d101a7b1627e6273',
    messagingSenderId: '716242497418',
    projectId: 'tracker-d1e9d',
    authDomain: 'tracker-d1e9d.firebaseapp.com',
    storageBucket: 'tracker-d1e9d.appspot.com',
    measurementId: 'G-1GDSR2C7J6',
  );
}
