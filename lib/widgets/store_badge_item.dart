import 'package:flutter/material.dart';

import '../utils/network_utils.dart';

class StoreBadgeItem extends StatelessWidget {
  const StoreBadgeItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Flexible(
            child: Container(
                child: Center(
                  child: Text(
              'experience our app',
              style: TextStyle(
                    fontSize: 16, color: Theme.of(context).shadowColor),
            ),
                )),
            flex: 1,
          ),
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final uri = Uri.parse('https://play.google.com/store/apps/details?id=com.novatech.bloc');
                        NetworkUtils.launchInBrowser(uri);
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/google-play-badge.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      final uri = Uri.parse('https://apps.apple.com/in/app/bloc-community/id1672736309');
                      NetworkUtils.launchInBrowser(uri);
                    },
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/app-store-badge.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            flex: 3,
          ),
        ],
      ),
    );
  }
}
