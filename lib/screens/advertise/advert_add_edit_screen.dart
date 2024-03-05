import 'dart:io';

import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../../../helpers/firestorage_helper.dart';
import '../../../helpers/firestore_helper.dart';
import '../../../utils/constants.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/logx.dart';
import '../../../utils/string_utils.dart';
import '../../../widgets/ui/app_bar_title.dart';
import '../../../widgets/ui/button_widget.dart';
import '../../../widgets/ui/textfield_widget.dart';
import '../../db/entity/advert.dart';

class AdvertAddEditScreen extends StatefulWidget {
  Advert advert;
  String task;

  AdvertAddEditScreen({key, required this.advert, required this.task})
      : super(key: key);

  @override
  _AdvertAddEditScreenState createState() =>
      _AdvertAddEditScreenState();
}

class _AdvertAddEditScreenState extends State<AdvertAddEditScreen> {
  static const String _TAG = 'AdvertAddEditScreen';

  String newImageUrl = '';
  bool isStorySize = false;

  DateTime sStartDateTime = DateTime.now();
  DateTime sEndDateTime = DateTime.now();
  DateTime sDate = DateTime.now();
  TimeOfDay sTimeOfDay = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      titleSpacing: 0,
      title: AppBarTitle(title: 'advertise'),
    ),
    body: _buildBody(context),
  );
  }

  _buildBody(BuildContext context) {
    double longSide = 1280;
    double shortSide = 1024;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        widget.advert.imageUrls.isNotEmpty ? SizedBox(
            width: double.infinity,
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/logo.png'),
              image: NetworkImage(widget.advert.imageUrls[0]),
              fit: BoxFit.contain,
            )) : Stack(
              children: [
                SizedBox(
                   width: double.infinity,
                  child: Image.asset('assets/images/logo.png', // Replace with your actual asset path
                  fit: BoxFit.cover, // Use BoxFit to cover the entire container
                        ),
                      ),
                Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: ButtonWidget(text: 'upload ad image', onClicked: () async {
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 99,
                      maxHeight: longSide,
                      maxWidth: shortSide,
                    );
                    if (image == null) return;

                    int fileSize = await image.length();
                    Logx.d(_TAG, 'file size : ${fileSize / 1000} kb');

                    final directory = await getApplicationDocumentsDirectory();
                    final name = basename(image.path);
                    final imageFile = File('${directory.path}/$name');
                    final newImage = await File(image.path).copy(imageFile.path);

                    newImageUrl = await FirestorageHelper.uploadFile(
                        FirestorageHelper.ADVERT_IMAGES,
                        StringUtils.getRandomString(28),
                        newImage);

                    widget.advert.imageUrls.add(newImageUrl);
                    setState(() {
                      FirestoreHelper.pushAdvert(widget.advert);
                    });
                  }),
                )
              ]
            ),
        const SizedBox(height: 15),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: [
        //     Text('${widget.advert.imageUrls.length} photos : '),
        //     const Spacer(),
        //     ButtonWidget(
        //       text: 'pick file',
        //       onClicked: () async {
        //         final image = await ImagePicker().pickImage(
        //           source: ImageSource.gallery,
        //           imageQuality: 99,
        //           maxHeight: isStorySize ? longSide : shortSide,
        //           maxWidth: isStorySize ? shortSide : longSide,
        //         );
        //         if (image == null) return;
        //
        //         int fileSize = await image.length();
        //         Logx.ist(_TAG, 'file size : ${fileSize / 1000} kb');
        //
        //         final directory = await getApplicationDocumentsDirectory();
        //         final name = basename(image.path);
        //         final imageFile = File('${directory.path}/$name');
        //         final newImage = await File(image.path).copy(imageFile.path);
        //
        //         newImageUrl = await FirestorageHelper.uploadFile(
        //             FirestorageHelper.AD_CAMPAIGN_IMAGES,
        //             StringUtils.getRandomString(28),
        //             newImage);
        //
        //         widget.advert.imageUrls.add(newImageUrl);
        //         setState(() {
        //           FirestoreHelper.pushAdvert(widget.advert);
        //         });
        //       },
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.only(left: 10.0),
        //       child: SizedBox.fromSize(
        //         size: const Size(56, 56),
        //         child: ClipOval(
        //           child: Material(
        //             color: Colors.redAccent,
        //             child: InkWell(
        //               splashColor: Colors.red,
        //               onTap: () {
        //                 // splashColorDialog(
        //                 //     context: context,
        //                 //     builder: (BuildContext context) {
        //                 //       return AlertDialog(
        //                 //         title: const Text('photos'),
        //                 //         content: photosListDialog(),
        //                 //       );
        //                 //     });
        //               },
        //               child: const Column(
        //                 mainAxisAlignment: MainAxisAlignment.center,
        //                 children: <Widget>[
        //                   Icon(Icons.delete_forever),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     )
        //   ],
        // ),
        // const SizedBox(height: 24),
        TextFieldWidget(
          label: 'title *',
          text: widget.advert.name,
          onChanged: (text) =>
          widget.advert = widget.advert.copyWith(name: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'link url',
          text: widget.advert.linkUrl,
          onChanged: (value) {
            widget.advert = widget.advert.copyWith(linkUrl: value);
          },
        ),
        const SizedBox(height: 24),
        dateTimeContainer(context, 'start'),
        const SizedBox(height: 24),
        dateTimeContainer(context, 'end'),
        const SizedBox(height: 24),
        // TextFieldWidget(
        //   label: 'views',
        //   text: widget.advert.views.toString(),
        //   onChanged: (value) {},
        // ),
        // const SizedBox(height: 12),
        // TextFieldWidget(
        //   label: 'clicks',
        //   text: widget.advert.clickCount.toString(),
        //   onChanged: (value) {},
        // ),
        const SizedBox(height: 12),
        UserPreferences.myUser.clearanceLevel>= Constants.MANAGER_LEVEL ? Row(
          children: <Widget>[
            const Text(
              'active : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.advert.isActive,
              onChanged: (value) {
                setState(() {
                  widget.advert =
                      widget.advert.copyWith(isActive: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ) : const SizedBox(height: 12),

        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            Navigator.of(context).pop();

            Advert freshAdvert = Fresh.freshAdvert(widget.advert);
            FirestoreHelper.pushAdvert(freshAdvert);
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            for (String imageUrl in widget.advert.imageUrls) {
              FirestorageHelper.deleteFile(imageUrl);
            }

            FirestoreHelper.deleteAdvert(widget.advert.id);

            Logx.ist(_TAG, 'advert deleted');
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget dateTimeContainer(BuildContext context, String type) {
    sStartDateTime = DateTimeUtils.getDate(widget.advert.startTime);
    sEndDateTime = DateTimeUtils.getDate(widget.advert.endTime);

    DateTime dateTime;

    if(type == 'start'){
      dateTime = sStartDateTime;
    } else {
      dateTime = sEndDateTime;
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
              foregroundColor: Constants.primary,
              shadowColor: Constants.shadowColor,
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0)),
              minimumSize: const Size(50, 50),
            ),
            onPressed: () {
              _selectDate(context, dateTime, type);
            },
            child: Text('$type date & time',
              style: const TextStyle(color: Constants.darkPrimary),),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate, String type) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      DateTime sDateTemp = DateTime(_sDate.year, _sDate.month, _sDate.day);

      setState(() {
        sDate = sDateTemp;
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

      if(type == 'start'){
        widget.advert =
            widget.advert.copyWith(startTime: sDateTime.millisecondsSinceEpoch);
      } else {
        widget.advert =
            widget.advert.copyWith(endTime: sDateTime.millisecondsSinceEpoch);
      }
    });
    return sTimeOfDay;
  }

  // Widget photosListDialog() {
  //   return SingleChildScrollView(
  //     child: SizedBox(
  //       height: 300.0, // Change as per your requirement
  //       width: 300.0, // Change as per your requirement
  //       child: ListView.builder(
  //         shrinkWrap: true,
  //         itemCount: widget.advert.imageUrls.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           return Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               Padding(
  //                 padding:
  //                 const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
  //                 child: ClipRRect(
  //                   borderRadius: BorderRadius.circular(8),
  //                   child: Image.network(widget.advert.imageUrls[index],
  //                       width: 100, height: 100, fit: BoxFit.fill),
  //                 ),
  //               ),
  //               SizedBox.fromSize(
  //                 size: const Size(50, 50),
  //                 child: ClipOval(
  //                   child: Material(
  //                     color: Colors.redAccent,
  //                     child: InkWell(
  //                       splashColor: Colors.red,
  //                       onTap: () {
  //                         FirestorageHelper.deleteFile(widget.advert.imageUrls[index]);
  //                         widget.advert.imageUrls.removeAt(index);
  //
  //                         FirestoreHelper.pushAdvert(widget.advert);
  //
  //                         Navigator.of(context).pop();
  //                         setState(() {});
  //                       },
  //                       child: const Column(
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: <Widget>[
  //                           Icon(Icons.delete_forever),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }
}
