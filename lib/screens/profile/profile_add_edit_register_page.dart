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
  late blocUser.User user;
  bool isPhotoChanged = false;
  late String oldImageUrl;

  @override
  void initState() {
    super.initState();

    user = UserPreferences.getUser();
  }

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
          imagePath: user.imageUrl,
          isEdit: true,
          onClicked: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery, imageQuality: 90, maxWidth: 300);
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
          label: 'name',
          text: user.name,
          onChanged: (name) => user = user.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'email',
          text: user.email,
          onChanged: (email) => user = user.copyWith(email: email),
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
              UserPreferences.setUser(user);

              if (isPhotoChanged) {
                if (oldImageUrl.isNotEmpty) {
                  FirestorageHelper.deleteFile(oldImageUrl);
                }
              }

              FirestoreHelper.updateUser(user, isPhotoChanged);

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
    if (user.name.isEmpty) {
      Toaster.longToast('please enter your name');
      return false;
    }
    if (user.email.isEmpty) {
      Toaster.longToast('please enter your email id');
      return false;
    }

    return true;
  }
}
