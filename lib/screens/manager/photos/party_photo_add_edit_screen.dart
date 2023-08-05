import 'dart:io';

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

import '../../../db/entity/bloc_service.dart';

import '../../../db/entity/party_photo.dart';
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

  PartyPhotoAddEditScreen({Key? key, required this.partyPhoto, required this.task})
      : super(key: key);

  @override
  State<PartyPhotoAddEditScreen> createState() => _PartyPhotoAddEditScreenState();
}

class _PartyPhotoAddEditScreenState extends State<PartyPhotoAddEditScreen> {
  static const String _TAG = 'PartyPhotoAddEditScreen';

  String imagePath = '';
  String oldImageUrl = '';
  bool isPhotoChanged = false;

  List<BlocService> mBlocServices = [];
  List<BlocService> sBlocs = [];
  List<String> sBlocIds = [];
  bool _isBlocServicesLoading = true;

  DateTime sDate = DateTime.now();
  TimeOfDay sTimeOfDay = TimeOfDay.now();


  @override
  void initState() {
    if(widget.partyPhoto.blocServiceId.isNotEmpty){
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
      appBar: AppBar(title: Text('${widget.task} party photo'),
          titleSpacing: 0,
      ),
      body: _isBlocServicesLoading ? const LoadingWidget() : _buildBody(context),
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
                source: ImageSource.gallery, imageQuality: 99, maxHeight: 1024, maxWidth: 768);
            if (image == null) return;

            final directory = await getApplicationDocumentsDirectory();
            final name = basename(image.path);
            final imageFile = File('${directory.path}/$name');
            final newImage = await File(image.path).copy(imageFile.path);

            String photoImageUrl = await FirestorageHelper.uploadFile(
                FirestorageHelper.PARTY_PHOTO_IMAGES,
                StringUtils.getRandomString(28),
                newImage);

            Logx.ist(_TAG, 'photo uploaded: $photoImageUrl');

            widget.partyPhoto = widget.partyPhoto.copyWith(imageUrl: photoImageUrl);
            FirestoreHelper.pushPartyPhoto(widget.partyPhoto);

            setState(() {
              imagePath = imageFile.path;
              isPhotoChanged = true;
            });
          },
          child: SizedBox(
            height: mq.height * 0.25,
            width: mq.width,
            child: FadeInImage(
              placeholder: const AssetImage(
                  'assets/icons/logo.png'),
              image: NetworkImage(widget.partyPhoto.imageUrl),
              fit: BoxFit.contain,),
          ),
        ),
        TextFieldWidget(
            label: 'name *',
            text: widget.partyPhoto.partyName,
            onChanged: (text) {
              widget.partyPhoto = widget.partyPhoto.copyWith(partyName: text);
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
              items: mBlocServices
                  .map((e) => MultiSelectItem(
                  e, e.name))
                  .toList(),
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
                  // color: Constants.primary,
                  width: 0.0,
                ),
              ),
              searchable: true,
              onConfirm: (values) {
                sBlocs = values as List<BlocService>;
                if(sBlocs.isNotEmpty){
                  widget.partyPhoto = widget.partyPhoto.copyWith(blocServiceId : sBlocs.first.id);
                } else {
                  widget.partyPhoto = widget.partyPhoto.copyWith(blocServiceId: '');
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        _dateTimeContainer(context),

        // Row(
        //   children: <Widget>[
        //     const Text(
        //       'active : ',
        //       style: TextStyle(fontSize: 17.0),
        //     ), //Text
        //     const SizedBox(width: 10), //SizedBox
        //     Checkbox(
        //       value: widget.partyPhoto.isActive,
        //       onChanged: (value) {
        //         setState(() {
        //           widget.partyPhoto = widget.partyPhoto.copyWith(isActive: value);
        //         });
        //       },
        //     ), //Checkbox
        //   ], //<Widget>[]
        // ),

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
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ButtonWidget(
              height: 50,
              text: 'save',
              onClicked: () {

                if (isPhotoChanged) {
                  if (oldImageUrl.isNotEmpty) {
                    FirestorageHelper.deleteFile(oldImageUrl);
                  }
                }

                PartyPhoto fresh = Fresh.freshPartyPhoto(widget.partyPhoto);
                FirestoreHelper.pushPartyPhoto(fresh);
                Logx.ist(_TAG, 'party photo saved');
                Navigator.of(context).pop();
              },
            ),
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

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      DateTime _sDateTemp = DateTime(_sDate.year, _sDate.month, _sDate.day);

      setState(() {
        sDate = _sDateTemp;
        _selectTime(context);
      });
    }
  }

  Future<TimeOfDay> _selectTime(BuildContext context) async {
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    setState((){
      sTimeOfDay = pickedTime!;

      DateTime sDateTime = DateTime(sDate.year, sDate.month, sDate.day, sTimeOfDay.hour, sTimeOfDay.minute);

      widget.partyPhoto = widget.partyPhoto.copyWith(endTime: sDateTime.millisecondsSinceEpoch);
    });
    return sTimeOfDay;
  }

  Widget _dateTimeContainer(BuildContext context) {
    DateTime dateTime = DateTimeUtils.getDate(widget.partyPhoto.endTime);

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
          Text(DateTimeUtils.getFormattedDateString(dateTime.millisecondsSinceEpoch),
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
              minimumSize: const Size(50, 50), //////// HERE
            ),
            onPressed: () {
              _selectDate(context, dateTime);
            },
            child: const Text('end date & time'),
          ),
        ],
      ),
    );
  }

  // showDeleteDialog(BuildContext context) {
  //   return showDialog(
  //     context: context,
  //     builder: (BuildContext ctx) {
  //       return AlertDialog(
  //         title: Text('delete lounge ${widget.partyPhoto.name}'),
  //         content: Text(
  //             'deleting the lounge ${widget.partyPhoto.name}. are you sure you want to continue?'),
  //         actions: [
  //           TextButton(
  //             child: const Text("yes"),
  //             onPressed: () async {
  //               FirestoreHelper.deleteLounge(widget.partyPhoto.id);
  //               Toaster.shortToast('lounge deleted');
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: const Text("no"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }
}
