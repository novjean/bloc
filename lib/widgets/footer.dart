import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../utils/network_utils.dart';

class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
      child: Container(
        height: 130,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
          child: Column(
            children:[
              Expanded(
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
                          GoRouter.of(context).pushNamed(RouteConstants.privacyRouteName);
                        },
                        child: const Text(
                          'privacy policy',
                          style: TextStyle(
                              fontSize: 14,
                              color: Constants.lightPrimary),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          GoRouter.of(context).pushNamed(RouteConstants.refundRouteName);
                        },
                        child: const Text(
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
              Padding(
                padding: const EdgeInsets.only(top:15.0, bottom: 5, left: 10, right: 10),
                child: Text('Copyright Novatech Corp (India) Pvt Ltd 2023. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Constants.primary, fontSize: 12),),
              )
          ]
          ),
        ),
      ),
    );
  }
}
