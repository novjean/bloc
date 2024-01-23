import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const SquareIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0), // Set the rounded edge radius
        child: Container(
          width: 56.0,
          height: 56.0,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10)),
            color: Constants.background,
          ),
          child: Center(
            child: Icon(
              icon,
              color: Constants.primary, // Set the icon color
            ),
          ),
        ),
      ),
    );
  }
}