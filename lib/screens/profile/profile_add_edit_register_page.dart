import 'dart:io';

import 'package:bloc/widgets/ui/toaster.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../db/entity/user.dart' as blocUser;
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../utils/logx.dart';
import '../../utils/string_utils.dart';
import '../../widgets/profile_widget.dart';
import '../../widgets/ui/button_widget.dart';
import '../../widgets/ui/dark_textfield_widget.dart';

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
  static const String _TAG = 'ProfileAddEditRegisterPage';

  bool isPhotoChanged = false;

  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('profile | ${widget.task}'),
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.task == 'register') {
              Logx.i(_TAG,'register back press not allowed');
              Toaster.longToast('click save to move ahead');
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
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
        DarkTextFieldWidget(
          label: 'name \*',
          text: widget.user.name,
          onChanged: (name) => widget.user = widget.user.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        DarkTextFieldWidget(
          label: 'surname',
          text: widget.user.surname,
          onChanged: (text) => widget.user = widget.user.copyWith(surname: text),
        ),
        const SizedBox(height: 24),
        DarkTextFieldWidget(
          label: 'email',
          text: widget.user.email,
          onChanged: (email) =>
              widget.user = widget.user.copyWith(email: email),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10, bottom: 5),
              child: DelayedDisplay(
                delay: const Duration(seconds: 1),
                child: Text(
                  "* required",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ),
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

              User freshUser = Fresh.freshUser(widget.user);

              UserPreferences.setUser(freshUser);
              FirestoreHelper.pushUser(freshUser);
              Navigator.of(context).pop();
            } else {
              Logx.i(_TAG,'user cannot be entered as data is incomplete');
              Toaster.longToast('please enter your name');
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

    return true;
  }
}
