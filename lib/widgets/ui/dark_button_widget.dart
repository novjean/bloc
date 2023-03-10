import 'package:flutter/material.dart';

class DarkButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const DarkButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColorDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        ),
        child: Text(text),
        onPressed: onClicked,
      );
}
