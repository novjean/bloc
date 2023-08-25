import 'dart:io';

import 'package:bloc/utils/file_utils.dart';
import 'package:bloc/widgets/ui/loading_widget.dart';
import 'package:bloc/widgets/ui/textfield_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delayed_display/delayed_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../../db/entity/bloc_service.dart';

import '../../../db/entity/party_photo.dart';
import '../../../helpers/dummy.dart';
import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../helpers/fresh.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/logx.dart';
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
  String mPartyName = '';
  int mPartyDate = Timestamp.now().millisecondsSinceEpoch;

  String imagePath = '';

  List<BlocService> mBlocServices = [];
  List<BlocService> sBlocs = [];
  List<String> sBlocIds = [];
  bool _isBlocServicesLoading = true;

  DateTime sDate = DateTime.now();
  TimeOfDay sTimeOfDay = TimeOfDay.now();
  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();

  @override
  void initState() {
    if (widget.partyPhoto.blocServiceId.isNotEmpty) {
      sBlocIds = [widget.partyPhoto.blocServiceId];
    }

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
        title: Text('${widget.task} party photo'),
        titleSpacing: 0,
      ),
      body:
          _isBlocServicesLoading ? const LoadingWidget() : _buildBody(context),
    );
  }

  _buildBody(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        GestureDetector(
          onTap: () async {
            final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
                maxHeight: 1024,
                maxWidth: 1280,
                imageQuality: 95);
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
                imageFile.path, 280, 210, 95);
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
                    maxHeight: 1024, maxWidth: 1280, imageQuality: 95);

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
                        imageFile.path, 280, 210, 95);
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                      imageFile.path, 280, 210, 95);
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
                  FirestorageHelper.deleteFile(widget.partyPhoto.imageUrl);
                  FirestoreHelper.deletePartyPhoto(widget.partyPhoto.id);
                  Navigator.of(context).pop();
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
      // DateTime _sDateTemp

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
}
