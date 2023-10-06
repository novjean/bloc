import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/route_constants.dart';
import '../screens/contact_us_screen.dart';
import '../screens/privacy_policy_screen.dart';
import '../screens/refund_policy_screen.dart';
import '../screens/terms_and_conditions_screen.dart';
import '../utils/constants.dart';
import '../utils/network_utils.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      child: Container(
        height: 85,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 40,
                width: 35,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/icons/logo-adaptive.png"),
                      fit: BoxFit.fitHeight),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      final uri =
                          Uri.parse('https://www.instagram.com/bloc.india/');
                      NetworkUtils.launchInBrowser(uri);
                    },
                    child: Text(
                      'instagram',
                      style: TextStyle(
                          fontSize: 14,
                          color: Constants.lightPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      GoRouter.of(context).pushNamed(RouteConstants.contactRouteName);
                    },
                    child: const Text(
                      'contact us',
                      style: TextStyle(
                          fontSize: 14,
                          color: Constants.lightPrimary),
                    ),
                  )
                ],
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyScreen()),
                      );
                    },
                    child: Text(
                      'privacy policy',
                      style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).primaryColorLight),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => RefundPolicyScreen()),
                      );
                    },
                    child: Text(
                      'refund policy',
                      style: TextStyle(
                          fontSize: 14,
                          color: Constants.lightPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      GoRouter.of(context).pushNamed(RouteConstants.termsAndConditionsRouteName);
                    },
                    child: const Text(
                      'terms and conditions',
                      style: TextStyle(
                          fontSize: 14,
                          color: Constants.lightPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
