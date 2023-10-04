import 'package:bloc/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../firebase_options.dart';
import '../utils/logx.dart';
import 'notification_service.dart';

@pragma('vm:entry-point')
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
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Logx.d(_TAG, 'notification permission auth status ${settings.authorizationStatus.name}');

      final fcmToken = await _firebaseMessaging.getToken();
      Logx.d(_TAG, 'fcm token: ${fcmToken!}');

      RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // Set the background messaging handler early on, as a named top-level function
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    } else {
      Logx.i(_TAG, 'fcm in web mode');
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      Logx.d(_TAG, 'notification permission auth status ${settings.authorizationStatus.name}');
    }
  }

  void _handleMessage(RemoteMessage message) {
    String type = message.data['type'];

    if (type == 'notification_tests') {

      Logx.ist(_TAG, 'notification test is received');

      // Navigator.pushNamed(context, '/chat',
      //   arguments: ChatArguments(message),
      // );
    }
  }
}