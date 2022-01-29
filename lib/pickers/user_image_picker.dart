import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  int imageQuality;
  double maxWidth;
  UserImagePicker(this.imagePickFn,this.imageQuality,this.maxWidth);

  final void Function(File pickedImage) imagePickFn;

  @override
  _UserImagePickerState createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  late File _pickedImage;
  bool photoCaptured = false;

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedImageFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: widget.imageQuality,
      maxWidth: widget.maxWidth,
    );
    setState(() {
      photoCaptured=true;
      _pickedImage = File(pickedImageFile!.path);
    });
    widget.imagePickFn(File(pickedImageFile!.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        photoCaptured?
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: FileImage(_pickedImage),
        ):CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
        ),
        FlatButton.icon(
          textColor: Theme.of(context).primaryColor,
          onPressed: _pickImage,
          icon: Icon(Icons.image),
          label: Text('Add Image'),
        ),
      ],
    );
  }
}
