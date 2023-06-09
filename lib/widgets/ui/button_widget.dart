import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  late final double? height;

  ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
    this.height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height ?? 40,
    child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          ),
          child: Text(text),
          onPressed: onClicked,
        ),
  );
}
