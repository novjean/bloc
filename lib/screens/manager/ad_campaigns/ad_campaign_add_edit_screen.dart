import 'dart:io';

import 'package:bloc/db/entity/ad_campaign.dart';
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

class AdCampaignAddEditScreen extends StatefulWidget {
  AdCampaign adCampaign;
  String task;

  AdCampaignAddEditScreen({key, required this.adCampaign, required this.task})
      : super(key: key);

  @override
  _AdCampaignAddEditScreenState createState() =>
      _AdCampaignAddEditScreenState();
}

class _AdCampaignAddEditScreenState extends State<AdCampaignAddEditScreen> {
  static const String _TAG = 'AdCampaignAddEditScreen';

  String newImageUrl = '';
  bool isStorySize = false;

  DateTime sEndDateTime = DateTime.now();
  DateTime sDate = DateTime.now();
  TimeOfDay sTimeOfDay = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          titleSpacing: 0,
          title: AppBarTitle(title: '${widget.task} ad campaign'),
        ),
        body: _buildBody(context),
      );

  _buildBody(BuildContext context) {
    double longSide = 1280;
    double shortSide = 1024;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${widget.adCampaign.imageUrls.length} photos : '),
            const Spacer(),
            ButtonWidget(
              text: 'pick file',
              onClicked: () async {
                final image = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 99,
                  maxHeight: isStorySize ? longSide : shortSide,
                  maxWidth: isStorySize ? shortSide : longSide,
                );
                if (image == null) return;

                int fileSize = await image.length();
                Logx.ist(_TAG, 'file size : ${fileSize / 1000} kb');

                final directory = await getApplicationDocumentsDirectory();
                final name = basename(image.path);
                final imageFile = File('${directory.path}/$name');
                final newImage = await File(image.path).copy(imageFile.path);

                newImageUrl = await FirestorageHelper.uploadFile(
                    FirestorageHelper.AD_CAMPAIGN_IMAGES,
                    StringUtils.getRandomString(28),
                    newImage);

                widget.adCampaign.imageUrls.add(newImageUrl);
                setState(() {
                  FirestoreHelper.pushAdCampaign(widget.adCampaign);
                });
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
              value: widget.adCampaign.isStorySize,
              side: MaterialStateBorderSide.resolveWith(
                (states) => const BorderSide(width: 1.0),
              ),
              onChanged: (value) {
                setState(() {
                  isStorySize = value!;
                  widget.adCampaign =
                      widget.adCampaign.copyWith(isStorySize: value!);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'name *',
          text: widget.adCampaign.name,
          onChanged: (text) =>
              widget.adCampaign = widget.adCampaign.copyWith(name: text),
        ),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'link url',
          text: widget.adCampaign.linkUrl,
          onChanged: (value) {
            widget.adCampaign = widget.adCampaign.copyWith(linkUrl: value);
          },
        ),
        const SizedBox(height: 24),
        dateTimeContainer(context, 'end'),
        const SizedBox(height: 24),
        TextFieldWidget(
          label: 'views',
          text: widget.adCampaign.views.toString(),
          onChanged: (value) {},
        ),
        const SizedBox(height: 12),
        TextFieldWidget(
          label: 'clicks',
          text: widget.adCampaign.clickCount.toString(),
          onChanged: (value) {},
        ),
        const SizedBox(height: 24),
        Row(
          children: <Widget>[
            const Text(
              'party ad : ',
              style: TextStyle(fontSize: 17.0),
            ), //Text
            const SizedBox(width: 10), //SizedBox
            Checkbox(
              value: widget.adCampaign.isPartyAd,
              onChanged: (value) {
                setState(() {
                  widget.adCampaign =
                      widget.adCampaign.copyWith(isPartyAd: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
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
              value: widget.adCampaign.isActive,
              onChanged: (value) {
                setState(() {
                  widget.adCampaign =
                      widget.adCampaign.copyWith(isActive: value);
                });
              },
            ), //Checkbox
          ], //<Widget>[]
        ),

        const SizedBox(height: 24),
        ButtonWidget(
          text: 'save',
          onClicked: () {
            AdCampaign freshAdCampaign =
                Fresh.freshAdCampaign(widget.adCampaign);
            FirestoreHelper.pushAdCampaign(freshAdCampaign);

            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 24),
        ButtonWidget(
          text: 'delete',
          onClicked: () {
            if (!widget.adCampaign.isPartyAd) {
              for (String imageUrl in widget.adCampaign.imageUrls) {
                FirestorageHelper.deleteFile(imageUrl);
              }
            }

            FirestoreHelper.deleteAdCampaign(widget.adCampaign.id);

            Logx.ist(_TAG, 'ad campaign deleted');
            Navigator.of(context).pop();
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget dateTimeContainer(BuildContext context, String type) {
    sEndDateTime = DateTimeUtils.getDate(widget.adCampaign.endTime);

    DateTime dateTime;
    dateTime = sEndDateTime;

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
              _selectDate(context, dateTime);
            },
            child: const Text('end date & time',
              style: TextStyle(color: Constants.darkPrimary),),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime initDate) async {
    final DateTime? _sDate = await showDatePicker(
        context: context,
        initialDate: initDate,
        firstDate: DateTime(2023, 1),
        lastDate: DateTime(2101));
    if (_sDate != null) {
      DateTime sDateTemp = DateTime(_sDate.year, _sDate.month, _sDate.day);

      setState(() {
        sDate = sDateTemp;
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

    setState(() {
      sTimeOfDay = pickedTime!;

      DateTime sDateTime = DateTime(sDate.year, sDate.month, sDate.day,
          sTimeOfDay.hour, sTimeOfDay.minute);
      widget.adCampaign =
          widget.adCampaign.copyWith(endTime: sDateTime.millisecondsSinceEpoch);
    });
    return sTimeOfDay;
  }

  Widget photosListDialog() {
    return SingleChildScrollView(
      child: SizedBox(
        height: 300.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.adCampaign.imageUrls.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.0, vertical: 1),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(widget.adCampaign.imageUrls[index],
                        width: 100, height: 100, fit: BoxFit.fill),
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
                          if (!widget.adCampaign.isPartyAd) {
                            FirestorageHelper.deleteFile(
                                widget.adCampaign.imageUrls[index]);
                          }
                          widget.adCampaign.imageUrls.removeAt(index);

                          FirestoreHelper.pushAdCampaign(widget.adCampaign);

                          Navigator.of(context).pop();
                          setState(() {});
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
