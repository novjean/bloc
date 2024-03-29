import 'dart:io';

import 'package:bloc/db/entity/user_lounge.dart';
import 'package:bloc/helpers/bloc_helper.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/toaster.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../db/entity/user.dart' as blocUser;
import '../../db/entity/user.dart';
import '../../db/shared_preferences/user_preferences.dart';
import '../../helpers/dummy.dart';
import '../../helpers/firestorage_helper.dart';
import '../../helpers/firestore_helper.dart';
import '../../helpers/fresh.dart';
import '../../main.dart';
import '../../routes/route_constants.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/logx.dart';
import '../../utils/number_utils.dart';
import '../../utils/string_utils.dart';
import '../../widgets/footer.dart';
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

  String sGender = 'male';
  List<String> genders = [
    'male',
    'female',
    'transgender',
    'non-binary/non-conforming',
    'prefer not to respond'
  ];

  final List<String> years = [];
  late String _sYear;

  var _isUsernameChanged = false;

  @override
  void initState() {
    sGender = widget.user.gender;

    _sYear = widget.user.birthYear.toString();
    for(int i = widget.user.birthYear; i > widget.user.birthYear-100; i--){
      years.add(i.toString());
    }

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
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Constants.lightPrimary),
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
          label: 'surname *',
          text: widget.user.surname,
          onChanged: (text) => widget.user = widget.user.copyWith(surname: text),
        ),
        widget.task == 'register' ? const SizedBox() : const SizedBox(height: 24),
        widget.task == 'register' ? const SizedBox() : DarkTextFieldWidget(
          label: 'username',
          text: widget.user.username,
          onChanged: (text) {
            Logx.ist(_TAG, 'changing username is not yet supported.');
            // widget.user = widget.user.copyWith(username: text);
            // _isUsernameChanged = true;
            },
        ),
        const SizedBox(height: 24),
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'year of birth',
                    style: TextStyle(
                        color: Constants.lightPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            FormField<String>(
              builder: (FormFieldState<String> state) {
                return InputDecorator(
                  key: const ValueKey('year_dropdown'),
                  decoration: InputDecoration(
                      fillColor: Colors.white,
                      errorStyle: const TextStyle(
                          color: Constants.errorColor, fontSize: 16.0),
                      hintText: 'please select year of birth',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide:
                        const BorderSide(color: Constants.primary),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Constants.primary, width: 0.0),
                      )),
                  isEmpty: _sYear == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      style: const TextStyle(
                          color: Constants.lightPrimary),
                      dropdownColor: Constants.background,
                      value: _sYear,
                      isDense: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          _sYear = newValue!;
                          int year = int.parse(_sYear);

                          widget.user =
                              widget.user.copyWith(birthYear: year);
                          state.didChange(newValue);
                        });
                      },
                      items: years.map((String value) {
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
            const SizedBox(height: 24),
          ],
        ),
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'gender *',
                    style: TextStyle(
                        color: Constants.lightPrimary,
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
                      errorStyle: const TextStyle(
                          color: Constants.errorColor,
                          fontSize: 16.0),
                      hintText: 'please select gender',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 0.0),
                      )),
                  isEmpty: sGender == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      style: const TextStyle(
                          color: Constants.lightPrimary),
                      dropdownColor: Constants.background,
                      value: sGender,
                      isDense: true,
                      onChanged: (String? newValue) {
                        setState(() {
                          sGender = newValue!;
                          widget.user = widget.user.copyWith(gender: sGender);
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
          label: 'instagram link',
          text: widget.user.instagramLink,
          onChanged: (text) => widget.user = widget.user.copyWith(instagramLink: text),
        ),
        const SizedBox(height: 24),
        DarkTextFieldWidget(
          label: 'email',
          text: widget.user.email,
          onChanged: (email) =>
              widget.user = widget.user.copyWith(email: email),
        ),
        const SizedBox(height: 24),
        const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10, bottom: 5),
              child: DelayedDisplay(
                delay: Duration(seconds: 1),
                child: Text(
                  "* required",
                  style: TextStyle(
                    color: Constants.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        ButtonWidget(
          text: '💾 save',
          onClicked: () async {
            // we should have some validation here
            if (isDataValid()) {
              User freshUser = Fresh.freshUser(widget.user);

              UserPreferences.setUser(freshUser);
              FirestoreHelper.pushUser(freshUser);

              if(widget.task == 'register'){
                BlocHelper.setDefaultBlocs(widget.user.id);

                // adding them to blocCommunity lounge
                UserLounge userLounge = Dummy.getDummyUserLounge();
                userLounge = userLounge.copyWith(userId: widget.user.id,
                    userFcmToken: widget.user.fcmToken,
                    loungeId: Constants.blocCommunityLoungeId);
                FirestoreHelper.pushUserLounge(userLounge);

                if(widget.user.gender == 'female'){
                  UserLounge userLounge = Dummy.getDummyUserLounge();
                  userLounge = userLounge.copyWith(
                      userId: widget.user.id,
                      userFcmToken: widget.user.fcmToken,
                      loungeId: Constants.ladiesLoungeId);
                  FirestoreHelper.pushUserLounge(userLounge);
                }

                if(freshUser.imageUrl.isEmpty){
                  _uploadRandomPhoto(freshUser);
                }

                if(freshUser.username.isEmpty){
                  String username = '';
                  if(freshUser.surname.trim().isNotEmpty){
                    username = '${freshUser.name.trim().toLowerCase()}_${freshUser.surname.trim().toLowerCase()}';
                  } else {
                    username = freshUser.name.trim().toLowerCase();
                  }

                  //check if username is present in db
                  FirestoreHelper.pullUserByUsername(username).then((res) {
                    if(res.docs.isNotEmpty){
                      // username is already taken
                      username = username + NumberUtils.getRandomNumber(1,999).toString();
                      freshUser = freshUser.copyWith(username: username);
                      FirestoreHelper.pushUser(freshUser);
                      UserPreferences.setUser(freshUser);

                      GoRouter.of(context).pushReplacementNamed(RouteConstants.landingRouteName);
                    } else {
                      freshUser = freshUser.copyWith(username: username);
                      FirestoreHelper.pushUser(freshUser);
                      UserPreferences.setUser(freshUser);

                      GoRouter.of(context).pushReplacementNamed(RouteConstants.landingRouteName);
                    }
                  });
                } else {
                  Logx.ist(_TAG, 'hey there, welcome to bloc! 🦖');
                  GoRouter.of(context).pushReplacementNamed(RouteConstants.landingRouteName);
                }
              } else {

                Navigator.of(context).pop();
              }
            } else {
              Logx.i(_TAG,'user cannot be entered as data is incomplete');
            }
          },
        ),
        const SizedBox(height: 36),
        Footer()
      ],
    );
  }

  void _uploadRandomPhoto(blocUser.User user) async {
    String assetFileName = '';

    int photoNum = NumberUtils.getRandomNumber(1,5);
    if(user.gender == 'male'){
    } else {
      photoNum += 10;
    }
    assetFileName = 'assets/profile_photos/$photoNum.jpeg';

    File imageFile = await FileUtils.getAssetImageAsFile(assetFileName);
    String imageUrl = await FirestorageHelper.uploadFile(
        FirestorageHelper.USER_IMAGES,
        StringUtils.getRandomString(28),
        imageFile);

    user = user.copyWith(imageUrl: imageUrl);
    FirestoreHelper.pushUser(user);
    UserPreferences.setUser(user);

    Logx.i(_TAG, 'user default photo added.');
  }

  bool isDataValid() {
    if (widget.user.name.isEmpty) {
      Toaster.longToast('please enter your name');
      return false;
    }
    if (widget.user.surname.isEmpty) {
      Toaster.longToast('please enter your surname');
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

                            if(oldImageUrl.isNotEmpty &&
                                oldImageUrl.contains(FirestorageHelper.USER_IMAGES)){
                              FirestorageHelper.deleteFile(oldImageUrl);
                            }

                            Logx.ist(_TAG,'profile photo updated');

                            setState(() {
                              imagePath = image.path;
                            });
                          }
                        } else {
                          Logx.ist(_TAG, 'download our app to upload your photo and more');
                          //todo: need to add dialog to download the app
                        }

                        Navigator.of(context).pop();

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

                            if(oldImageUrl.isNotEmpty &&
                                oldImageUrl.contains(FirestorageHelper.USER_IMAGES)){
                              FirestorageHelper.deleteFile(oldImageUrl);
                            }

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
