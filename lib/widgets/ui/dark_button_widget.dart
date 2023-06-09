import 'package:flutter/material.dart';

class DarkButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  late final double? height;

  DarkButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height ?? 40,
    child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColorDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(text),
          onPressed: onClicked,
        ),
  );
}
