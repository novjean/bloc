import 'package:bloc/widgets/ui/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';

import '../routes/app_route_constants.dart';
import '../utils/constants.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("bloc | error"),
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
                style: TextStyle(fontSize: 22, color: Constants.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'click to get back on track!'.toLowerCase(),
                style: TextStyle(fontSize: 16, color: Constants.primary),
              ),
              const SizedBox(height: 16),
              ButtonWidget(
                text:  'home',
                onClicked: () {
                  GoRouter.of(context)
                      .pushNamed(MyAppRouteConstants.landingRouteName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}