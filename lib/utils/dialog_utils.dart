import 'package:bloc/db/entity/party_photo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';

import '../db/entity/lounge.dart';
import '../db/entity/user.dart';
import '../db/shared_preferences/user_preferences.dart';
import '../helpers/firestore_helper.dart';
import '../helpers/fresh.dart';
import 'challenge_utils.dart';
import 'constants.dart';
import 'file_utils.dart';
import 'logx.dart';
import 'network_utils.dart';

class DialogUtils {
  static final String _TAG = 'DialogUtils';

  static showDownloadAppDialog(BuildContext context) {
    String message = '📸 Click, Share, and Party On! Download our app to access all the photos, share them on your favorite apps, and get notified with instant guest list approvals and more! 🎉📲';

    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '🎁 save your photos to gallery',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: Text(message.toLowerCase()),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary), // Set your desired background color
                ),
                child: const Text('🤖 android',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  final uri = Uri.parse(ChallengeUtils.urlBlocPlayStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary), // Set your desired background color
                ),
                child: const Text('🍎 ios',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  Navigator.of(ctx).pop();

                  final uri = Uri.parse(ChallengeUtils.urlBlocAppStore);
                  NetworkUtils.launchInBrowser(uri);
                },
              ),
            ],
          );
        });
  }

  static showReviewAppDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text(
              '🍭 review our app',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, color: Colors.black),
            ),
            backgroundColor: Constants.lightPrimary,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: const EdgeInsets.all(16.0),
            content: Text(
                'Behind bloc, there\'s a small but dedicated team pouring their hearts into it. Will you be our champion by leaving a review? Together, we\'ll build the best community app out there!'.toLowerCase()),
            actions: [
              TextButton(
                child: const Text('close',
                    style: TextStyle(color: Constants.background)),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .lightPrimary),
                ),
                child: const Text('🧸 already reviewed',),
                onPressed: () async {
                  User user = UserPreferences.myUser;
                  user = user.copyWith(
                      isAppReviewed: true,
                      lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                  FirestoreHelper.pushUser(user);

                  Logx.ist(_TAG, '🃏 thank you for already reviewing us');

                  Navigator.of(ctx).pop();
                },
              ),
              TextButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Constants
                      .darkPrimary),
                ),
                child: const Text('🌟 review us',
                    style: TextStyle(color: Constants.primary)),
                onPressed: () async {
                  final InAppReview inAppReview = InAppReview.instance;
                  bool isAvailable = await inAppReview.isAvailable();

                  if(isAvailable){
                    inAppReview.requestReview();
                  } else {
                    inAppReview.openStoreListing(appStoreId: Constants.blocAppStoreId);
                  }

                  User user = UserPreferences.myUser;
                  user = user.copyWith(
                      isAppReviewed: true,
                      lastReviewTime: Timestamp.now().millisecondsSinceEpoch);
                  UserPreferences.setUser(user);
                  FirestoreHelper.pushUser(user);

                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        });
  }

}