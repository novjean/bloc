import 'dart:io';

import 'package:bloc/widgets/ui/app_bar_title.dart';
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
import '../../main.dart';
import '../../utils/constants.dart';
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

  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  String sGender = 'female';
  List<String> genders = [
    'male',
    'female',
    'transgender',
    'non-binary/non-conforming',
    'prefer not to respond'
  ];

  @override
  void initState() {
    sGender = widget.user.gender;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.background,
      appBar: AppBar(
        title: AppBarTitle(title: 'profile',),
        titleSpacing: 0,
        backgroundColor: Colors.black,
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
        ProfileWidget(
          imagePath: imagePath.isEmpty ? widget.user.imageUrl : imagePath,
          isEdit: true,
          onClicked: () async {
            _showBottomSheet(context);
          },
        ),
        const SizedBox(height: 24),
        DarkTextFieldWidget(
          label: 'name *',
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
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'gender *',
                    style: TextStyle(
                        color: Theme.of(context).primaryColorLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  key: const ValueKey('gender_dropdown'),
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      errorStyle: TextStyle(
                          color: Theme.of(context).errorColor,
                          fontSize: 16.0),
                      hintText: 'please select gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        // width: 0.0 produces a thin "hairline" border
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 0.0),
                      )),
                  isEmpty: sGender == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      style: TextStyle(
                          color: Theme.of(context).primaryColorLight),
                      dropdownColor: Constants.background,
                      value: sGender,
                      isDense: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          sGender = newValue!;

                          widget.user =
                              widget.user.copyWith(gender: sGender);
                          state.didChange(newValue);
                        });
                      },
                      items: genders.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ],
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Constants.lightPrimary,
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
            EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture label
              const Text('pick or click 🤳 your best photo 🤩',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500)),

              //for adding some space
              SizedBox(height: mq.height * .02),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {

                        if(!kIsWeb){
                          final ImagePicker picker = ImagePicker();

                          // Pick an image
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery, imageQuality: 95, maxWidth: 300);
                          if (image != null) {
                            Logx.i(_TAG, 'image path: ${image.path}');

                            final directory = await getApplicationDocumentsDirectory();
                            final name = basename(image.path);
                            final imageFile = File('${directory.path}/$name');
                            final newImage = await File(image.path).copy(imageFile.path);

                            oldImageUrl = widget.user.imageUrl;
                            newImageUrl = await FirestorageHelper.uploadFile(
                                FirestorageHelper.USER_IMAGES,
                                StringUtils.getRandomString(28),
                                newImage);

                            widget.user = widget.user.copyWith(imageUrl: newImageUrl);
                            FirestoreHelper.pushUser(widget.user);
                            FirestorageHelper.deleteFile(oldImageUrl);

                            Toaster.shortToast('profile photo updated');

                            setState(() {
                              imagePath = image.path;
                            });

                          }
                        } else {
                          Toaster.shortToast('download our app to upload your photo and more');
                          //todo: need to add dialog to download the app
                        }

                        Navigator.pop(context);

                      },
                      child: Image.asset('assets/images/add_image.png')),

                  //take picture from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        if(!kIsWeb){
                          final ImagePicker picker = ImagePicker();

                          // Pick an image
                          final XFile? image = await picker.pickImage(
                              source: ImageSource.camera, imageQuality: 95, maxWidth: 300);
                          if (image != null) {
                            Logx.i(_TAG, 'image path: ${image.path}');

                            final directory = await getApplicationDocumentsDirectory();
                            final name = basename(image.path);
                            final imageFile = File('${directory.path}/$name');
                            final newImage = await File(image.path).copy(imageFile.path);

                            oldImageUrl = widget.user.imageUrl;
                            newImageUrl = await FirestorageHelper.uploadFile(
                                FirestorageHelper.USER_IMAGES,
                                StringUtils.getRandomString(28),
                                newImage);

                            widget.user = widget.user.copyWith(imageUrl: newImageUrl);
                            FirestoreHelper.pushUser(widget.user);
                            FirestorageHelper.deleteFile(oldImageUrl);

                            Toaster.shortToast('profile photo updated');

                            setState(() {
                              imagePath = image.path;
                            });
                          }
                        }else {
                          Toaster.shortToast('download our app to upload your photo and more');
                        }

                        Navigator.pop(context);

                      },
                      child: Image.asset('assets/images/camera.png')),
                ],
              )
            ],
          );
        });
  }
}
