import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class UpiAppWidget extends StatelessWidget {
  final String imageAsset;
  final String name;

  UpiAppWidget({required this.imageAsset, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, // Adjust the size according to your needs
      height: 45,
      margin: EdgeInsets.symmetric(horizontal: 1),
      padding: EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Constants.darkPrimary, // Set your desired background color
        borderRadius: BorderRadius.circular(9.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            width: 36, // Set the image width
            height: 36, // Set the image height
            // color: Colors.white, // Set the image color
          ),
          SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              color: Colors.white, // Set the text color
            ),
          ),
        ],
      ),
    );
  }
}