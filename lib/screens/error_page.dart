import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routes/route_constants.dart';
import '../utils/constants.dart';
import '../widgets/ui/app_bar_title.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: AppBarTitle(title: "error"),
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
          onPressed: () {
            GoRouter.of(context).pushReplacementNamed(RouteConstants.landingRouteName);
          },
        ),
      ),
      backgroundColor: Constants.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Uh-oh! It appears that the URL you entered is dancing to its own beat and doesn\'t want to be found. 💀'.toLowerCase(),
                style: const TextStyle(fontSize: 22, color: Constants.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'click to get back on track!'.toLowerCase(),
                style: const TextStyle(fontSize: 16, color: Constants.primary),
              ),
              const SizedBox(height: 16),
              ButtonWidget(
                text:  'home',
                onClicked: () {
                  GoRouter.of(context)
                      .pushReplacementNamed(RouteConstants.landingRouteName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}