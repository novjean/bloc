import 'dart:io';

import 'package:bloc/db/entity/ad_campaign.dart';
import 'package:bloc/db/shared_preferences/user_preferences.dart';
import 'package:bloc/helpers/fresh.dart';
import 'package:bloc/screens/manager/adverts/advert_checkout_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../helpers/dummy.dart';

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
                  child: Image.asset('assets/images/logo.png',
                  fit: BoxFit.cover,
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
        TextFieldWidget(
          label: 'title *',
          text: widget.advert.title,
          onChanged: (text) =>
          widget.advert = widget.advert.copyWith(title: text),
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
        const SizedBox(height: 12),
        UserPreferences.myUser.clearanceLevel >= Constants.MANAGER_LEVEL ? Column(
          children: [
            Row(
              children: <Widget>[
                const Text(
                  'paused : ',
                  style: TextStyle(fontSize: 17.0),
                ),
                const SizedBox(width: 10),
                Checkbox(
                  value: widget.advert.isPaused,
                  onChanged: (value) {
                    bool isPaused = value!;

                    FirestoreHelper.pullAdCampaignByAdvertId(widget.advert.id).then((res) {
                      if(res.docs.isNotEmpty){
                        DocumentSnapshot document = res.docs[0];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        AdCampaign adCampaign = Fresh.freshAdCampaignMap(data, true);

                        if(isPaused){
                          adCampaign = adCampaign.copyWith(isActive: false);
                          Logx.ist(_TAG, 'advert is paused and campaign is not active');
                        } else {
                          adCampaign = adCampaign.copyWith(isActive: true);
                          Logx.ist(_TAG, 'advert is unpaused and campaign is active');
                        }
                        FirestoreHelper.pushAdCampaign(adCampaign);

                      } else {
                        Logx.ist(_TAG, 'ad campaign not found for ${widget.advert.id}');

                        if(!isPaused){
                          AdCampaign adCampaign = Dummy.getDummyAdCampaign()
                              .copyWith(
                              name: widget.advert.title,
                              imageUrls: widget.advert.imageUrls,
                              clickCount: widget.advert.clickCount,
                              views: widget.advert.views,
                              linkUrl: widget.advert.linkUrl,
                              isActive: false,
                              isStorySize: true,

                              advertId: widget.advert.id,
                              isPurchased: widget.advert.isCompleted && widget.advert.isSuccess,

                              startTime: widget.advert.startTime,
                              endTime: widget.advert.endTime);

                          FirestoreHelper.pushAdCampaign(adCampaign);
                        } else {
                          // nothing to do
                          Logx.d(_TAG, 'no ad campaign found and active is false');
                        }
                      }
                    });

                    setState(() {
                      widget.advert =
                          widget.advert.copyWith(isPaused: value);
                    });

                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Text(
                  'active : ',
                  style: TextStyle(fontSize: 17.0),
                ), //Text
                const SizedBox(width: 10), //SizedBox
                Checkbox(
                  value: widget.advert.isActive,
                  onChanged: (value) {

                    FirestoreHelper.pullAdCampaignByAdvertId(widget.advert.id).then((res) {
                      if(res.docs.isNotEmpty){
                        DocumentSnapshot document = res.docs[0];
                        Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                        AdCampaign adCampaign = Fresh.freshAdCampaignMap(data, true);
                        adCampaign = adCampaign.copyWith(isActive: value);
                        FirestoreHelper.pushAdCampaign(adCampaign);

                        Logx.ist(_TAG, 'ad campaign is active $value');
                      } else {
                        Logx.ist(_TAG, 'ad campaign not found for ${widget.advert.id}');

                        if(value!){
                          AdCampaign adCampaign = Dummy.getDummyAdCampaign()
                              .copyWith(
                              name: widget.advert.title,
                              imageUrls: widget.advert.imageUrls,
                              clickCount: widget.advert.clickCount,
                              views: widget.advert.views,
                              linkUrl: widget.advert.linkUrl,
                              isActive: value,
                              isStorySize: true,

                              advertId: widget.advert.id,
                              isPurchased: widget.advert.isCompleted && widget.advert.isSuccess,

                              startTime: widget.advert.startTime,
                              endTime: widget.advert.endTime);

                          FirestoreHelper.pushAdCampaign(adCampaign);
                        } else {
                          // nothing to do
                          Logx.d(_TAG, 'no ad campaign found and active is false');
                        }
                      }
                    });

                    setState(() {
                      widget.advert =
                          widget.advert.copyWith(isActive: value);
                      FirestoreHelper.pushAdvert(widget.advert);
                      Logx.ist(_TAG, 'advert is updated');
                    });
                  },
                ), //Checkbox
              ], //<Widget>[]
            ),
            const SizedBox(height: 12),
            TextFieldWidget(
              label: 'result',
              text: widget.advert.result,
              maxLines: 3,
              onChanged: (text) {},
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Text(
                  'success : ',
                  style: TextStyle(fontSize: 17.0),
                ), //Text
                const SizedBox(width: 10),
                Checkbox(
                  value: widget.advert.isSuccess,
                  onChanged: (value) {
                    if(UserPreferences.myUser.clearanceLevel==Constants.ADMIN_LEVEL){
                      setState(() {
                        widget.advert = widget.advert.copyWith(isSuccess: value);
                      });
                      FirestoreHelper.pushAdvert(widget.advert);
                      Logx.ist(_TAG, 'admin: success is set to $value');
                    } else {
                      Logx.ist(_TAG,'success value cannot be changed');
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                const Text(
                  'completed : ',
                  style: TextStyle(fontSize: 17.0),
                ),
                const SizedBox(width: 10),
                Checkbox(
                  value: widget.advert.isCompleted,
                  onChanged: (value) {
                    if(UserPreferences.myUser.clearanceLevel==Constants.ADMIN_LEVEL){
                      setState(() {
                        widget.advert = widget.advert.copyWith(isCompleted: value);
                      });
                      FirestoreHelper.pushAdvert(widget.advert);
                      Logx.ist(_TAG, 'admin: completed is set to $value');
                    } else {
                      Logx.ist(_TAG,'completed value cannot be changed');
                    }
                  },
                ),
              ],
            ),

          ],
        ) : const SizedBox(height: 12),
        const SizedBox(height: 24),
        widget.advert.isSuccess ? ButtonWidget(
          text: 'save',
          onClicked: () {
            Navigator.of(context).pop();

            Advert freshAdvert = Fresh.freshAdvert(widget.advert);
            FirestoreHelper.pushAdvert(freshAdvert);
          },
        ) : ButtonWidget(
          text: 'purchase',
          onClicked: () async {

            int timeDiff = widget.advert.endTime - widget.advert.startTime;

            if(timeDiff>0){
              double days = (timeDiff/DateTimeUtils.millisecondsDay);

              double totalAmount = days * 10;

              double igst = totalAmount * Constants.igstPercent;
              double subTotal = totalAmount - igst;
              double bookingFee = totalAmount * 0;
              double grandTotal = subTotal + igst + bookingFee;

              widget.advert = widget.advert.copyWith(
                  igst: igst,
                  subTotal: subTotal,
                  bookingFee: bookingFee,
                  total: grandTotal);

              Advert freshAdvert = Fresh.freshAdvert(widget.advert);
              await FirestoreHelper.pushAdvert(freshAdvert);

              // navigate to payment page
              await Navigator.of(context).push (
                MaterialPageRoute(
                    builder: (context) =>
                        AdvertCheckoutScreen(
                          advert: widget.advert,
                        )),
              );
            } else {
              Logx.ilt(_TAG, 'end time cannot be before start time');
            }
          },
        ),
        const SizedBox(height: 24),
        widget.task == 'manage' ? ButtonWidget(
          text: 'delete',
          onClicked: () {
            for (String imageUrl in widget.advert.imageUrls) {
              FirestorageHelper.deleteFile(imageUrl);
            }

            FirestoreHelper.deleteAdvert(widget.advert.id);

            Logx.ist(_TAG, 'advert deleted');
            Navigator.of(context).pop();
          },
        ) : const SizedBox(),
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
              if(widget.advert.isSuccess && widget.advert.isCompleted){
                Logx.ilt(_TAG, '$type date and time cannot be changed after purchase');
              } else {
                _selectDate(context, dateTime, type);
              }
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
}
