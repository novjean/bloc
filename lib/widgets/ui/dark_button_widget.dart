import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class DarkButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  late final double? height;
  late final double? fontSize;

  DarkButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
    this.height, this.fontSize
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height ?? 40,
    child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Constants.darkPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
      child: Text(text, style: TextStyle(fontSize: fontSize?? 18),),
          onPressed: onClicked,
        ),
  );
}
