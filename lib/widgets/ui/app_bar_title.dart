import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/shared_preferences/user_preferences.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';

class AppBarTitle extends StatelessWidget {
  String title;

  AppBarTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        height: 50,
        width: 40,
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/icons/logo-adaptive.png"),
              fit: BoxFit.fitHeight),
        ),
      ),
      InkWell(
          onTap: () {
            GoRouter.of(context)
                .pushNamed(RouteConstants.landingRouteName);
          },
          child: const Text('bloc.', style: TextStyle(color: Constants.lightPrimary),)),
      const Spacer(),
      Padding(
        padding: const EdgeInsets.only(right: 20.0, left: 10),
        child: Text(title.toLowerCase(), overflow: TextOverflow.ellipsis, style: TextStyle(color: Constants.lightPrimary),),
      )
    ],);
  }

}