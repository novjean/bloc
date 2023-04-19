import 'package:flutter/material.dart';

import '../utils/network_utils.dart';

class StoreBadgeItem extends StatelessWidget {
  const StoreBadgeItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'download the app to receive push notifications, guest list and ticket status updates, and be a part of the ever expanding #blocCommunity',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Theme.of(context).shadowColor),
          ),
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 55,
              width: 110,
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
              height: 60,
              width: 120,
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
