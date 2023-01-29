import 'dart:io';

import 'package:bloc/widgets/ui/toaster.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../db/entity/user.dart' as blocUser;
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/firestore_helper.dart';
import '../../utils/string_utils.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/textfield_widget.dart';
import '../login_screen.dart';

class ProfileAddEditRegisterPage extends StatefulWidget {
  blocUser.User user;
  String task;

  ProfileAddEditRegisterPage({key, required this.user, required this.task})
      : super(key: key);

  @override
  _ProfileAddEditRegisterPageState createState() =>
      _ProfileAddEditRegisterPageState();
}

class _ProfileAddEditRegisterPageState
    extends State<ProfileAddEditRegisterPage> {
  bool isPhotoChanged = false;

  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('profile | ' + widget.task),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (widget.task == 'register') {
                UserPreferences.resetUser();

                try {
                  FirebaseAuth.instance.signOut();
                } catch (err) {
                  print('err:' + err.toString());
                }
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
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
          imagePath: imagePath.isEmpty ? widget.user.imageUrl : imagePath,
          isEdit: true,
          onClicked: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery, imageQuality: 90, maxWidth: 300);
            if (image == null) return;

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            oldImageUrl = widget.user.imageUrl;
            newImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.USER_IMAGES,
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
          text: widget.user.name,
          onChanged: (name) => widget.user = widget.user.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'email',
          text: widget.user.email,
          onChanged: (email) => widget.user = widget.user.copyWith(email: email),
        ),
        const SizedBox(height: 24),
        // TextFieldWidget(
        //   label: 'about',
        //   text: '',
        //   maxLines: 5,
        //   onChanged: (about) {},
        // ),
        // const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            // we should have some validation here
            if (isDataValid()) {
              if (isPhotoChanged) {
                widget.user = widget.user.copyWith(imageUrl: newImageUrl);
                if (oldImageUrl.isNotEmpty) {
                  FirestorageHelper.deleteFile(oldImageUrl);
                }
              }

              UserPreferences.setUser(widget.user);
              FirestoreHelper.pushUser(widget.user);
              Navigator.of(context).pop();
            } else {
              print('user cannot be entered as data is incomplete');
            }
          },
        ),
      ],
    );
  }

  bool isDataValid() {
    if (widget.user.name.isEmpty) {
      Toaster.longToast('please enter your name');
      return false;
    }
    if (widget.user.email.isEmpty) {
      Toaster.longToast('please enter your email id');
      return false;
    }

    return true;
  }
}