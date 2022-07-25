import 'package:flutter/material.dart';

class CenterTextWidget extends StatelessWidget {
  final String text;

  CenterTextWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(text),
          ),
        ),
      ],
    );
  }
}
