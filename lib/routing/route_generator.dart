import 'package:bloc/routing/login_arguments.dart';
import 'package:bloc/screens/login_screen.dart';
import 'package:flutter/material.dart';

import 'app_routes.dart';

/// route_generator.dart
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case AppRoutes.login:
      //   return buildRoute(const LoginScreen(shouldTriggerSkip: false,), settings: settings);
      // case AppRoutes.register:
      //   return buildRoute(const Register(), settings: settings);
      // case AppRoutes.profile:
      //   final arguments = settings.arguments as ProfileArguments;
      //   return buildRoute(const LoginScreen(arguments: arguments), settings: settings);
      case AppRoutes.login:
        final arguments = settings.arguments as LoginArguments;
        return buildRoute(LoginScreen(arguments: arguments), settings: settings);
      // case AppRoutes.settings:
      //   return buildRoute(const Settings(), settings: settings);
      default:
        return _errorRoute();
    }
  }

  static MaterialPageRoute buildRoute(Widget child,
      {required RouteSettings settings}) {
    return MaterialPageRoute(
        settings: settings, builder: (BuildContext context) => child);
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text(
            'ERROR!!',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 450.0,
                  width: 450.0,
                  child: Text('error'),
                ),
                const Text(
                  'Seems the route you\'ve navigated to doesn\'t exist!!',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}