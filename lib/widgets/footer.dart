import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../utils/network_utils.dart';

class Footer extends StatelessWidget {
  bool? showAll;

  Footer({super.key, this.showAll});

  @override
  Widget build(BuildContext context) {
    bool show = showAll ?? true;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      child: Container(
        height: show ? 130 : 50,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10, top: 5),
          child: Column(
              children: [
            show ? Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 3.0, top: 15),
                    child: Container(
                      height: 60,
                      width: 40,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage("assets/icons/logo-adaptive.png"),
                            fit: BoxFit.fitHeight),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          final uri = Uri.parse(Constants.blocInstaHandle);
                          NetworkUtils.launchInBrowser(uri);
                        },
                        child: const Text(
                          'instagram',
                          style: TextStyle(
                              fontSize: 14, color: Constants.lightPrimary),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.contactRouteName);
                        },
                        child: const Text(
                          'contact us',
                          style: TextStyle(
                              fontSize: 14, color: Constants.lightPrimary),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.privacyRouteName);
                        },
                        child: const Text(
                          'privacy policy',
                          style: TextStyle(
                              fontSize: 14, color: Constants.lightPrimary),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          GoRouter.of(context)
                              .pushNamed(RouteConstants.refundRouteName);
                        },
                        child: const Text(
                          'refund policy',
                          style: TextStyle(
                              fontSize: 14, color: Constants.lightPrimary),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          GoRouter.of(context).pushNamed(
                              RouteConstants.termsAndConditionsRouteName);
                        },
                        child: const Text(
                          'terms and conditions',
                          style: TextStyle(
                              fontSize: 14, color: Constants.lightPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ) : const SizedBox(),
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 5, left: 10, right: 10),
              child: Text(
                'Copyright Novatech Corp 2024. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Constants.primary, fontSize: 13),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
