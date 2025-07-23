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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAubPdtDS0JfTjhS9gdsPWXn1hwdInWa6I',
    appId: '1:777338031688:web:1bf33b05fe4a84002cd27d',
    messagingSenderId: '777338031688',
    projectId: 'ticketgo-86d2b',
    authDomain: 'ticketgo-86d2b.firebaseapp.com',
    storageBucket: 'ticketgo-86d2b.firebasestorage.app',
    measurementId: 'G-F9E3WH4GCF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBNj8undgINex183zH9iJ89fWBOLojM7jQ',
    appId: '1:777338031688:android:944e17b5f7fd7cb42cd27d',
    messagingSenderId: '777338031688',
    projectId: 'ticketgo-86d2b',
    storageBucket: 'ticketgo-86d2b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TON_API_KEY_IOS',
    appId: 'TON_APP_ID_IOS',
    messagingSenderId: 'TON_SENDER_ID',
    projectId: 'TON_PROJECT_ID',
  );
}