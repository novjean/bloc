import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../utils/network_utils.dart';

class StoreBadgeItem extends StatelessWidget {
  const StoreBadgeItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 25, left: 15.0, right: 15),
          child: Text(
            'download the app to register for limited guest list, photo saving to gallery, push notifications for updates, and be a part of the ever expanding #blocCommunity',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Constants.shadowColor),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80,
              width: 165,
              child: GestureDetector(
                onTap: () {
                  final uri = Uri.parse(
                      'https://apps.apple.com/in/app/bloc-community/id1672736309');
                  NetworkUtils.launchInBrowser(uri);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                      AssetImage('assets/images/app-store-badge.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 90,
              width: 180,
              child: GestureDetector(
                onTap: () {
                  final uri = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.novatech.bloc');
                  NetworkUtils.launchInBrowser(uri);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image:
                      AssetImage('assets/images/google-play-badge.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
