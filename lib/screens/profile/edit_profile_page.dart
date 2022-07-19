import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../db/bloc_repository.dart';
import '../../db/dao/bloc_dao.dart';
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/firestore_helper.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  User user;
  BlocDao dao;

  EditProfilePage({key, required this.user, required this.dao}):super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late User user;
  bool isPhotoChanged = false;
  late String oldImageUrl;

  @override
  void initState() {
    super.initState();

    user = UserPreferences.getUser();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('BLOC | Edit Profile'),),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 32),
      physics: BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: user.imageUrl,
          isEdit: true,
          onClicked: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                imageQuality: 90, maxWidth: 300);
            if (image == null) return;

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            setState(() {
              oldImageUrl = user.imageUrl;
              user = user.copyWith(imageUrl: newImage.path);
              isPhotoChanged = true;
            });
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Full Name',
          text: user.name,
          onChanged: (name) => user = user.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'Email',
          text: user.email,
          onChanged: (email) => user = user.copyWith(email: email),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'About',
          text: 'this is a test about, need to edit all this.',
          maxLines: 5,
          onChanged: (about) {},
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'Save',
          onClicked: () {
            UserPreferences.setUser(user);

            if(isPhotoChanged){
              FirestorageHelper.deleteFile(oldImageUrl);
            }

            BlocRepository.updateUser(widget.dao, user);
            FirestoreHelper.updateUser(user);

            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

