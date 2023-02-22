import 'package:bloc/widgets/ui/toaster.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreBadgeItem extends StatelessWidget {
  int addCount = 1;

  StoreBadgeItem();

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Flexible(
            child: Container(
                child: Center(
                  child: Text(
              'download app from',
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
                        _launchInBrowser(uri);
                      },
                      child: Container(
                        decoration: BoxDecoration(
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
                      Toaster.shortToast('pending approval');
                    },
                    child: Container(
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
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
