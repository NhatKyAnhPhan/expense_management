// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBlpFgF2tY4J-tRMbsRnf58H-GQzwB4tXU',
    appId: '1:688359730374:web:069fbbc7c495c88c0e7bc7',
    messagingSenderId: '688359730374',
    projectId: 'ancient-scope-x14dk',
    authDomain: 'ancient-scope-x14dk.firebaseapp.com',
    storageBucket: 'ancient-scope-x14dk.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBlpFgF2tY4J-tRMbsRnf58H-GQzwB4tXU',
    appId: '1:688359730374:web:069fbbc7c495c88c0e7bc7',
    messagingSenderId: '688359730374',
    projectId: 'ancient-scope-x14dk',
    storageBucket: 'ancient-scope-x14dk.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBlpFgF2tY4J-tRMbsRnf58H-GQzwB4tXU',
    appId: '1:688359730374:web:069fbbc7c495c88c0e7bc7',
    messagingSenderId: '688359730374',
    projectId: 'ancient-scope-x14dk',
    storageBucket: 'ancient-scope-x14dk.firebasestorage.app',
  );
}