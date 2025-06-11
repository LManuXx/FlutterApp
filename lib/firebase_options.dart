
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
    apiKey: 'AIzaSyA0Z6I5kOjFcZ08vlralvkwkQ3Oy9KOnk0',
    appId: '1:985537482037:web:5ca662ca771ee51bcfd07c',
    messagingSenderId: '985537482037',
    projectId: 'madrid-fonts',
    authDomain: 'madrid-fonts.firebaseapp.com',
    storageBucket: 'madrid-fonts.firebasestorage.app',
    measurementId: 'G-BR1SXTRXKW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDVh2HoSSFengXISLVoYn4TU5MaZoHV0o4',
    appId: '1:985537482037:android:2af8746450d1dd8bcfd07c',
    messagingSenderId: '985537482037',
    projectId: 'madrid-fonts',
    storageBucket: 'madrid-fonts.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDiRKvoiYS-YrDmtiWoUUz-SlFYZEXg6E4',
    appId: '1:985537482037:ios:3cb29f205f10da90cfd07c',
    messagingSenderId: '985537482037',
    projectId: 'madrid-fonts',
    storageBucket: 'madrid-fonts.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDiRKvoiYS-YrDmtiWoUUz-SlFYZEXg6E4',
    appId: '1:985537482037:ios:3cb29f205f10da90cfd07c',
    messagingSenderId: '985537482037',
    projectId: 'madrid-fonts',
    storageBucket: 'madrid-fonts.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA0Z6I5kOjFcZ08vlralvkwkQ3Oy9KOnk0',
    appId: '1:985537482037:web:7ae8f90b88f80168cfd07c',
    messagingSenderId: '985537482037',
    projectId: 'madrid-fonts',
    authDomain: 'madrid-fonts.firebaseapp.com',
    storageBucket: 'madrid-fonts.firebasestorage.app',
    measurementId: 'G-7621QNJSKJ',
  );
}
