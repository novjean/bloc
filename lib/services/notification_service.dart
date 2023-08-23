import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/db/entity/lounge_chat.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../db/entity/ad.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/route_constants.dart';
import '../utils/logx.dart';

class NotificationService {
  static const String _TAG = 'NotificationService';

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'high importance',
          channelDescription: 'notification channel for high importance',
          defaultColor: const Color(0xFF9D50DD),
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
          defaultColor: const Color(0xFF9D50DD),
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

    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
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
    debugPrint('onDismissActionReceivedMethod');
  }

  /// Use this method to detect when the user taps on a notification or action button
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('onActionReceivedMethod');
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
      }
    }
  }

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
  }

  /** notification **/
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
      ]);
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
      );
    }
  }

  static void showChatNotification(LoungeChat chat) async {
    Map<String, dynamic> objectMap = chat.toMap();
    String jsonString = jsonEncode(objectMap);

    String title = chat.loungeName;

    if (chat.type == 'text') {
      String body = chat.message;

      await showNotification(
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Messaging,
        payload: {
          "navigate": "false",
          "type": "chat",
          "data": jsonString,
        },
      );
    } else {
      String body = 'tap to learn more';

      await showNotification(
        title: title,
        body: body,
        largeIcon: chat.message,
        notificationLayout: NotificationLayout.Messaging,
        payload: {
          "navigate": "false",
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
}
