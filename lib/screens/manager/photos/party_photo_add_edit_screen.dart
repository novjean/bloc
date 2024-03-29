import 'dart:io';

import 'package:bloc/utils/file_utils.dart';
import 'package:bloc/widgets/ui/app_bar_title.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/textfield_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../../api/apis.dart';
import '../../../db/entity/bloc_service.dart';

import '../../../db/entity/friend.dart';
import '../../../db/entity/friend_notification.dart';
import '../../../db/entity/party_photo.dart';
import '../../../db/entity/user.dart';
import '../../../db/entity/user_photo.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/logx.dart';
import '../../../utils/number_utils.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/dark_button_widget.dart';

class PartyPhotoAddEditScreen extends StatefulWidget {
  PartyPhoto partyPhoto;
  String task;

  PartyPhotoAddEditScreen(
      {Key? key, required this.partyPhoto, required this.task})
      : super(key: key);

  @override
  State<PartyPhotoAddEditScreen> createState() =>
      _PartyPhotoAddEditScreenState();
}

class _PartyPhotoAddEditScreenState extends State<PartyPhotoAddEditScreen> {
  static const String _TAG = 'PartyPhotoAddEditScreen';

  List<String> mImageUrls = [];
  List<String> mImageThumbUrls = [];
  List<PartyPhoto> mPartyPhotos = [];
  int mPartyDate = Timestamp.now().millisecondsSinceEpoch;

  String imagePath = '';
  bool isStorySize = false;

  List<BlocService> mBlocServices = [];
  List<BlocService> sBlocs = [];
  List<String> sBlocIds = [];
  bool _isBlocServicesLoading = true;

  DateTime sDate = DateTime.now();
  TimeOfDay sTimeOfDay = TimeOfDay.now();
  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();

  List<User> mUsers = [];
  List<User> mFcmUsers = [];
  bool isUsersLoading = true;
  List<String> sUserNames = [];
  List<User> sUsers = [];
  List<String> sUserIds = [];

  List<User> downloaders = [];

  @override
  void initState() {
    if (widget.partyPhoto.blocServiceId.isNotEmpty) {
      sBlocIds = [widget.partyPhoto.blocServiceId];
    }

    sUserIds = widget.partyPhoto.tags;
    FirestoreHelper.pullUsersApp().then((res) {
      if(res.docs.isNotEmpty){
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final User user = Fresh.freshUserMap(data, false);
          mUsers.add(user);

          if (sUserIds.contains(user.id)) {
            sUsers.add(user);
            sUserNames.add('${user.name} ${user.surname}');
          }
        }

        setState(() {
          isUsersLoading = false;
        });
      } else {
        Logx.est(_TAG, 'no app users, time to close up shop!');
        setState(() {
          isUsersLoading = false;
        });
      }
    });

    FirestoreHelper.pullAllBlocServices().then((res) {
      Logx.i(_TAG, "successfully pulled in all bloc services ");

      if (res.docs.isNotEmpty) {
        for (int i = 0; i < res.docs.length; i++) {
          DocumentSnapshot document = res.docs[i];
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          final BlocService blocService = BlocService.fromMap(data);
          mBlocServices.add(blocService);

          if (sBlocIds.contains(blocService.id)) {
            sBlocs.add(blocService);
          }
        }

        setState(() {
          _isBlocServicesLoading = false;
        });
      } else {
        Logx.i(_TAG, 'no bloc services found!');
        setState(() {
          _isBlocServicesLoading = false;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(title: '${widget.task} party photo'),
        titleSpacing: 0,
      ),
      body:
          _isBlocServicesLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    double longSide = 1280;
    double shortSide = 1024;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                maxHeight: isStorySize? longSide:shortSide,
                maxWidth: isStorySize? shortSide:longSide,
                imageQuality: 99);
            if (image == null) return;

            int fileSize = await image.length();
            Logx.ist(_TAG, 'file size : ${fileSize / 1000} kb');

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            String oldImageUrl = widget.partyPhoto.imageUrl;
            FirestorageHelper.deleteFile(oldImageUrl);

            String photoImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.PARTY_PHOTO_IMAGES,
                StringUtils.getRandomString(28),
                newImage);

            Logx.ist(_TAG, 'photo uploaded: $photoImageUrl');

            String oldImageThumbUrl = widget.partyPhoto.imageThumbUrl;
            if (oldImageThumbUrl.isNotEmpty) {
              FirestorageHelper.deleteFile(oldImageThumbUrl);
            }

            final newThumbImage = await FileUtils.getImageCompressed(
                imageFile.path, isStorySize? 280:210, isStorySize? 210:280, 95);
            String imageThumbUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.PARTY_PHOTO_THUMB_IMAGES,
                StringUtils.getRandomString(28),
                newThumbImage);

            widget.partyPhoto = widget.partyPhoto.copyWith(
                imageUrl: photoImageUrl, imageThumbUrl: imageThumbUrl);
            FirestoreHelper.pushPartyPhoto(widget.partyPhoto);

            setState(() {
              imagePath = imageFile.path;
            });
          },
          child: SizedBox(
            height: mq.height * 0.25,
            width: mq.width,
            child: FadeInImage(
              placeholder: const AssetImage('assets/icons/logo.png'),
              image: NetworkImage(widget.partyPhoto.imageUrl),
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${mImageUrls.length} photos: '),
            const Spacer(),
            ButtonWidget(
              text: 'pick photos',
              onClicked: () async {
                List<XFile> images = await ImagePicker().pickMultiImage(
                    maxHeight: isStorySize? longSide:shortSide,
                    maxWidth: isStorySize? shortSide:longSide,
                    imageQuality: 99);

                if (images.isNotEmpty) {
                  final directory = await getApplicationDocumentsDirectory();

                  for (int i = 0; i < images.length; i++) {
                    XFile image = images[i];

                    final name = basename(image.path);
                    final imageFile = File('${directory.path}/$name');
                    final newImage =
                        await File(image.path).copy(imageFile.path);

                    String imageUrl = await FirestorageHelper.uploadFile(
                        FirestorageHelper.PARTY_PHOTO_IMAGES,
                        StringUtils.getRandomString(28),
                        newImage);

                    final newThumbImage = await FileUtils.getImageCompressed(
                        imageFile.path, isStorySize? 280:210, isStorySize? 210:280, 99);
                    String imageThumbUrl = await FirestorageHelper.uploadFile(
                        FirestorageHelper.PARTY_PHOTO_THUMB_IMAGES,
                        StringUtils.getRandomString(28),
                        newThumbImage);

                    PartyPhoto partyPhoto = Dummy.getDummyPartyPhoto();
                    partyPhoto = partyPhoto.copyWith(
                      imageUrl: imageUrl,
                      imageThumbUrl: imageThumbUrl,
                      partyName: widget.partyPhoto.partyName,
                      partyDate: widget.partyPhoto.partyDate,
                      endTime: widget.partyPhoto.endTime,
                      blocServiceId: widget.partyPhoto.blocServiceId,
                      initLikes: widget.partyPhoto.initLikes
                    );
                    FirestoreHelper.pushPartyPhoto(partyPhoto);

                    mImageUrls.add(imageUrl);
                    Logx.ist(_TAG, '${i + 1}/${images.length} photo uploaded');
                  }

                  Logx.ist(_TAG, 'all photos successfully uploaded!');

                  setState(() {
                    mImageUrls;
                  });
                } else {
                  return;
                }
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
                                content: photosListDialog(),
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
        const SizedBox(height: 12),
        Row(
          children: [
            const Text('story size: ',
                style: TextStyle(
                  fontSize: 16,
                )),
            Checkbox(
              value: isStorySize,
              side: MaterialStateBorderSide.resolveWith(
                    (states) => const BorderSide(
                    width: 1.0),
              ),
              onChanged: (value) {
                setState(() {
                  isStorySize = value!;
                });
              },
            ),
          ],
        ),

        const SizedBox(height: 24),

        TextFieldWidget(
            label: 'name *',
            text: widget.partyPhoto.partyName,
            onChanged: (text) {
              setState(() {
                widget.partyPhoto = widget.partyPhoto.copyWith(partyName: text);
              });
            }),
        const SizedBox(height: 24),
        Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'bloc *',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items:
                  mBlocServices.map((e) => MultiSelectItem(e, e.name)).toList(),
              initialValue: sBlocs.map((e) => e).toList(),
              listType: MultiSelectListType.CHIP,
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
              title: const Text('pick a bloc'),
              buttonText: const Text(
                'select',
                style: TextStyle(color: Constants.darkPrimary),
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sBlocs = values as List<BlocService>;
                if (sBlocs.isNotEmpty) {
                  setState(() {
                    widget.partyPhoto = widget.partyPhoto
                        .copyWith(blocServiceId: sBlocs.first.id);
                  });
                } else {
                  setState(() {
                    widget.partyPhoto =
                        widget.partyPhoto.copyWith(blocServiceId: '');
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _dateTimeContainer(context, 'start'),
        const SizedBox(height: 24),
        _dateTimeContainer(context, 'end'),
        const SizedBox(height: 24),
        TextFieldWidget(
            label: 'views',
            text: widget.partyPhoto.views.toString(),
            onChanged: (text) {
              int view = int.parse(text);
              setState(() {
                widget.partyPhoto = widget.partyPhoto.copyWith(views: view);
              });
            }),
        const SizedBox(height: 24),
        TextFieldWidget(
            label: 'init likes',
            text: widget.partyPhoto.initLikes.toString(),
            onChanged: (text) {
              int initLikes = int.parse(text);
              setState(() {
                widget.partyPhoto =
                    widget.partyPhoto.copyWith(initLikes: initLikes);
              });
            }),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),

            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'tags',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            MultiSelectDialogField(
              items: mUsers
                  .map((e) => MultiSelectItem(e,
                  '${e.name.toLowerCase()} ${e.surname.toLowerCase()}'))
                  .toList(),
              initialValue: sUsers.map((e) => e).toList(),
              listType: MultiSelectListType.CHIP,
              buttonIcon: Icon(
                Icons.arrow_drop_down,
                color: Colors.grey.shade700,
              ),
              title: const Text('app members'),
              buttonText: const Text(
                'select',
              ),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                border: Border.all(
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sUsers = values as List<User>;
                sUserIds = [];
                sUserNames = [];

                for (User user in sUsers) {
                  sUserIds.add(user.id);
                  sUserNames.add(user.name);
                }

                if (sUserIds.isEmpty) {
                  Logx.i(_TAG, 'no users selected');
                  widget.partyPhoto = widget.partyPhoto.copyWith(tags: []);

                  FirestoreHelper.pullUserPhotosByPartyPhotoId(widget.partyPhoto.id).then((res) {
                    if(res.docs.isNotEmpty){
                      for (int i = 0; i < res.docs.length; i++) {
                        DocumentSnapshot document = res.docs[i];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        UserPhoto userPhoto = Fresh.freshUserPhotoMap(data, false);
                        FirestoreHelper.deleteUserPhoto(userPhoto.id);
                      }
                      Logx.ist(_TAG, '${res.docs.length} user photo docs has been deleted');
                    } else {
                      Logx.ist(_TAG, 'no user photo docs has been found!');
                    }
                  });
                } else {
                  // clear of all user photos
                  FirestoreHelper.pullUserPhotosByPartyPhotoId(widget.partyPhoto.id).then((res) {
                    if(res.docs.isNotEmpty){
                      for (int i = 0; i < res.docs.length; i++) {
                        DocumentSnapshot document = res.docs[i];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        UserPhoto userPhoto = Fresh.freshUserPhotoMap(data, false);
                        FirestoreHelper.deleteUserPhoto(userPhoto.id);
                      }
                      Logx.ist(_TAG, '${res.docs.length} user photo docs has been deleted');
                    } else {
                      Logx.ist(_TAG, 'no user photo docs has been found!');
                    }
                  });

                  // check if all tagged members have usernames
                  FirestoreHelper.pullUsersByIds(sUserIds).then((res) {
                    if(res.docs.isNotEmpty){
                      for (int i = 0; i < res.docs.length; i++) {
                        DocumentSnapshot document = res.docs[i];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        User user = Fresh.freshUserMap(data, false);

                        if(user.fcmToken.isNotEmpty){
                          mFcmUsers.add(user);
                        }

                        if(user.username.isEmpty){
                          String username = '';
                          if(user.surname.trim().isNotEmpty){
                            username = '${user.name.trim().toLowerCase()}_${user.surname.trim().toLowerCase()}';
                          } else {
                            username = user.name.trim().toLowerCase();
                          }

                          FirestoreHelper.pullUserByUsername(username).then((res) {
                            if(res.docs.isNotEmpty){
                              // username is already taken
                              username = username + NumberUtils.getRandomNumber(1,999).toString();
                              user = user.copyWith(username: username);
                              FirestoreHelper.pushUser(user);
                              Logx.ist(_TAG, '${user.name} ${user.surname} has new username : ${user.username}');
                            } else {
                              user = user.copyWith(username: username);
                              FirestoreHelper.pushUser(user);
                              Logx.ist(_TAG, '${user.name} ${user.surname} has new username : ${user.username}');
                            }
                          });
                        }
                      }
                      widget.partyPhoto =
                          widget.partyPhoto.copyWith(tags: sUserIds);

                      for(String userId in sUserIds){
                        UserPhoto uPhoto = Dummy.getDummyUserPhoto();
                        uPhoto = uPhoto.copyWith(userId: userId, partyPhotoId: widget.partyPhoto.id, isConfirmed: true);
                        FirestoreHelper.pushUserPhoto(uPhoto);
                      }

                      _showNotifyTaggedUsersFollowersDialog(context, mFcmUsers);
                    } else {
                      Logx.est(_TAG, 'tagged members could not be found, tags cleared!');
                      // widget.partyPhoto = widget.partyPhoto.copyWith(tags: []);
                    }

                  });
                }
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Text(
                  'free photo : ',
                  style: TextStyle(fontSize: 17.0),
                ), //Text
                const SizedBox(width: 10), //SizedBox
                Checkbox(
                  value: widget.partyPhoto.isFreePhoto,
                  onChanged: (value) {
                    setState(() {
                      widget.partyPhoto = widget.partyPhoto.copyWith(isFreePhoto: value);
                    });
                  },
                ), //Checkbox
              ], //<Widget>[]
            ),
            const SizedBox(height: 12),
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
            const SizedBox(height: 24),

            ButtonWidget(
              height: 50,
              text: '💾 save',
              onClicked: () {
                if (widget.partyPhoto.imageUrl.isNotEmpty) {
                  PartyPhoto fresh = Fresh.freshPartyPhoto(widget.partyPhoto);
                  FirestoreHelper.pushPartyPhoto(fresh);
                  Logx.ist(_TAG, 'party photo saved');
                }
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 24),
            ButtonWidget(
                height: 50,
                text: 'check friendship',
                onClicked: () async {
                  List<String> tagIds = widget.partyPhoto.tags;

                  for(int i=0; i<tagIds.length; i++){
                    for(int j=0; j<tagIds.length; j++){
                      if(i==j){
                        continue;
                      }
                      String userId = tagIds[i];
                      String friendUserId = tagIds[j];

                      String name1 = sUserNames[i];
                      String name2 = sUserNames[j];

                      await FirestoreHelper.pullFriend(userId, friendUserId).then((res) async {
                        if(res.docs.isNotEmpty){
                          // they are friends, nothing to do
                        } else {
                          Logx.ist(_TAG, '$name1 and $name2 are not friends!');
                          await _showUsersConnectDialog(context, userId, friendUserId, name1, name2);
                        }
                      });
                    }
                  }
                }),
            const SizedBox(height: 24),
            ButtonWidget(
                height: 50,
                text: 'view downloaders',
                onClicked: () async {
                  List<String> downloaders = widget.partyPhoto.downloaders;

                  FirestoreHelper.pullUsersByIds(downloaders).then((res) {
                    if(res.docs.isNotEmpty){
                      for (int i = 0; i < res.docs.length; i++) {
                        DocumentSnapshot document = res.docs[i];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        User user = Fresh.freshUserMap(data, false);

                        Logx.ist(_TAG, '${user.name} ${user.surname} has downloaded');
                      }
                    }
                  });
                }),
            const SizedBox(height: 24),
            ButtonWidget(
                height: 50,
                text: 'update thumbnail',
                onClicked: () async {
                  final Uri url = Uri.parse(widget.partyPhoto.imageUrl);
                  final response = await http.get(url);

                  final tempDir = await getTemporaryDirectory();
                  final imageFile = File('${tempDir.path}/temp_image.png');
                  await imageFile.writeAsBytes(response.bodyBytes);

                  String oldImageThumbUrl = widget.partyPhoto.imageThumbUrl;
                  if (oldImageThumbUrl.isNotEmpty) {
                    FirestorageHelper.deleteFile(oldImageThumbUrl);
                  }

                  final newThumbImage = await FileUtils.getImageCompressed(
                      imageFile.path, isStorySize? 280:210, isStorySize?210:280, 95);
                  String imageThumbUrl = await FirestorageHelper.uploadFile(
                      FirestorageHelper.PARTY_PHOTO_THUMB_IMAGES,
                      StringUtils.getRandomString(28),
                      newThumbImage);

                  widget.partyPhoto =
                      widget.partyPhoto.copyWith(imageThumbUrl: imageThumbUrl);
                  FirestoreHelper.pushPartyPhoto(widget.partyPhoto);

                  Logx.ist(_TAG, 'photo thumbnail size updated ');
                }),
            const SizedBox(height: 36),
            DarkButtonWidget(
                height: 50,
                text: 'delete',
                onClicked: () {
                  if(widget.partyPhoto.tags.isNotEmpty){
                    _showPhotoTagsDeleteConfirm(context);
                  } else {
                    FirestorageHelper.deleteFile(widget.partyPhoto.imageUrl);
                    FirestorageHelper.deleteFile(widget.partyPhoto.imageThumbUrl);
                    FirestoreHelper.deletePartyPhoto(widget.partyPhoto.id);
                    Navigator.of(context).pop();
                  }
                }),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Future<void> _selectDate(
      BuildContext context, DateTime initDate, String type) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      setState(() {
        sDate = DateTime(_sDate.year, _sDate.month, _sDate.day);
        _selectTime(context, type);
      });
    }
  }

  Future<TimeOfDay> _selectTime(BuildContext context, String type) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    setState(() {
      sTimeOfDay = pickedTime!;

      DateTime sDateTime = DateTime(sDate.year, sDate.month, sDate.day,
          sTimeOfDay.hour, sTimeOfDay.minute);

      if (type == 'start') {
        setState(() {
          widget.partyPhoto = widget.partyPhoto
              .copyWith(partyDate: sDateTime.millisecondsSinceEpoch);
        });
      } else {
        setState(() {
          widget.partyPhoto = widget.partyPhoto
              .copyWith(endTime: sDateTime.millisecondsSinceEpoch);
        });
      }
    });
    return sTimeOfDay;
  }

  Widget _dateTimeContainer(BuildContext context, String type) {
    sStartDateTime = DateTimeUtils.getDate(widget.partyPhoto.partyDate);
    sEndDateTime = DateTimeUtils.getDate(widget.partyPhoto.endTime);

    String title = '';
    DateTime dateTime;
    if (type == 'start') {
      dateTime = sStartDateTime;
      title = 'party date';
    } else {
      dateTime = sEndDateTime;
      title = 'end date';
    }

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black38,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      padding: const EdgeInsets.only(left: 10, top: 5, right: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              DateTimeUtils.getFormattedDateString(
                  dateTime.millisecondsSinceEpoch),
              style: const TextStyle(
                fontSize: 18,
              )),
          const SizedBox(
            height: 20.0,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primary,
              foregroundColor: Colors.white,
              shadowColor: Constants.shadowColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50),
            ),
            onPressed: () {
              _selectDate(context, dateTime, type);
            },
            child: Text(title),
          ),
        ],
      ),
    );
  }

  Widget photosListDialog() {
    return SingleChildScrollView(
      child: SizedBox(
        height: mq.height * 0.5, // Change as per your requirement
        width: mq.width * 0.8, // Change as per your requirement
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
                        width: 120, height: 80, fit: BoxFit.contain),
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
                          FirestoreHelper.deletePartyPhoto(
                              mPartyPhotos[index].id);
                          setState(() {
                            mImageUrls.removeAt(index);
                          });
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

  _showPhotoTagsDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            '📛 delete tagged photo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: const Text(
              "this is a tagged photo, are you sure you want to delete?"),
          actions: [
            TextButton(
              child: const Text("yes"),
              onPressed: () {
                FirestoreHelper.pullUserPhotosByPartyPhotoId(widget.partyPhoto.id).then((res) {
                  if(res.docs.isNotEmpty){
                    for (int i = 0; i < res.docs.length; i++) {
                      DocumentSnapshot document = res.docs[i];
                      Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                      UserPhoto userPhoto = Fresh.freshUserPhotoMap(data, false);
                      FirestoreHelper.deleteUserPhoto(userPhoto.id);
                    }
                    Logx.ist(_TAG, '${res.docs.length} user photo docs has been deleted');
                  }
                });

                FirestorageHelper.deleteFile(widget.partyPhoto.imageUrl);
                FirestorageHelper.deleteFile(widget.partyPhoto.imageThumbUrl);
                FirestoreHelper.deletePartyPhoto(widget.partyPhoto.id);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  _showNotifyTaggedUsersFollowersDialog(BuildContext context, List<User> fcmUsers) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            'notify tagged members and followers',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: const Text(
              "are you sure you want to notify them?"),
          actions: [
            TextButton(
              child: const Text("yes everyone"),
              onPressed: () async {
                Navigator.of(context).pop();

                for(User user in fcmUsers){
                  String title = 'you\'ve been tagged in ${widget.partyPhoto.partyName}! 🔥';
                  String message =
                      'congratulations ${user.name}, your photo\'s been featured! time to check out the vibes. 📸';

                  //send a notification
                  Apis.sendPushNotification(
                      user.fcmToken, title, message);
                  Logx.ist(_TAG,
                      'notification has been sent to ${user.name} ${user.surname}');

                  FriendNotification notification = Dummy.getDummyFriendNotification();
                  notification = notification.copyWith(topic: user.id,
                      imageUrl: widget.partyPhoto.imageUrl,
                      title: '🤩 ${user.name} has a new photo'.toLowerCase(),
                      message: 'Latest pic just landed, catch ${user.name} in the spotlight! 📸💝'.toLowerCase()
                  );
                  FirestoreHelper.pushFriendNotification(notification);

                  Logx.ist(_TAG, 'friend notification sent to all followers of ${user.name}');
                }
              },
            ),

            TextButton(
              child: const Text("tagged"),
              onPressed: () async {
                Navigator.of(context).pop();

                for(User user in fcmUsers){
                  String title = 'you\'ve been tagged in ${widget.partyPhoto.partyName}! 🔥';
                  String message =
                      'congratulations ${user.name}, your photo\'s been featured! time to check out the vibes. 📸';

                  //send a notification
                  Apis.sendPushNotification(
                      user.fcmToken, title, message);
                  Logx.ist(_TAG,
                      'notification has been sent to ${user.name} ${user.surname}');
                }
              },
            ),

            TextButton(
              child: const Text("followers"),
              onPressed: () async {
                Navigator.of(context).pop();

                for(User user in fcmUsers){
                  FriendNotification notification = Dummy.getDummyFriendNotification();
                  notification = notification.copyWith(topic: user.id,
                      imageUrl: widget.partyPhoto.imageUrl,
                      title: '🤩 ${user.name} has a new photo'.toLowerCase(),
                      message: 'Latest pic just landed, catch ${user.name} in the spotlight! 📸💝'.toLowerCase()
                  );
                  FirestoreHelper.pushFriendNotification(notification);

                  Logx.ist(_TAG, 'friend notification sent to all followers of ${user.name}');
                }
              },
            ),

            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  _showUsersConnectDialog(BuildContext context,
      String userId, String friendUserId,
      String name1,
      String name2) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Constants.lightPrimary,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          contentPadding: const EdgeInsets.all(16.0),
          title: const Text(
            'connect tagged members',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.black),
          ),
          content: Text(
              "are you sure you want to connect $name1 and $name2?"),
          actions: [
            TextButton(
              child: const Text("yes & notify"),
              onPressed: () async {
                Navigator.of(context).pop();

                Friend friend = Dummy.getDummyFriend();
                friend = friend.copyWith(userId: userId, friendUserId: friendUserId);
                FirestoreHelper.pushFriend(friend);

                Logx.ist(_TAG, '$name1 is now friends with $name2');

                for(User user in mFcmUsers){
                  if(user.id == friendUserId){
                    String title = '🤍 new friend alert';
                    String message = '$name1 has added you as their friend!'.toLowerCase();

                    Apis.sendPushNotification(user.fcmToken, title, message);
                    Logx.ist(_TAG, '$name2 is notified about the friendship');
                    break;
                  }
                }
              },
            ),
            TextButton(
              child: const Text("yes"),
              onPressed: () async {
                Navigator.of(context).pop();

                Friend friend = Dummy.getDummyFriend();
                friend = friend.copyWith(userId: userId, friendUserId: friendUserId);
                FirestoreHelper.pushFriend(friend);

                Logx.ist(_TAG, '$name1 is now friends with $name2');
              },
            ),

            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Constants.darkPrimary), // Set your desired background color
              ),
              child: const Text("no"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }


}
