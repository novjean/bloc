import 'dart:async';

import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class CountdownTimer extends StatefulWidget {
  @override
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  int _secondsRemaining = 60;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Start the countdown timer when the widget is initialized
    startTimer();
  }

  void startTimer() {
    // Update the countdown every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          // Timer reached 0, perform any action you need here
          _timer.cancel(); // Cancel the timer when it reaches 0
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      'please wait $_secondsRemaining seconds',
      style: const TextStyle(fontSize: 16, color: Constants.lightPrimary),
    );
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to avoid memory leaks
    _timer.cancel();
    super.dispose();
  }
}