import 'package:bloc/main.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      body: const LoadingWidget()
    );
  }
}