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
  bool isPhoto2Changed = false;
  bool isPhoto3Changed = false;

  String imagePath = '';
  String imagePath2 = '';
  String imagePath3 = '';

  String oldImageUrl = '';
  String oldImageUrl2 = '';
  String oldImageUrl3 = '';

  String newImageUrl = '';
  String newImageUrl2 = '';
  String newImageUrl3 = '';

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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),

        SizedBox(
          height: 150,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ProfileWidget(
                  imagePath: imagePath.isEmpty? widget.bloc.imageUrl:imagePath,
                  isEdit: true,
                  onClicked: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 95,
                        maxWidth: 768);
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
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ProfileWidget(
                  imagePath: imagePath2.isEmpty? widget.bloc.imageUrl2:imagePath2,
                  isEdit: true,
                  onClicked: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 95,
                        maxWidth: 768);
                    if (image == null) return;

                    final directory = await getApplicationDocumentsDirectory();
                    final name = basename(image.path);
                    final imageFile = File('${directory.path}/$name');
                    final newImage = await File(image.path).copy(imageFile.path);

                    oldImageUrl2 = widget.bloc.imageUrl2;
                    newImageUrl2 = await FirestorageHelper.uploadFile(
                        FirestorageHelper.BLOCS_IMAGES,
                        StringUtils.getRandomString(28),
                        newImage);

                    setState(() {
                      imagePath2 = imageFile.path;
                      isPhoto2Changed = true;
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: ProfileWidget(
                  imagePath: imagePath3.isEmpty? widget.bloc.imageUrl3:imagePath3,
                  isEdit: true,
                  onClicked: () async {
                    final image = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 95,
                        maxWidth: 768);
                    if (image == null) return;

                    final directory = await getApplicationDocumentsDirectory();
                    final name = basename(image.path);
                    final imageFile = File('${directory.path}/$name');
                    final newImage = await File(image.path).copy(imageFile.path);

                    oldImageUrl3 = widget.bloc.imageUrl;
                    newImageUrl3 = await FirestorageHelper.uploadFile(
                        FirestorageHelper.BLOCS_IMAGES,
                        StringUtils.getRandomString(28),
                        newImage);

                    setState(() {
                      imagePath3 = imageFile.path;
                      isPhoto3Changed = true;
                    });
                  },
                ),
              ),
            ],),
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
              if(oldImageUrl.isNotEmpty) {
                FirestorageHelper.deleteFile(oldImageUrl);
              }
            }
            if (isPhoto2Changed) {
              widget.bloc =
                  widget.bloc.copyWith(imageUrl2: newImageUrl2);
              if(oldImageUrl2.isNotEmpty) {
                FirestorageHelper.deleteFile(oldImageUrl2);
              }
            }
            if (isPhoto3Changed) {
              widget.bloc =
                  widget.bloc.copyWith(imageUrl3: newImageUrl3);
              if(oldImageUrl3.isNotEmpty) {
                FirestorageHelper.deleteFile(oldImageUrl3);
              }
            }

            FirestoreHelper.pushBloc(widget.bloc);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
