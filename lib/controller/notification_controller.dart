import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'package:bloc/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../api/apis.dart';
import '../db/entity/ad.dart';
import '../db/entity/celebration.dart';
import '../db/entity/lounge_chat.dart';
import '../db/entity/notification_test.dart';
import '../db/entity/party_guest.dart';
import '../db/entity/reservation.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/ui_preferences.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/network_utils.dart';


class NotificationController extends ChangeNotifier {
  static const String _TAG = 'NotificationController';

  static final NotificationController _instance =
  NotificationController._internal();

  factory NotificationController() {
    return _instance;
  }

  NotificationController._internal();

  /// *********************************************
  ///  OBSERVER PATTERN
  /// *********************************************

  String _firebaseToken = '';
  String get firebaseToken => _firebaseToken;

  String _nativeToken = '';
  String get nativeToken => _nativeToken;

  ReceivedAction? initialAction;

  /// *********************************************
  ///   INITIALIZATION METHODS
  /// *********************************************

  static Future<void> initializeLocalNotifications({required bool debug}) async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'high importance',
          channelDescription: 'notification channel for high importance',
          defaultColor: Constants.lightPrimary,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'chat_channel',
          channelKey: 'chat_channel',
          channelName: 'chats',
          channelDescription: 'notification channel for chats',
          defaultColor: Constants.lightPrimary,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupName: 'high importance',
          channelGroupKey: 'high_importance_channel_group',
        ),
        NotificationChannelGroup(
          channelGroupName: 'chats',
          channelGroupKey: 'chat_channel_group',
        )
      ],
      debug: true,
    );

    await AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) async {
        if (!isAllowed) {
          await AwesomeNotifications().requestPermissionToSendNotifications();
        }
      },
    );

    // Get initial notification action is optional
    _instance.initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static Future<void> initializeRemoteNotifications(
      {required bool debug}) async {
    await Firebase.initializeApp();
    await AwesomeNotificationsFcm().initialize(
        onFcmTokenHandle: NotificationController.myFcmTokenHandle,
        onNativeTokenHandle: NotificationController.myNativeTokenHandle,
        onFcmSilentDataHandle: NotificationController.mySilentDataHandle,
        licenseKeys:
        // On this example app, the app ID / Bundle Id are different
        // for each platform, so i used the main Bundle ID + 1 variation
        [
          // me.carda.awesomeNotificationsFcmExample
          'B3J3yxQbzzyz0KmkQR6rDlWB5N68sTWTEMV7k9HcPBroUh4RZ/Og2Fv6Wc/lE'
              '2YaKuVY4FUERlDaSN4WJ0lMiiVoYIRtrwJBX6/fpPCbGNkSGuhrx0Rekk'
              '+yUTQU3C3WCVf2D534rNF3OnYKUjshNgQN8do0KAihTK7n83eUD60=',

          // me.carda.awesome_notifications_fcm_example
          'UzRlt+SJ7XyVgmD1WV+7dDMaRitmKCKOivKaVsNkfAQfQfechRveuKblFnCp4'
              'zifTPgRUGdFmJDiw1R/rfEtTIlZCBgK3Wa8MzUV4dypZZc5wQIIVsiqi0Zhaq'
              'YtTevjLl3/wKvK8fWaEmUxdOJfFihY8FnlrSA48FW94XWIcFY=',
        ],
        debug: debug);
  }

  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  static ReceivePort? receivePort;
  static Future<void> initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
              (silentData) => onActionReceivedImplementationMethod(silentData)
      );

    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort,
        'notification_action_port'
    );
  }

  //  *********************************************
  ///     LOCAL NOTIFICATION EVENTS
  ///  *********************************************

  static Future<void> getInitialNotificationAction() async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
    if (receivedAction == null) return;

    // Fluttertoast.showToast(
    //     msg: 'Notification action launched app: $receivedAction',
    //   backgroundColor: Colors.deepPurple
    // );
    Logx.d(_TAG, 'App launched by a notification action: $receivedAction');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {

    if(
    receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction
    ){
      // For background actions, you must hold the execution until the end
      print('Message sent via notification input: "${receivedAction.buttonKeyInput}"');

      // await executeLongTaskInBackground();
      return;
    }
    else {
      final payload = receivedAction.payload ?? {};

      String payloadType = payload['type']!;
      Logx.d(_TAG, 'notification click type is $payloadType');

      if (payloadType.isNotEmpty) {
        switch (payloadType) {
          case 'ad':
            Ad ad = Fresh.freshAdMap(jsonDecode(payload['data']!), false);
            BuildContext? appContext = BlocApp.navigatorKey.currentContext;

            FirestoreHelper.updateAdHit(ad.id);

            if(ad.partyName.isNotEmpty && ad.partyChapter.isNotEmpty){
              GoRouter.of(appContext!).pushNamed(RouteConstants.eventRouteName,
                  params: {
                    'partyName': ad.partyName,
                    'partyChapter': ad.partyChapter
                  });
            } else {
              if (UserPreferences.isUserLoggedIn()) {
                GoRouter.of(appContext!).pushNamed(RouteConstants.homeRouteName);
              } else {
                GoRouter.of(appContext!)
                    .pushNamed(RouteConstants.landingRouteName);
              }
            }
            break;
          case 'chat':
            try {
              LoungeChat chat = Fresh.freshLoungeChatMap(jsonDecode(payload['data']!), false);

              BuildContext? appContext = BlocApp.navigatorKey.currentContext;
              GoRouter.of(appContext!).pushNamed(
                  RouteConstants.loungeRouteName,
                  params: {
                    'id': chat.loungeId,
                  });
              Logx.d(_TAG, 'successful');
            } catch (e) {
              Logx.em(_TAG, e.toString());
            }
            break;
          case 'url':
            String url = payload['link']!;

            final uri = Uri.parse(url);
            NetworkUtils.launchInBrowser(uri);
            break;
        }
      }
    }

    return onActionReceivedImplementationMethod(receivedAction);
  }

  /// Use this method to detect when a new notification or a schedule is created
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationCreatedMethod');
  }

  /// Use this method to detect every time that a new notification is displayed
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('onNotificationDisplayedMethod');
  }

  /// Use this method to detect if the user dismissed a notification
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Logx.d(_TAG, 'onDismissActionReceivedMethod');
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction
      ) async {
    Logx.d(_TAG, 'onActionReceivedImplementationMethod');

    BlocApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/notification-page',
            (route) =>
        (route.settings.name != '/notification-page') || route.isFirst,
        arguments: receivedAction);
  }

  ///  *********************************************
  ///     REMOTE NOTIFICATION EVENTS
  ///  *********************************************

  /// Use this method to execute on background when a silent data arrives
  /// (even while terminated)
  @pragma("vm:entry-point")
  static Future<void> mySilentDataHandle(FcmSilentData silentData) async {
    Fluttertoast.showToast(
        msg: 'Silent data received',
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16);

    Logx.d(_TAG, 'SilentData: ${silentData.toString()}');

    if (silentData.createdLifeCycle != NotificationLifeCycle.Foreground) {
      print("bg");
    } else {
      print("FOREGROUND");
    }

    // Map<String, dynamic> data = silentData.data!;

    print('mySilentDataHandle received a FcmSilentData execution');
    await executeLongTaskInBackground();
  }

  // Use this method to detect when a new fcm token is received
  @pragma("vm:entry-point")
  static Future<void> myFcmTokenHandle(String token) async {

    if (token.isNotEmpty){
      if(UserPreferences.isUserLoggedIn()){
        User user = UserPreferences.getUser();
        UserPreferences.setUserFcmToken(token!);
        FirestoreHelper.pushUser(user);
      }

      Logx.d(_TAG, 'firebase token:"$token"');
    }
    else {
      Fluttertoast.showToast(
          msg: 'Fcm token deleted',
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16);

      debugPrint('Firebase Token deleted');
    }

    _instance._firebaseToken = token;
    _instance.notifyListeners();
  }

  /// Use this method to detect when a new native token is received
  @pragma("vm:entry-point")
  static Future<void> myNativeTokenHandle(String token) async {
    Fluttertoast.showToast(
        msg: 'Native token received',
        backgroundColor: Colors.blueAccent,
        textColor: Colors.white,
        fontSize: 16);
    Logx.d(_TAG, 'native token: "$token"');

    _instance._nativeToken = token;
    _instance.notifyListeners();
  }

  ///  *********************************************
  ///     BACKGROUND TASKS TEST
  ///  *********************************************

  static Future<void> executeLongTaskInBackground() async {
    await Future.delayed(const Duration(seconds: 4));
    final url = Uri.parse("http://google.com");
    final re = await http.get(url);
    print(re.body);
    print("long task done");
  }

  ///  *********************************************
  ///     REQUEST NOTIFICATION PERMISSIONS
  ///  *********************************************

  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = BlocApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                    'Allow Awesome Notifications to send you beautiful notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     LOCAL NOTIFICATION CREATION METHODS
  ///  *********************************************

  static Future<void> showNotification({
        required final String title,
        required final String body,
        final String? summary,
        final Map<String, String>? payload,
        final ActionType actionType = ActionType.Default,
        final NotificationLayout notificationLayout = NotificationLayout.Default,
        final NotificationCategory? category,
        final String? bigPicture,
        final String? largeIcon,
        final List<NotificationActionButton>? actionButtons,
        final bool scheduled = false,
        final int? interval,
      }) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();

    if (!isAllowed) {
      isAllowed = await displayNotificationRationale();
    }

    if (!isAllowed) return;

    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1,
          channelKey: 'high_importance_channel',
          title: title,
          body: body,
          // actionType: actionType,
          notificationLayout: notificationLayout,
          summary: summary,
          category: category,
          payload: payload,
          bigPicture: bigPicture,
          largeIcon: largeIcon),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
        interval: interval!,
        timeZone:
        await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      )
          : null,
    );

    // await AwesomeNotifications().createNotification(
    //     content: NotificationContent(
    //         id: -1, // -1 is replaced by a random number
    //         channelKey: 'alerts',
    //         title: 'Huston! The eagle has landed!',
    //         body:
    //         "A small step for a man, but a giant leap to Flutter's community!",
    //         bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',
    //         largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',
    //         notificationLayout: NotificationLayout.BigPicture,
    //         payload: {'notificationId': '1234567890'}),
    //     actionButtons: [
    //       NotificationActionButton(key: 'REDIRECT', label: 'Redirect'),
    //       NotificationActionButton(
    //           key: 'REPLY',
    //           label: 'Reply Message',
    //           requireInputText: true,
    //           actionType: ActionType.SilentAction
    //       ),
    //       NotificationActionButton(
    //           key: 'DISMISS',
    //           label: 'Dismiss',
    //           actionType: ActionType.DismissAction,
    //           isDangerousOption: true)
    //     ]);
  }

  static void showAdNotification(Ad ad) async {
    Map<String, dynamic> objectMap = ad.toMap();
    String jsonString = jsonEncode(objectMap);

    if (ad.imageUrl.isEmpty) {
      await showNotification(title: ad.title, body: ad.message, actionButtons: [
        NotificationActionButton(
            key: 'DISMISS',
            label: 'dismiss',
            actionType: ActionType.DismissAction,
            isDangerousOption: true)
      ]).then((res) {
        FirestoreHelper.updateAdReach(ad.id);
      });
    } else {
      await showNotification(
        title: ad.title,
        body: ad.message,
        bigPicture: ad.imageUrl,
        largeIcon: ad.imageUrl,
        notificationLayout: NotificationLayout.BigPicture,
        payload: {
          "navigate": "true",
          "type": "ad",
          "data": jsonString,
        },
      ).then((res) {
        FirestoreHelper.updateAdReach(ad.id);
      });
    }
  }

  static void showChatNotification(LoungeChat chat) async {
    String photoUrl = '';
    String photoChat = '';

    if(chat.type == 'image'){
      int firstDelimiterIndex = chat.message.indexOf(',');
      if (firstDelimiterIndex != -1) {
        // Use substring to split the string into two parts
        photoUrl = chat.message.substring(0, firstDelimiterIndex);
        photoChat = chat.message.substring(firstDelimiterIndex + 1);
      } else {
        // Handle the case where the delimiter is not found
        photoUrl = chat.message;
      }
    }

    Map<String, dynamic> objectMap = chat.toMap();
    String jsonString = jsonEncode(objectMap);

    String title = '💌 ${chat.loungeName}';

    if (chat.type == 'text') {
      String body = chat.message;

      await showNotification(
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: {
          "navigate": "true",
          "type": "chat",
          "data": jsonString,
        },
      );
    } else {
      await showNotification(
        title: title,
        body: photoChat,
        largeIcon: photoUrl,
        notificationLayout: NotificationLayout.Default,
        payload: {
          "navigate": "true",
          "type": "chat",
          "data": jsonString,
        },
        // actionButtons: [
        //   NotificationActionButton(
        //       key: 'DISMISS',
        //       label: 'dismiss',
        //       actionType: ActionType.DismissAction,
        //       isDangerousOption: true)
        // ]
      );
    }
  }

  static void showDefaultNotification(String title, String body) async {
    await showNotification(
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        actionButtons: [
          NotificationActionButton(
              key: 'DISMISS',
              label: 'dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true)
        ]);
  }

  static void showUrlLinkNotification(String title, String body, String url ) async {
    await showNotification(
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        payload: {
          "navigate": "true",
          "type": "url",
          "link": url
        },
        actionButtons: [
          NotificationActionButton(
              key: 'DISMISS',
              label: 'dismiss',
              actionType: ActionType.DismissAction,
              isDangerousOption: true),
          NotificationActionButton(
            key: 'OPEN_URL_ACTION',
            label: '💖 review bloc',
            actionType: ActionType.Default,
          ),

        ]);
  }

  static Future<void> resetBadge() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> deleteToken() async {
    await AwesomeNotificationsFcm().deleteToken();
    await Future.delayed(Duration(seconds: 5));
    await requestFirebaseToken();
  }

  ///  *********************************************
  ///     REMOTE TOKEN REQUESTS
  ///  *********************************************

  static Future<String> requestFirebaseToken() async {
    if (await AwesomeNotificationsFcm().isFirebaseAvailable) {
      try {
        return await AwesomeNotificationsFcm().requestFirebaseAppToken();
      } catch (exception) {
        debugPrint('$exception');
      }
    } else {
      debugPrint('Firebase is not available on this project');
    }
    return '';
  }

}