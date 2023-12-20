import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../db/shared_preferences/user_preferences.dart';
import '../../routes/route_constants.dart';

class AppBarTitle extends StatelessWidget {
  String title;

  AppBarTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        Container(
          height: 40,
          width: 35,
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
            child: const Text('bloc.')),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(right: 20.0, left: 10),
          child: Text(title.toLowerCase(), overflow: TextOverflow.ellipsis,),
        )
      ],),
    );
  }

}