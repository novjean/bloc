import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../db/entity/bloc.dart';
import '../../main.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/app_bar_title.dart';

class BlocAddEditScreen extends StatefulWidget {
  Bloc bloc;
  String task;

  BlocAddEditScreen({key, required this.bloc, required this.task})
      : super(key: key);

  @override
  _BlocAddEditScreenState createState() => _BlocAddEditScreenState();
}

class _BlocAddEditScreenState extends State<BlocAddEditScreen> {
  static const String _TAG = 'BlocAddEditScreen';

  bool isPhotoChanged = false;

  String imagePath = '';
  String oldImageUrl = '';
  String newImageUrl = '';

  List<String> mImageUrls = [];
  List<String> oldImageUrls = [];

  String mapImagePath ='';

  @override
  void initState() {
    super.initState();

    mImageUrls.addAll(widget.bloc.imageUrls);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: AppBarTitle(title: '${widget.task} bloc'),
          titleSpacing: 0,
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
            Text('${mImageUrls.length} photos: '),
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

                mImageUrls.add(newImageUrl);

                setState(() {
                  widget.bloc = widget.bloc.copyWith(imageUrls: mImageUrls);
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: SizedBox.fromSize(
                size: const Size(56, 56),
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
                                title: const Text('photos'),
                                content: _photosListDialog(),
                              );
                            });
                      },
                      child: const Column(
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
          label: 'order priority',
          text: widget.bloc.orderPriority.toString(),
          onChanged: (text) {
            int value = int.parse(text);
            widget.bloc = widget.bloc.copyWith(orderPriority: value);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'creation date',
          text: widget.bloc.creationDate.toString(),
          onChanged: (text) {
            int value = int.parse(text);
            widget.bloc = widget.bloc.copyWith(creationDate: value);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'creation old',
          text: widget.bloc.createdAt,
          onChanged: (text) {
            widget.bloc = widget.bloc.copyWith(createdAt: text);
          },
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
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'pin code',
          text: widget.bloc.pinCode,
          onChanged: (value) {
            widget.bloc = widget.bloc.copyWith(pinCode: value);
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: ProfileWidget(
            imagePath: mapImagePath.isEmpty? widget.bloc.mapImageUrl:mapImagePath,
            isEdit: true,
            onClicked: () async {
              final image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 99,
                  maxWidth: 1024);
              if (image == null) return;

              final directory = await getApplicationDocumentsDirectory();
              final name = basename(image.path);
              final imageFile = File('${directory.path}/$name');
              final newImage = await File(image.path).copy(imageFile.path);

              String oldMapImage = widget.bloc.mapImageUrl;

              if(oldMapImage.isNotEmpty){
                FirestorageHelper.deleteFile(oldMapImage);
              }

              String newMapImage = await FirestorageHelper.uploadFile(
                  FirestorageHelper.BLOCS_MAP_IMAGES,
                  StringUtils.getRandomString(28),
                  newImage);
              widget.bloc =
                  widget.bloc.copyWith(mapImageUrl: newMapImage);

              setState(() {
                mapImagePath = imageFile.path;
              });
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextFieldWidget(
            label: 'latitude',
            text: widget.bloc.latitude.toString(),
            onChanged: (text) {
              double value = double.parse(text);
              widget.bloc = widget.bloc.copyWith(latitude: value);
            },
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: TextFieldWidget(
            label: 'longitude',
            text: widget.bloc.longitude.toString(),
            onChanged: (text) {
              double value = double.parse(text);
              widget.bloc = widget.bloc.copyWith(longitude: value);
            },
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            const Text(
              'active : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
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
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            const Text(
              'power bloc : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.bloc.powerBloc,
              onChanged: (value) {
                setState(() {
                  widget.bloc = widget.bloc.copyWith(powerBloc: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            const Text(
              'super power bloc : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.bloc.superPowerBloc,
              onChanged: (value) {
                setState(() {
                  widget.bloc = widget.bloc.copyWith(superPowerBloc: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: '💾 save',
          onClicked: () {
            FirestoreHelper.pushBloc(widget.bloc);
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 36),
      ],
    );
  }

  Widget _photosListDialog() {
    return SingleChildScrollView(
      child: SizedBox(
        height: mq.height * 0.6,
        width: mq.width * 0.8,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: mImageUrls.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(mImageUrls[index],
                        width: 80, height: 80, fit: BoxFit.cover),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(50, 50),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orangeAccent,
                      child: InkWell(
                        splashColor: Colors.orange,
                        onTap: () {
                          int prevIndex = index--;
                          if (prevIndex >= 0) {
                            mImageUrls.swap(index, prevIndex);
                            widget.bloc =
                                widget.bloc.copyWith(imageUrls: mImageUrls);
                            FirestoreHelper.pushBloc(widget.bloc);
                          } else {
                            Logx.ist(_TAG, 'photo is already the first');
                          }

                          setState(() {});
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.arrow_circle_up_outlined),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(50, 50),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orangeAccent,
                      child: InkWell(
                        splashColor: Colors.orange,
                        onTap: () {
                          int nextIndex = index++;
                          if (nextIndex <= mImageUrls.length - 1) {
                            mImageUrls.swap(index, nextIndex);
                            widget.bloc =
                                widget.bloc.copyWith(imageUrls: mImageUrls);
                            FirestoreHelper.pushBloc(widget.bloc);
                          } else {
                            Logx.ist(_TAG, 'photo is already the last');
                          }

                          widget.bloc =
                              widget.bloc.copyWith(imageUrls: mImageUrls);
                          FirestoreHelper.pushBloc(widget.bloc);

                          setState(() {});
                        },
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.arrow_circle_down_outlined),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox.fromSize(
                  size: const Size(50, 50),
                  child: ClipOval(
                    child: Material(
                      color: Colors.redAccent,
                      child: InkWell(
                        splashColor: Colors.red,
                        onTap: () {
                          FirestorageHelper.deleteFile(mImageUrls[index]);
                          mImageUrls.removeAt(index);

                          widget.bloc =
                              widget.bloc.copyWith(imageUrls: mImageUrls);
                          FirestoreHelper.pushBloc(widget.bloc);

                          setState(() {});
                          Navigator.of(context).pop();
                        },
                        child: const Column(
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
