import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredImage extends StatelessWidget {
  String imageUrl;
  double blurLevel;

  BlurredImage({super.key, required this.imageUrl, required this.blurLevel});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blurLevel, sigmaY: blurLevel), // Adjust sigma values for more blur
      child: FadeInImage(
        placeholder: const AssetImage('assets/images/logo_3x2.png'),
        image: NetworkImage(imageUrl),
      ),
    );
  }
}