import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../db/entity/bloc.dart';
import '../../utils/string_utils.dart';

class BlocAddEditScreen extends StatefulWidget {
  Bloc bloc;
  String task;

  BlocAddEditScreen({key, required this.bloc, required this.task})
      : super(key: key);

  @override
  _BlocAddEditScreenState createState() => _BlocAddEditScreenState();
}

class _BlocAddEditScreenState extends State<BlocAddEditScreen> {
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('bloc | ' + widget.task),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: imagePath.isEmpty ? widget.bloc.imageUrl : imagePath,
          isEdit: true,
          onClicked: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 90,
                maxWidth: 500);
            if (image == null) return;

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            oldImageUrl = widget.bloc.imageUrl;
            newImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.BLOCS_IMAGES,
                StringUtils.getRandomString(28),
                newImage);

            setState(() {
              imagePath = imageFile.path;
              isPhotoChanged = true;
            });
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'name',
          text: widget.bloc.name,
          onChanged: (name) =>
          widget.bloc = widget.bloc.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'address line 1',
          text: widget.bloc.addressLine1,
          onChanged: (value) {
            widget.bloc = widget.bloc.copyWith(addressLine1: value);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'address line 2',
          text: widget.bloc.addressLine2,
          onChanged: (value) {
            widget.bloc = widget.bloc.copyWith(addressLine2: value);
          },
        ),
        TextFieldWidget(
          label: 'pin code',
          text: widget.bloc.pinCode,
          onChanged: (value) {
            widget.bloc = widget.bloc.copyWith(pinCode: value);
          },
        ),

        Row(
          children: <Widget>[
            SizedBox(
              width: 0,
            ), //SizedBox
            Text(
              'active : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.bloc.isActive,
              onChanged: (value) {
                setState(() {
                  widget.bloc =
                      widget.bloc.copyWith(isActive: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            if (isPhotoChanged) {
              widget.bloc =
                  widget.bloc.copyWith(imageUrl: newImageUrl);
              FirestorageHelper.deleteFile(oldImageUrl);
            }

            FirestoreHelper.pushBloc(widget.bloc);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
