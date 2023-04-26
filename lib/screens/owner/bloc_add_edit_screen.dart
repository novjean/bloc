import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
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

  String imagePath = '';
  String oldImageUrl = '';
  String newImageUrl = '';

  List<String> imageUrls = [];
  List<String> oldImageUrls = [];

  @override
  void initState() {
    super.initState();

    imageUrls.addAll(widget.bloc.imageUrls);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('bloc | ${widget.task}'),
        ),
        body: _buildBody(context),
      );

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(imageUrls.length.toString() + ' photos : '),
            const Spacer(),
            ButtonWidget(
              text: 'pick file',
              onClicked: () async {
                final image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 95,
                    maxHeight: 768,
                    maxWidth: 1024);
                if (image == null) return;

                final directory = await getApplicationDocumentsDirectory();
                final name = basename(image.path);
                final imageFile = File('${directory.path}/$name');
                final newImage = await File(image.path).copy(imageFile.path);

                newImageUrl = await FirestorageHelper.uploadFile(
                    FirestorageHelper.BLOCS_IMAGES,
                    StringUtils.getRandomString(28),
                    newImage);

                imageUrls.add(newImageUrl);

                setState(() {
                  widget.bloc = widget.bloc.copyWith(imageUrls: imageUrls);
                  // isPhotoChanged = true;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SizedBox.fromSize(
                size: Size(56, 56),
                child: ClipOval(
                  child: Material(
                    color: Colors.redAccent,
                    child: InkWell(
                      splashColor: Colors.red,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('photos'),
                                content: photosListDialog(),
                              );
                            });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.delete_forever),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'name',
          text: widget.bloc.name,
          onChanged: (name) => widget.bloc = widget.bloc.copyWith(name: name),
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
            const Text(
              'active : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.bloc.isActive,
              onChanged: (value) {
                setState(() {
                  widget.bloc = widget.bloc.copyWith(isActive: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            FirestoreHelper.pushBloc(widget.bloc);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget photosListDialog() {
    return SingleChildScrollView(
      child: SizedBox(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: imageUrls.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                  child:
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                        imageUrls[index],
                        width: 110,
                        height: 70,
                        fit:BoxFit.fill

                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: Size(56, 56),
                  child: ClipOval(
                    child: Material(
                      color: Colors.redAccent,
                      child: InkWell(
                        splashColor: Colors.red,
                        onTap: () {
                          FirestorageHelper.deleteFile(imageUrls[index]);
                          imageUrls.removeAt(index);
                          Navigator.of(context).pop();
                          setState(() {

                          });
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.delete_forever),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
