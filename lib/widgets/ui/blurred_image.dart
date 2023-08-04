import 'dart:ui';

import 'package:flutter/material.dart';

class BlurredImage extends StatelessWidget {
  String imageUrl;

  BlurredImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust sigma values for more blur
      child: FadeInImage(
        placeholder: const AssetImage('assets/icons/logo.png'),
        image: NetworkImage(imageUrl),
      ),
    );
  }
}