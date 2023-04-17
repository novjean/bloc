import 'package:flutter/material.dart';

import '../screens/terms_and_conditions_screen.dart';
import '../utils/network_utils.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: MediaQuery.of(context).size.width,
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {

                  },
                  child: Text(
                    'instagram',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).primaryColorLight),
                  ),
                ),
                // InkWell(
                //   onTap: () {
                //
                //   },
                //   child: Text(
                //     'whatsapp',
                //     style: TextStyle(
                //         fontSize: 14, color: Theme.of(context).primaryColorLight),
                //   ),
                // ),
                InkWell(
                  onTap: () {

                  },
                  child: Text(
                    'contact us',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).primaryColorLight),
                  ),
                )
              ],
            ),
            const Divider(),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    final uri = Uri.parse('https://bloc.bar/privacy.html');
                    NetworkUtils.launchInBrowser(uri);
                  },
                  child: Text(
                    'privacy policy',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).primaryColorLight),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TermsAndConditionsScreen()),
                    );
                  },
                  child: Text(
                    'terms and conditions',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).primaryColorLight),
                  ),
                ),
                InkWell(
                  onTap: () {

                  },
                  child: Text(
                    'refund and cancellation policy',
                    style: TextStyle(
                        fontSize: 14, color: Theme.of(context).primaryColorLight),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
