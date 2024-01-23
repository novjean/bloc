import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/constants.dart';

class ProfileWidget extends StatelessWidget {
  final String imagePath;
  final bool isEdit;
  final VoidCallback onClicked;
  final bool showEditIcon;

  const ProfileWidget({
    Key? key,
    required this.imagePath,
    this.isEdit = false,
    this.showEditIcon = true,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Stack(
        children: [
          imagePath.isNotEmpty? _loadImage(context) : displayDefaultImage(context),
          showEditIcon? Positioned(
            bottom: 0,
            right: 4,
            child: buildEditIcon(),
          ) : const SizedBox(),
        ],
      ),
    );
  }

  Widget _loadImage(BuildContext context) {
    final image = imagePath.contains('https://')
        ? NetworkImage(imagePath)
        : FileImage(File(imagePath));

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image as ImageProvider,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }

  Widget buildEditIcon() => buildCircle(
    color: Constants.shadowColor,
    all: 3,
    child: buildCircle(
      color: Constants.primary,
      all: 8,
      child: GestureDetector(
        onTap: onClicked,
        child: Icon(
          isEdit ? Icons.add_a_photo : Icons.edit,
          color: Colors.white,
          size: 20,
        ),
      ),
    ),
  );

  Widget buildCircle({
    required Widget child,
    required double all,
    required Color color,
  }) =>
      ClipOval(
        child: Container(
          padding: EdgeInsets.all(all),
          color: color,
          child: child,
        ),
      );

  displayDefaultImage(BuildContext context) {
    final image = AssetImage('assets/images/default_image.png');

    return ClipOval(
      child: Material(
        color: Colors.transparent,
        child: Ink.image(
          image: image as ImageProvider,
          fit: BoxFit.cover,
          width: 128,
          height: 128,
          child: InkWell(onTap: onClicked),
        ),
      ),
    );
  }
}
