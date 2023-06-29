import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class IconButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;
  late final double? height;
  late final double? fontSize;
  final IconData? icon;

  IconButtonWidget({
    Key? key,
    required this.icon,
    required this.text,
    required this.onClicked,
    this.height, this.fontSize
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    height: height ?? 40,
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColorDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10),
              topRight: Radius.circular(10)),
        ),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      label: Text(text, style: TextStyle(fontSize: fontSize?? 16, color: Constants.primary),
      ),
      onPressed: onClicked,
        icon: Icon(
          icon,
          size: 24.0,
          color: Constants.primary,
        )
    ),
  );
}
