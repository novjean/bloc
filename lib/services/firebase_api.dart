import 'package:bloc/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';
import '../utils/logx.dart';
import 'notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logx.i('main', 'handling a background message ${message.messageId}');

  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  NotificationService.handleMessage(message, true);
}
class FirebaseApi {
  static const String _TAG = 'FirebaseApi';

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    if(!kIsWeb){
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      Logx.d(_TAG, 'fcm token: ${fcmToken!}');

      // Set the background messaging handler early on, as a named top-level function
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } else {
      Logx.d(_TAG, 'fcm not supported on web');
    }
  }
}