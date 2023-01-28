import 'dart:io';

import 'package:bloc/utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../db/entity/bloc_service.dart';

class BlocServiceAddEditScreen extends StatefulWidget {
  BlocService blocService;
  String task;

  BlocServiceAddEditScreen({key, required this.blocService, required this.task})
      : super(key: key);

  @override
  _BlocServiceAddEditScreenState createState() => _BlocServiceAddEditScreenState();
}

class _BlocServiceAddEditScreenState extends State<BlocServiceAddEditScreen> {
  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath ='';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('bloc service | ' + widget.task),
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
          imagePath: imagePath.isEmpty? widget.blocService.imageUrl:imagePath,
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

            oldImageUrl = widget.blocService.imageUrl;
            newImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.BLOCS_SERVICES_IMAGES,
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
          text: widget.blocService.name,
          onChanged: (name) =>
          widget.blocService = widget.blocService.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'type',
          text: widget.blocService.type,
          onChanged: (value) {
            widget.blocService = widget.blocService.copyWith(type: value);
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('bloc_service_primary_phone'),
          initialValue: widget.blocService.primaryPhone.toString(),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid phone number';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'primary phone',
          ),
          onChanged: (value) {
            double? number = double.tryParse(value);
            widget.blocService = widget.blocService.copyWith(primaryPhone: number);
          },
        ),
        const SizedBox(height: 24),
        TextFormField(
          key: const ValueKey('bloc_service_secondary_phone'),
          initialValue: widget.blocService.secondaryPhone.toString(),
          autocorrect: false,
          textCapitalization: TextCapitalization.none,
          enableSuggestions: false,
          validator: (value) {
            if (value!.isEmpty) {
              return 'please enter a valid phone number';
            }
            return null;
          },
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'secondary phone',
          ),
          onChanged: (value) {
            double? number = double.tryParse(value);
            widget.blocService = widget.blocService.copyWith(secondaryPhone: number);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'email address',
          text: widget.blocService.emailId,
          onChanged: (value) {
            widget.blocService = widget.blocService.copyWith(emailId: value);
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            if (isPhotoChanged) {
              widget.blocService =
                  widget.blocService.copyWith(imageUrl: newImageUrl);
              FirestorageHelper.deleteFile(oldImageUrl);
            }

            FirestoreHelper.pushBlocService(widget.blocService);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
