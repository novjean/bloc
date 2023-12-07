import 'dart:io';

import 'package:bloc/db/entity/bloc_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import '../../../db/entity/friend.dart';
import '../../../db/entity/history_music.dart';
import '../../../db/entity/party_guest.dart';
import '../../../db/entity/reservation.dart';
import '../../../db/entity/user.dart';
import '../../../db/entity/user_level.dart';
import '../../../db/entity/user_lounge.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../utils/constants.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/profile_widget.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';
import '../../../widgets/ui/loading_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';

class UserAddEditScreen extends StatefulWidget {
  User user;
  String task;
  List<UserLevel> userLevels;

  UserAddEditScreen({key, required this.user, required this.task, required this.userLevels})
      : super(key: key);

  @override
  _UserAddEditScreenState createState() => _UserAddEditScreenState();
}

class _UserAddEditScreenState extends State<UserAddEditScreen> {
  static const String _TAG = 'UserAddEditScreen';

  bool isPhotoChanged = false;
  late String oldImageUrl;
  late String newImageUrl;
  String imagePath = '';

  List<BlocService> blocServices = [];
  List<String> blocServiceNames = [];
  late String _sBlocServiceName;
  late String _sBlocServiceId;
  bool _isBlocServicesLoading = true;

  List<String> userLevelNames = [];
  late String sUserLevelName;
  late int sUserLevel;

  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();

  String sGender = 'male';
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
    sUserLevel = Constants.CUSTOMER_LEVEL;
    sUserLevelName = 'customer';

    for(UserLevel userLevel in widget.userLevels){
      userLevelNames.add(userLevel.name);
      if(widget.user.clearanceLevel == userLevel.level){
        sUserLevelName = userLevel.name;
      }
    }

    FirestoreHelper.pullAllBlocServices().then((res) {
      Logx.i(_TAG, "successfully pulled in all bloc services");

      if (res.docs.isNotEmpty) {
        List<BlocService> _blocServices = [];
        List<String> _blocServiceNames = [];

        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);

          if (i == 0) {
            _sBlocServiceId = blocService.id;
            _sBlocServiceName = blocService.name;
          }

          _blocServiceNames.add(blocService.name);
          _blocServices.add(blocService);
        }

        setState(() {
          blocServiceNames = _blocServiceNames;
          blocServices = _blocServices;
          _isBlocServicesLoading = false;
        });
      } else {
        Logx.em(_TAG, 'no bloc services found!');
        setState(() {
          _isBlocServicesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      titleSpacing: 0,
      title: AppBarTitle(title: '${widget.task} user',),
    ),
    body: _buildBody(context),
  );

  _buildBody(BuildContext context) {
    return _isBlocServicesLoading
        ? const LoadingWidget()
        : ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        ProfileWidget(
          imagePath: imagePath.isEmpty? widget.user.imageUrl:imagePath,
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
          onChanged: (name) =>
          widget.user = widget.user.copyWith(name: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'surname',
          text: widget.user.surname,
          onChanged: (name) =>
          widget.user = widget.user.copyWith(surname: name),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'username',
          text: widget.user.username,
          onChanged: (text) =>
          widget.user = widget.user.copyWith(username: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'phone',
          text: widget.user.phoneNumber.toString(),
          maxLines: 1,
          onChanged: (value) {
            int phoneNumber = int.parse(value);
            widget.user = widget.user.copyWith(phoneNumber: phoneNumber);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'email',
          text: widget.user.email,
          maxLines: 1,
          onChanged: (value) {
            widget.user = widget.user.copyWith(email: value);
          },
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'year',
          text: widget.user.birthYear.toString(),
          maxLines: 1,
          onChanged: (value) {
            int num = int.parse(value);
            widget.user = widget.user.copyWith(birthYear: num);
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
                    'gender',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      ),
                  isEmpty: sGender == '',
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'challenge level ',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ButtonWidget(text: '  down  ', onClicked: () {
                  int level = widget.user.challengeLevel;
                  level--;
                  setState(() {
                    widget.user = widget.user.copyWith(challengeLevel: level);
                    FirestoreHelper.pushUser(widget.user);
                  });
                },),
                DarkButtonWidget(text: widget.user.challengeLevel.toString(), onClicked: () {  },),
                ButtonWidget(text: 'level up', onClicked: () {
                  int level = widget.user.challengeLevel;
                  level++;
                  setState(() {
                    widget.user = widget.user.copyWith(challengeLevel: level);
                    FirestoreHelper.pushUser(widget.user);
                  });
                },),
              ],
            )
          ],
        ),

        const SizedBox(height: 24),
        FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              key: const ValueKey('bloc_service_id'),
              decoration: InputDecoration(
                  errorStyle: const TextStyle(
                      color: Constants.errorColor,
                      fontSize: 16.0),
                  hintText: 'please select bloc service',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              isEmpty: _sBlocServiceName == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _sBlocServiceName,
                  isDense: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      _sBlocServiceName = newValue!;

                      for (BlocService service in blocServices) {
                        if (service.name == _sBlocServiceName) {
                          _sBlocServiceId = service.id;
                        }
                      }

                      widget.user = widget.user
                          .copyWith(blocServiceId: _sBlocServiceId);
                      state.didChange(newValue);
                    });
                  },
                  items: blocServiceNames.map((String value) {
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
        FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              key: const ValueKey('user_level'),
              decoration: InputDecoration(
                  errorStyle: const TextStyle(
                      color: Constants.errorColor,
                      fontSize: 16.0),
                  hintText: 'please select user level',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0))),
              isEmpty: sUserLevelName == '',
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sUserLevelName,
                  isDense: true,
                  onChanged: (String? newValue) {
                    setState(() {
                      sUserLevelName = newValue!;

                      for (UserLevel userLevel in widget.userLevels) {
                        if (userLevel.name == sUserLevelName) {
                          sUserLevel = userLevel.level;
                        }
                      }

                      widget.user = widget.user
                          .copyWith(clearanceLevel: sUserLevel);
                      state.didChange(newValue);
                    });
                  },
                  items: userLevelNames.map((String value) {
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
        ButtonWidget(
          text: 'save',
          onClicked: () {
            if (isPhotoChanged) {
              widget.user = widget.user.copyWith(imageUrl: newImageUrl);
              if(oldImageUrl.isNotEmpty &&
                  oldImageUrl.contains(FirestorageHelper.USER_IMAGES)){
                  FirestorageHelper.deleteFile(oldImageUrl);
              }
            }

            if (widget.user.blocServiceId.isEmpty) {
              widget.user =
                  widget.user.copyWith(blocServiceId: _sBlocServiceId);
            }

            FirestoreHelper.pushUser(widget.user);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 36),
        DarkButtonWidget(
          text: 'delete',
          onClicked: () {

            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('delete ${widget.user.name} ${widget.user.surname}'),
                content: const Text(
                  'entire history of the user shall be removed if proceeded, are you sure you want to delete the user?',
                ),
                actions: [
                  ElevatedButton(
                    child: const Text('no'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  ElevatedButton(
                    child: const Text('yes'),
                    onPressed: () async {
                      // delete all lounge user
                      FirestoreHelper.pullUserLounges(widget.user.id).then((res) {
                        if(res.docs.isNotEmpty){
                          for (int i = 0; i < res.docs.length; i++) {
                            DocumentSnapshot document = res.docs[i];
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            UserLounge userLounge = Fresh.freshUserLoungeMap(data, false);

                            FirestoreHelper.deleteUserLounge(userLounge.id);
                          }
                          Logx.ist(_TAG, '${widget.user.name} ${widget.user.surname} is removed from ${res.docs.length} lounges');
                        }
                      });

                      FirestoreHelper.pullHistoryMusicByUser(widget.user.id).then((res) {
                        if(res.docs.isNotEmpty){
                          for (int i = 0; i < res.docs.length; i++) {
                            DocumentSnapshot document = res.docs[i];
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            final HistoryMusic historyMusic = Fresh.freshHistoryMusicMap(data, false);
                            FirestoreHelper.deleteHistoryMusic(historyMusic.id);
                          }
                        }
                        Logx.ist(_TAG, '${widget.user.name} ${widget.user.surname}\'s ${res.docs.length} music history deleted');
                      });

                      FirestoreHelper.pullPartyGuestsByUser(widget.user.id).then((res) {
                        if(res.docs.isNotEmpty){
                          for (int i = 0; i < res.docs.length; i++) {
                            DocumentSnapshot document = res.docs[i];
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            final PartyGuest partyGuest = Fresh.freshPartyGuestMap(data, false);
                            FirestoreHelper.deletePartyGuest(partyGuest.id);
                          }
                          Logx.ist(_TAG, '${widget.user.name} ${widget.user.surname}\'s ${res.docs.length} guest list requests deleted');
                        }
                      });

                      FirestoreHelper.pullReservationsByUser(widget.user.id).then((res) {
                        if(res.docs.isNotEmpty){
                          for (int i = 0; i < res.docs.length; i++) {
                            DocumentSnapshot document = res.docs[i];
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            final Reservation reservation = Fresh.freshReservationMap(data, false);
                            FirestoreHelper.deleteReservation(reservation.id);
                          }
                          Logx.ist(_TAG, '${widget.user.name} ${widget.user.surname}\'s ${res.docs.length} reservations deleted');
                        }
                      });

                      FirestoreHelper.pullFriendConnections(widget.user.id).then((res) {
                        if(res.docs.isNotEmpty){
                          for(int i=0;i<res.docs.length; i++){
                            DocumentSnapshot document = res.docs[i];
                            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                            Friend friend = Fresh.freshFriendMap(data, false);
                            FirestoreHelper.deleteFriend(friend.id);
                          }
                        }
                      });

                      if(widget.user.imageUrl.isNotEmpty &&
                          widget.user.imageUrl.contains(FirestorageHelper.USER_IMAGES)){
                        FirestorageHelper.deleteFile(widget.user.imageUrl);
                      }

                      FirestoreHelper.deleteUser(widget.user.id);
                      Logx.ist(_TAG, 'user is successfully deleted');

                      Navigator.of(ctx).pop(true);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}


