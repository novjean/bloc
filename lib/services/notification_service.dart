import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:bloc/db/entity/lounge_chat.dart';
import 'package:bloc/helpers/firestore_helper.dart';
import 'package:bloc/utils/string_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/apis.dart';
import '../db/entity/ad.dart';
import '../db/entity/celebration.dart';
import '../db/entity/notification_test.dart';
import '../db/entity/party_guest.dart';
import '../db/entity/reservation.dart';
import '../db/shared_preferences/ui_preferences.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/fresh.dart';
import '../main.dart';
import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../utils/logx.dart';
import '../utils/network_utils.dart';

class NotificationService {
  static const String _TAG = 'NotificationService';

  static int lastNotificationTime = 0;

  // Keep track of the notification IDs
  static String notificationId = '';

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
          channelGroupKey: 'high_importance_channel',
          channelKey: 'high_importance_channel',
          channelName: 'high importance',
          channelDescription: 'notification channel for high importance',
          defaultColor: Constants.primary,
          ledColor: Colors.red,
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
          defaultColor: Constants.primary,
          ledColor: Colors.orange,
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
        case 'url':
          String url = payload['link']!;

          final uri = Uri.parse(url);
          NetworkUtils.launchInBrowser(uri);
          break;
      }
    }
  }

  static void handleMessage(RemoteMessage message, bool isBackground){
    Logx.d(_TAG, 'prev notification id: $notificationId');
    Map<String, dynamic> data = message.data;
    String type = '';
    try{
      type = data['type'];
    } catch(e) {
      Logx.em(_TAG, e.toString());
    }

    switch(type){
      case 'lounge_chats':{
        LoungeChat chat = Fresh.freshLoungeChatMap(jsonDecode(data['document']), false);
        if(notificationId == chat.id){
          return;
        } else {
          notificationId = chat.id;

          UiPreferences.setHomePageIndex(2);

          if(isBackground){
            String title = chat.loungeName;

            String message = '';
            if(chat.type == 'image'){
              String photoUrl = '';
              String photoChat = '';

              if (chat.type == 'image') {
                int firstDelimiterIndex = chat.message.indexOf('|');
                if (firstDelimiterIndex != -1) {
                  // Use substring to split the string into two parts
                  photoChat = chat.message.substring(0, firstDelimiterIndex);
                  photoUrl = chat.message.substring(firstDelimiterIndex + 1);
                } else {
                  // Handle the case where the delimiter is not found
                  photoUrl = chat.message;
                }
              }

              message = '📷 ${StringUtils.firstFewWords(photoChat, 15)} ...';
            } else {
              message = '${StringUtils.firstFewWords(chat.message, 15)} ...';
            }
            NotificationService.showDefaultNotification(title, message);
          } else {
            LoungeChat chat = Fresh.freshLoungeChatMap(jsonDecode(data['document']), false);

            if(notificationId == chat.id){
              Logx.d(_TAG, 'same notification, not showing');
              return;
            } else {
              if(UserPreferences.isUserLoggedIn() && chat.userId != UserPreferences.myUser.id){
                if(UserPreferences.getListLounges().contains(chat.loungeId)){
                  NotificationService.showChatNotification(chat);
                }
              }
            }
          }
        }

        break;
      }
      case 'ads':{
        Ad ad = Fresh.freshAdMap(jsonDecode(data['document']), false);
        if(notificationId == ad.id){
          return;
        } else {
          notificationId = ad.id;

          FirestoreHelper.updateAdReach(ad.id);
          NotificationService.showAdNotification(ad);
        }
        break;
      }
      case 'party_guest':{
        PartyGuest partyGuest = Fresh.freshPartyGuestMap(jsonDecode(data['document']), false);
        if(notificationId == partyGuest.id){
          return;
        } else {
          notificationId = partyGuest.id;

          if(!partyGuest.isApproved){
            String title = '${partyGuest.name} ${partyGuest.surname}';
            String body = '${partyGuest.guestStatus} : ${partyGuest.guestsCount}';

            NotificationService.showDefaultNotification(title, body);
          } else {
            Logx.ist(_TAG, 'guest list: ${partyGuest.name} added');
          }
        }
        break;
      }
      case 'reservations':{
        Reservation reservation = Fresh.freshReservationMap(jsonDecode(data['document']), false);
        if(notificationId == reservation.id){
          return;
        } else {
          notificationId = reservation.id;

          String title = 'request : table reservation';
          String body = '${reservation.name} : ${reservation.guestsCount}';
          NotificationService.showDefaultNotification(title, body);
        }
        break;
      }
      case 'celebrations':{
        Celebration celebration = Fresh.freshCelebrationMap(jsonDecode(data['document']), false);

        if(notificationId == celebration.id){
          return;
        } else {
          notificationId = celebration.id;

          String title = 'request : celebration';
          String body = '${celebration.name} : ${celebration.guestsCount}';
          NotificationService.showDefaultNotification(title, body);
        }
        break;
      }
      case Apis.GoogleReviewBloc:
      case Apis.GoogleReviewFreq:{
        String title = 'Fun night at HQ 🤩! Review us?';
        String message = 'Hope you had a wonderful time tonight at as a guest in our community! A Google review will help us improve and ensure every night at our bar is an unforgettable experience. Reach home safe and see you soon 🤗🤍'.toLowerCase();
        String url = data['link'];

        if(notificationId == url){
          return;
        } else {
          notificationId = url;

          NotificationService.showGoogleReviewUrlNotification(title, message, url);
        }
        break;
      }
      case 'notification_tests': {
        NotificationTest notificationTest = Fresh.freshNotificationTestMap(jsonDecode(data['document']), false);

        String? title ='notification test!';
        String? body = notificationTest.text;

        if(notificationId == notificationTest.id){
          return;
        } else {
          notificationId = notificationTest.id;

          NotificationService.showDefaultNotification(title!, body!);
        }
        break;
      }
      case 'sos':
      case 'offer':
      case 'order': {
        Logx.i(_TAG, 'notification handled by firebase');
        break;
      }
      default:{
        String? title = message.notification!.title;
        String? body = message.notification!.body;

        if(notificationId == title){
          return;
        } else {
          notificationId = title!;

          NotificationService.showDefaultNotification(title, body!);
        }
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
    Logx.d(_TAG, 'showNotification: $title');

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
    String photoUrl = '';
    String photoChat = '';

    if (chat.type == 'image') {
      int firstDelimiterIndex = chat.message.indexOf('|');
      if (firstDelimiterIndex != -1) {
        // Use substring to split the string into two parts
        photoChat = chat.message.substring(0, firstDelimiterIndex);
        photoUrl = chat.message.substring(firstDelimiterIndex + 1);
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

  static void showGoogleReviewUrlNotification(String title, String body, String url ) async {
    await showNotification(
    title: title,
    body: body,
    notificationLayout: NotificationLayout.Default,
      payload: {
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
        label: '💯 review',
        actionType: ActionType.Default,
      ),

    ]);
  }
}
